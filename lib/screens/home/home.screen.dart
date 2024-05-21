
import 'package:events_emitter/events_emitter.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:my_expense_app/dao/account_dao.dart';
import 'package:my_expense_app/dao/payment_dao.dart';
import 'package:my_expense_app/events.dart';
import 'package:my_expense_app/extension.dart';
import 'package:my_expense_app/model/account.model.dart';
import 'package:my_expense_app/model/category.model.dart';
import 'package:my_expense_app/model/payment.model.dart';
import 'package:my_expense_app/providers/app_provider.dart';
import 'package:my_expense_app/screens/home/widgets/account_slider.dart';
import 'package:my_expense_app/screens/home/widgets/payment_list_item.dart';
import 'package:my_expense_app/screens/payments/payment_form.screen.dart';
import 'package:my_expense_app/screens/settings/settings.screen.dart';
import 'package:my_expense_app/theme/colors.dart';
import 'package:my_expense_app/widgets/currency.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:fl_chart/fl_chart.dart';

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
  //double _savings = 0;
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

  void _fetchTransactions() async {
    List<Payment> trans = await _paymentDao.find(
        range: _range, category: _category, account: _account);
    double income = 0;
    double expense = 0;
    for (var payment in trans) {
      if (payment.type == PaymentType.credit) income += payment.amount;
      if (payment.type == PaymentType.debit) expense += payment.amount;
    }

    //fetch accounts
    List<Account> accounts = await _accountDao.find(withSummery: true);

    setState(() {
      _payments = trans;
      _income = income;
      _expense = expense;
      _accounts = accounts;
    });
  }

  // void _fetchExpenseTransactions() async {
  //   List<Payment> trans = await _paymentDao.find(
  //       range: _range, category: _category, account: _account);
  //   double expense = 0;
  //   for (var payment in trans) {
  //     if (payment.type == PaymentType.debit) {
  //       expense += payment.amount;
  //     }
  //   }
  //
  //   // Fetch accounts
  //   List<Account> accounts = await _accountDao.find(withSummery: true);
  //
  //   setState(() {
  //     _payments = trans;
  //     _expense = expense;
  //     _accounts = accounts;
  //   });
  // }

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
                    Text("Hi! Good ${greeting()}"),
                    Selector<AppProvider, String?>(
                        selector: (_, provider) => provider.username,
                        builder: (context, state, _) => Text(
                              state ?? "Guest",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ))
                  ],
                )),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen()));
                    },
                    icon: const Icon(IconsaxOutline.user_octagon))
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            // height: 190,
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
            child: Row(children: [
              const Text("Transactions",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
              const Expanded(child: SizedBox()),
              MaterialButton(
                onPressed: () {
                  handleChooseDateRange();
                },
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
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                                //TextSpan(text: "▼", style: TextStyle(color: ThemeColors.success)),
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
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: ThemeColors.success,
                                    fontFamily: context.monoFontFamily),
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
                                //TextSpan(text: "▲", style: TextStyle(color: ThemeColors.error)),
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
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: ThemeColors.error,
                                    fontFamily: context.monoFontFamily),
                              )
                            ],
                          ),
                        ))),
              ],
            ),
          ),

          _payments.isNotEmpty
              ? Column(
                children: [
                  Container(
                    height: 250, // Adjust height as needed
                    padding: const EdgeInsets.all(16),
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex =
                                  pieTouchResponse.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        centerSpaceRadius: 40,
                        sections: _buildChartSections(), // Define chart sections
                        borderData: FlBorderData(show: false), // Hide chart border
                      ),
                    ),
                  ),
                  ListView.separated(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, index) {
                        return PaymentListItem(
                            payment: _payments[index],
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (builder) => PaymentForm(
                                        type: _payments[index].type,
                                        payment: _payments[index],
                                      )));
                            });
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Container(
                          width: double.infinity,
                          color: Colors.grey.withAlpha(25),
                          height: 1,
                          margin: const EdgeInsets.only(left: 75, right: 20),
                        );
                      },
                      itemCount: _payments.length,
                    ),
                ],
              )
              : Container(
                  padding: const EdgeInsets.symmetric(vertical: 25),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Lottie.network(
                            "https://lottie.host/82db2f50-94b0-4e70-bd7d-efa373b23d73/BUtKcXysHb.json"),
                      ),
                      const Text("No payments!"),
                    ],
                  ),
                ),
        ],
      )),
    ));
  }

  // Method to build chart sections based on expense data
  List<PieChartSectionData> _buildChartSections() {


    // Group expenses by category
    Map<Category, double> categoryExpenses = {};
    _payments.forEach((payment) {
      if (payment.type == PaymentType.debit) {
        var category = payment.category;
        categoryExpenses.update(category, (value) => value + payment.amount,
            ifAbsent: () => payment.amount);
      }
    });

    // Create chart sections based on expense categories
    // Create chart sections based on expense categories
    List<PieChartSectionData> sections = [];
    int i = 0; // Counter for index
    categoryExpenses.entries.forEach((entry) {
      final category = entry.key;
      final amount = entry.value;
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 60.0 : 50.0;
      sections.add(
        PieChartSectionData(
          titlePositionPercentageOffset: 1,
          value: amount,
          title: category.name,
          color: category.color, // Use the color assigned to the category
          radius: radius,
          titleStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      );
      i++; // Increment the index counter
    });

    return sections;


  }
}
