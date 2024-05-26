import 'package:events_emitter/events_emitter.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:penniverse/dao/account_dao.dart';
import 'package:penniverse/dao/payment_dao.dart';
import 'package:penniverse/events.dart';
import 'package:penniverse/model/account.model.dart';
import 'package:penniverse/model/category.model.dart';
import 'package:penniverse/model/payment.model.dart';
import 'package:penniverse/providers/app_provider.dart';
import 'package:penniverse/screens/home/widgets/account_slider.dart';
import 'package:penniverse/screens/home/widgets/payment_list_item.dart';
import 'package:penniverse/screens/payments/payment_form.screen.dart';
import 'package:penniverse/screens/settings/settings.screen.dart';
import 'package:penniverse/theme/colors.dart';
import 'package:penniverse/widgets/currency.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/widgets.dart' as pw;

String greeting() {
  var hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Morning';
  }
  if (hour < 17) {
    return 'Afternoon';
  }
  return 'Evening';
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PaymentDao _paymentDao = PaymentDao();
  final AccountDao _accountDao = AccountDao();
  EventListener? _accountEventListener;
  EventListener? _categoryEventListener;
  EventListener? _paymentEventListener;
  List<Payment> _payments = [];
  List<Account> _accounts = [];
  double _income = 0;
  double _expense = 0;
  int touchedIndex = -1;
  DateTimeRange _range = DateTimeRange(
      start: DateTime.now().subtract(Duration(days: DateTime.now().day - 1)),
      end: DateTime.now());
  Account? _account;
  Category? _category;

  void handleChooseDateRange() async {
    final selected = await showDateRangePicker(
      context: context,
      initialDateRange: _range,
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    );
    if (selected != null) {
      setState(() {
        _range = selected;
        _fetchTransactions();
      });
    }
  }

  void _showFilterDialog() {
    // Show filter dialog
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        DateTime selectedDate = DateTime.now();
        return AlertDialog(
          title: const Text('Select Filter'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: const Text('Annual'),
                    onTap: () async {
                      final selectedYear = await _selectYear(context, selectedDate.year);
                      if (selectedYear != null) {
                        _applyAnnualFilter(selectedYear);
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('Monthly'),
                    onTap: () async {
                      final selectedMonth = await _selectMonth(context, selectedDate);
                      if (selectedMonth != null) {
                        _applyMonthlyFilter(selectedMonth);
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('Weekly'),
                    onTap: () async {
                      final selectedWeek = await _selectWeek(context);
                      if (selectedWeek != null) {
                        _applyWeeklyFilter(selectedWeek);
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<int?> _selectYear(BuildContext context, int initialYear) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(initialYear),
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDatePickerMode: DatePickerMode.year,
    );
    return picked?.year;
  }

  Future<DateTime?> _selectMonth(
      BuildContext context, DateTime initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDatePickerMode: DatePickerMode.year,
    );
    return picked;
  }

  Future<DateTimeRange?> _selectWeek(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDatePickerMode: DatePickerMode.day,
    );
    if (picked != null) {
      DateTime startOfWeek =
          picked.subtract(Duration(days: picked.weekday - 1));
      DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
      return DateTimeRange(start: startOfWeek, end: endOfWeek);
    }
    return null;
  }

  void _applyAnnualFilter(int year) {
    setState(() {
      _range = DateTimeRange(
        start: DateTime(year, 1, 1),
        end: DateTime(year, 12, 31),
      );
    });
    _fetchTransactions();
  }

  void _applyMonthlyFilter(DateTime month) {
    setState(() {
      _range = DateTimeRange(
        start: DateTime(month.year, month.month, 1),
        end: DateTime(month.year, month.month + 1, 0),
      );
    });
    _fetchTransactions();
  }

  void _applyWeeklyFilter(DateTimeRange weekRange) {
    setState(() {
      _range = weekRange;
    });
    _fetchTransactions();
  }

  void _fetchTransactions() async {
    List<Payment> trans = await _paymentDao.find(
        range: _range, category: _category, account: _account);
    double income = 0;
    double expense = 0;
    for (var payment in trans) {
      if (payment.type == PaymentType.credit) income += payment.amount;
      if (payment.type == PaymentType.debit) expense += payment.amount;
    }

    List<Account> accounts = await _accountDao.find(withSummary: true);

    setState(() {
      _payments = trans;
      _income = income;
      _expense = expense;
      _accounts = accounts;
    });
  }

  int maxItemsPerPage = 20; // Adjust this number based on your layout

  Future<void> _generatePDF(String username, DateTimeRange dateRange, String currencySymbol) async {
    try {
      final dateFormat = DateFormat("yyyy-MM-dd hh:mma");
      final ByteData logoImage = await rootBundle.load('assets/logo/penniverse_logo.png');
      final Uint8List logoImageUint8List = logoImage.buffer.asUint8List();
      final pw.MemoryImage logo = pw.MemoryImage(logoImageUint8List);
      final ByteData signatureImage = await rootBundle.load('assets/images/signature.png');
      final Uint8List signatureImageUint8List = signatureImage.buffer.asUint8List();
      final pw.MemoryImage signature = pw.MemoryImage(signatureImageUint8List);
      final currencySymbol = Provider.of<AppProvider>(context, listen: false).currency!;

      final roboto = await PdfGoogleFonts.robotoRegular();
      final robotoBold = await PdfGoogleFonts.robotoBold();

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(
            base: roboto,
            bold: robotoBold,
          ),
          header: (context) => _buildPdfHeader(logo),
          footer: (context) => _buildPdfFooter(signature),
          build: (context) => _buildPdfContent(username, dateRange, dateFormat,currencySymbol),
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      // Handle error, e.g., show a message to the user
    }
  }

  pw.Widget _buildPdfHeader(pw.MemoryImage logo) {
    return pw.Column(
      children: [
        pw.Container(
          height: 70,
          width: 70,
          child: pw.Image(logo),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 10),
          child: pw.Text("Penniverse"),
        ),
      ],
    );
  }

  pw.Widget _buildPdfFooter(pw.MemoryImage signature) {

    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            'Thank you for using Penniverse. -JB',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10), // Add some spacing between text and image
          pw.Image(signature, width: 100, height: 50), // Adjust width and height as needed
        ],
      ),
    );
  }

  List<pw.Widget> _buildPdfContent(String username, DateTimeRange dateRange, DateFormat dateFormat,String currencySymbol) {
    return [
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 20),
          pw.Center(
            child: pw.Text(
              "Transaction Summary",
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                decoration: pw.TextDecoration.underline,
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text("Hi $username!"),
          pw.SizedBox(height: 20),
          pw.Text("General Accounts:", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellHeight: 30,
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {0: pw.Alignment.centerLeft},
            cellPadding: const pw.EdgeInsets.all(5),
            headers: ['Name', 'Holder', 'Account Number', 'Balance ($currencySymbol)', 'Income ($currencySymbol)', 'Expense ($currencySymbol)'],
            data: _accounts.map((account) => [
              account.name,
              account.holderName,
              account.accountNumber,
              '${account.balance ?? 0}',
              '${account.income ?? 0}',
              '${account.expense ?? 0}',
            ]).toList(),
          ),
        ],
      ),
      pw.SizedBox(height: 20),
      pw.Center(
        child: pw.Container(
          child: pw.Text(
            "Transactions from ${DateFormat("dd MMM yyyy").format(dateRange.start)} - ${DateFormat("dd MMM yyyy").format(dateRange.end)}",
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1.0)),
          ),
        ),
      ),
      pw.SizedBox(height: 16),

      pw.Text("Total Income ($currencySymbol): ${(_income.toString())}"),
      pw.Text("Total Expenses ($currencySymbol): ${_expense.toString()}"),
      pw.TableHelper.fromTextArray(
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
        cellHeight: 30,
        cellAlignment: pw.Alignment.centerLeft,
        cellAlignments: {0: pw.Alignment.centerLeft},
        cellPadding: const pw.EdgeInsets.all(5),
        headers: ['Date', 'Category', 'Amount ($currencySymbol)', 'Type'],
        data: _payments.map((payment) => [
          dateFormat.format(payment.datetime).replaceFirst('AM', 'am').replaceFirst('PM', 'pm'),
          payment.category.name,
          payment.amount.toString(),
          payment.type == PaymentType.credit ? 'CR' : 'DR',
        ]).toList(),
      ),
    ];
  }




  @override
  void initState() {
    super.initState();
    _fetchTransactions();

    _accountEventListener = globalEvent.on("account_update", (data) {
      debugPrint("accounts are changed");
      _fetchTransactions();
    });

    _categoryEventListener = globalEvent.on("category_update", (data) {
      debugPrint("categories are changed");
      _fetchTransactions();
    });

    _paymentEventListener = globalEvent.on("payment_update", (data) {
      debugPrint("payments are changed");
      _fetchTransactions();
    });
  }

  @override
  void dispose() {
    _accountEventListener?.cancel();
    _categoryEventListener?.cancel();
    _paymentEventListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Container(
                margin: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Heya!😃 Good ${greeting()}"),
                          Selector<AppProvider, String?>(
                            selector: (_, provider) => provider.username,
                            builder: (context, state, _) => Text(
                              state ?? "Guest",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen()),
                        );
                      },
                      icon: const Icon(IconsaxOutline.user_octagon),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                width: double.infinity,
                child: AccountsSlider(
                  accounts: _accounts,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    const Text(
                      "Transactions",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                    ),
                    const Expanded(child: SizedBox()),
                    MaterialButton(
                      onPressed: handleChooseDateRange,
                      height: double.minPositive,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      child: Row(
                        children: [
                          Text(
                            "${DateFormat("dd MMM").format(_range.start)} - ${DateFormat("dd MMM").format(_range.end)}",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const Icon(Icons.arrow_drop_down_outlined)
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: _showFilterDialog,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: ThemeColors.success.withOpacity(0.2),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text.rich(TextSpan(children: [
                                    TextSpan(
                                        text: "Income",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                  ])),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  CurrencyText(
                                    _income,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: ThemeColors.success,
                                        ),
                                  )
                                ],
                              ),
                            ))),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: ThemeColors.error.withOpacity(0.2),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text.rich(TextSpan(children: [
                                    TextSpan(
                                        text: "Expense",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                  ])),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  CurrencyText(
                                    _expense,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: ThemeColors.error,
                                        ),
                                  )
                                ],
                              ),
                            ))),
                  ],
                ),
              ),
              if (_payments.isNotEmpty)
                DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(text: "Payments"),
                          Tab(text: "Expense Chart"),
                        ],
                      ),
                      SizedBox(
                        height: 400, // Adjust as needed
                        child: TabBarView(
                          children: [
                            ListView.separated(
                              padding: EdgeInsets.zero,
                              itemBuilder: (BuildContext context, index) {
                                return PaymentListItem(
                                    payment: _payments[index],
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (builder) => PaymentForm(
                                                    type: _payments[index].type,
                                                    payment: _payments[index],
                                                  )));
                                    });
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Container(
                                  width: double.infinity,
                                  color: Colors.grey.withAlpha(25),
                                  height: 1,
                                  margin: const EdgeInsets.only(
                                      left: 75, right: 20),
                                );
                              },
                              itemCount: _payments.length,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: PieChart(
                                PieChartData(
                                  pieTouchData: PieTouchData(
                                    touchCallback:
                                        (FlTouchEvent event, pieTouchResponse) {
                                      setState(() {
                                        if (!event
                                                .isInterestedForInteractions ||
                                            pieTouchResponse == null ||
                                            pieTouchResponse.touchedSection ==
                                                null) {
                                          touchedIndex = -1;
                                          return;
                                        }
                                        touchedIndex = pieTouchResponse
                                            .touchedSection!
                                            .touchedSectionIndex;
                                      });
                                    },
                                  ),
                                  centerSpaceRadius: 40,
                                  sections: _buildChartSections(),
                                  borderData: FlBorderData(show: false),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 25),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Image.asset("assets/images/emptyfile.png"),
                      ),
                      const Text("No payments!"),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        heroTag: "pdf-hero-fab",
        onPressed: () {
          _generatePDF(
              Provider.of<AppProvider>(context, listen: false).username ??
                  "Guest",
              _range, Provider.of<AppProvider>(context, listen: false).currency!);
        },
        child: const Icon(Icons.picture_as_pdf),
      ),
    );
  }

  List<PieChartSectionData> _buildChartSections() {
    Map<String, CategoryExpense> categoryExpenses = {};  // Use category name as the key and a custom class to store amount and count
    Map<String, Category> categoryDetails = {}; // Store category details

    for (var payment in _payments) {
      if (payment.type == PaymentType.debit) {
        var category = payment.category;
        if (categoryExpenses.containsKey(category.name)) {
          categoryExpenses[category.name]!.amount += payment.amount;
          categoryExpenses[category.name]!.count += 1;
        } else {
          categoryExpenses[category.name] = CategoryExpense(payment.amount, 1);
        }
        categoryDetails[category.name] = category; // Store the category details
      }
    }

    List<PieChartSectionData> sections = [];
    int i = 0;
    for (var entry in categoryExpenses.entries) {
      final categoryName = entry.key;
      final categoryExpense = entry.value;
      final category = categoryDetails[categoryName]; // Retrieve category details
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 60.0 : 50.0;

      if (category != null) {
        sections.add(
          PieChartSectionData(
            titlePositionPercentageOffset: 1,
            value: categoryExpense.amount,
            title: '$categoryName (${categoryExpense.count})',  // Include the count in the title
            color: category.color,
            radius: radius,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,

            ),
          ),
        );
      }
      i++;
    }

    return sections;
  }



}
class CategoryExpense {
  double amount;
  int count;

  CategoryExpense(this.amount, this.count);
}

