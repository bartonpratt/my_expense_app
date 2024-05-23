import 'package:events_emitter/events_emitter.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:penniverse/dao/account_dao.dart';
import 'package:penniverse/dao/payment_dao.dart';
import 'package:penniverse/events.dart';
import 'package:penniverse/extension.dart';
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
import 'package:provider/provider.dart';
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

    List<Account> accounts = await _accountDao.find(withSummery: true);

    setState(() {
      _payments = trans;
      _income = income;
      _expense = expense;
      _accounts = accounts;
    });
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
                          Text("Hi! Good ${greeting()}"),
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
                child: Row(children: [
                  const Text("Transactions",
                      style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
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
              if (_payments.isNotEmpty)
                DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
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
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
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
                                  margin: const EdgeInsets.only(left: 75, right: 20),
                                );
                              },
                              itemCount: _payments.length,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: PieChart(
                                PieChartData(
                                  pieTouchData: PieTouchData(
                                    touchCallback:
                                        (FlTouchEvent event, pieTouchResponse) {
                                      setState(() {
                                        if (!event.isInterestedForInteractions ||
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
    );
  }


  List<PieChartSectionData> _buildChartSections() {
    Map<Category, double> categoryExpenses = {};
    for (var payment in _payments) {
      if (payment.type == PaymentType.debit) {
        var category = payment.category;
        categoryExpenses.update(category, (value) => value + payment.amount,
            ifAbsent: () => payment.amount);
      }
    }

    List<PieChartSectionData> sections = [];
    int i = 0;
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
          color: category.color,
          radius: radius,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      );
      i++;
    });

    return sections;
  }



}
