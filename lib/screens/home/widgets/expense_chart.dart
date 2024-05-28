import 'package:penniverse/exports.dart';

class ExpensePieChart extends StatefulWidget {
  final List<Payment> payments;
  final PaymentType paymentType;

  const ExpensePieChart({super.key, required this.payments, required this.paymentType});

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  EventListener? _accountEventListener;
  EventListener? _categoryEventListener;
  EventListener? _paymentEventListener;
  int touchedIndex = -1;
  late String _currencySymbol;
  Map<String, CategoryExpense> _categoryExpenses = {};

  @override
  void initState() {
    super.initState();

    _accountEventListener = globalEvent.on("account_update", (data){
      debugPrint("accounts are changed");
      globalEvent.emit("account_update");
    });
    _paymentEventListener = globalEvent.on("payment_update", (data){
      debugPrint("Payments are made, updating accounts");
      globalEvent.emit("payment_update");
    });

    _currencySymbol = Provider.of<AppProvider>(context, listen: false).currency!;
    _computeCategoryExpenses();
  }

  void _computeCategoryExpenses() {
    Map<String, CategoryExpense> categoryExpenses = {};
    Map<String, Category> categoryDetails = {};
    double totalExpense = 0;

    for (var payment in widget.payments) {
      if (payment.type == widget.paymentType) {
        var category = payment.category;
        if (categoryExpenses.containsKey(category.name)) {
          categoryExpenses[category.name]!.amount += payment.amount;
          categoryExpenses[category.name]!.count += 1;
        } else {
          categoryExpenses[category.name] = CategoryExpense(payment.amount, 1, category.color, category.icon);
        }
        categoryDetails[category.name] = category;
        totalExpense += payment.amount;
      }
    }

    setState(() {
      _categoryExpenses = categoryExpenses;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_categoryExpenses.isEmpty) {
      return Center(child: Text('No expenses to display.'));
    }

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: Card(
            elevation: 3,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions || pieTouchResponse?.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = pieTouchResponse!.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                centerSpaceRadius: 40,
                sections: _buildChartSections(),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            separatorBuilder: (BuildContext context, int index) {
              return Container(
                width: double.infinity,
                color: Colors.grey.withAlpha(25),
                height: 1,
                margin: const EdgeInsets.only(left: 75, right: 20),
              );
            },
            itemCount: _categoryExpenses.length,
            itemBuilder: (context, index) {
              final categoryName = _categoryExpenses.keys.elementAt(index);
              final categoryExpense = _categoryExpenses[categoryName]!;
              final totalExpense = _categoryExpenses.values.fold(0.0, (sum, item) => sum + item.amount);
              final percentage = (categoryExpense.amount / totalExpense) * 100;

              return ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: categoryExpense.color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(categoryName),
                      ],
                    ),
                    Text('${categoryExpense.count}'),
                    Text(
                      _currencySymbol,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(categoryExpense.amount.toStringAsFixed(2)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildChartSections() {
    List<PieChartSectionData> sections = [];
    int i = 0;
    for (var entry in _categoryExpenses.entries) {
      final categoryName = entry.key;
      final categoryExpense = entry.value;
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 70.0 : 50.0;

      // Trim category name if it exceeds 7 characters
      String title = categoryName.length > 7
          ? "${categoryName.substring(0, 7)}..."
          : categoryName;

      sections.add(
        PieChartSectionData(
          badgeWidget: _Badge(
            categoryExpense.icon,
            size: 40,
            borderColor: Colors.black,
          ),
          badgePositionPercentageOffset: .98,
          titlePositionPercentageOffset: 2,
          value: categoryExpense.amount,
          title: title,
          color: categoryExpense.color,
          radius: radius,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      i++;
    }

    return sections;
  }
}

class _Badge extends StatelessWidget {
  const _Badge(
      this.icon, {
        required this.size,
        required this.borderColor,
      });

  final IconData icon;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
        child: Icon(
          icon,
          color: Colors.black,
        ),
      ),
    );
  }
}

class CategoryExpense {
  double amount;
  int count;
  Color color;
  IconData icon;

  CategoryExpense(this.amount, this.count, this.color, this.icon);
}
