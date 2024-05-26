import 'package:events_emitter/events_emitter.dart';
import 'package:penniverse/dao/payment_dao.dart';
import 'package:penniverse/events.dart';
import 'package:penniverse/model/payment.model.dart';
import 'package:penniverse/screens/home/widgets/payment_list_item.dart';
import 'package:flutter/material.dart';
import 'package:penniverse/screens/payments/payment_form.screen.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

enum PaymentFilter { all, debit, credit }

class _PaymentsScreenState extends State<PaymentsScreen> {
  final PaymentDao _paymentDao = PaymentDao();
  EventListener? _paymentEventListener;
  List<Payment> _payments = [];
  List<Payment> _filteredPayments = [];
  int _count = 0;
  final int limit = 20;
  PaymentFilter _selectedFilter = PaymentFilter.all;
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  bool _isSearching = false;

  void loadMore() async {
    if (_count > _payments.length || _payments.isEmpty) {
      List<Payment> payments =
          await _paymentDao.find(limit: 20, offset: _payments.length);
      int count = await _paymentDao.count();
      setState(() {
        _count = count;
        _payments.addAll(payments);
        _applyFilter();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("No more transactions"),
        duration: Duration(seconds: 1),
      ));
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredPayments = _payments.where((payment) {
        final matchesFilter = _selectedFilter == PaymentFilter.all ||
            (_selectedFilter == PaymentFilter.debit &&
                payment.type == PaymentType.debit) ||
            (_selectedFilter == PaymentFilter.credit &&
                payment.type == PaymentType.credit);

        final matchesSearch =
            payment.title.toLowerCase().contains(_searchTerm.toLowerCase()) ||
                payment.description
                    .toLowerCase()
                    .contains(_searchTerm.toLowerCase()) ||
                payment.account.name.toLowerCase().contains(_searchTerm
                    .toLowerCase()) || // Assuming Account has a name attribute
                payment.category.name.toLowerCase().contains(_searchTerm
                    .toLowerCase()); // Assuming Category has a name attribute

        return matchesFilter && matchesSearch;
      }).toList();
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchTerm = _searchController.text;
      _applyFilter();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchTerm = '';
        _applyFilter();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    loadMore();
    _paymentEventListener = globalEvent.on("payment_update", (data) async {
      List<Payment> payments = await _paymentDao.find(
        limit: _payments.length > limit ? _payments.length : limit,
        offset: 0,
      );
      int count = await _paymentDao.count();
      setState(() {
        _count = count;
        _payments = payments;
        _applyFilter();
      });
      debugPrint("payments are changed");
    });
  }

  @override
  void dispose() {
    _paymentEventListener?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onFilterChanged(PaymentFilter filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 18),
              )
            : const Text(
                "Payments",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18,),
              ),
        leading: IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: _toggleSearch,
        ),
        actions: _isSearching
            ? null
            : [
                PopupMenuButton<PaymentFilter>(
                  onSelected: _onFilterChanged,
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<PaymentFilter>>[
                    const PopupMenuItem<PaymentFilter>(
                      value: PaymentFilter.all,
                      child: Text('All'),
                    ),
                    const PopupMenuItem<PaymentFilter>(
                      value: PaymentFilter.debit,
                      child: Text('Debit (DR)'),
                    ),
                    const PopupMenuItem<PaymentFilter>(
                      value: PaymentFilter.credit,
                      child: Text('Credit (CR)'),
                    ),
                  ],
                ),
              ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _count = 0;
                  _payments = [];
                });
                return loadMore();
              },
              child: _filteredPayments.isEmpty
                  ? Center(
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
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 0),
                      itemCount: _filteredPayments.length,
                      itemBuilder: (BuildContext context, index) {
                        return PaymentListItem(
                          payment: _filteredPayments[index],
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (builder) => PaymentForm(
                                type: _filteredPayments[index].type,
                                payment: _filteredPayments[index],
                              ),
                            ));
                          },
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Container(
                          width: double.infinity,
                          color: Colors.grey.withAlpha(25),
                          height: 1,
                          margin: const EdgeInsets.only(left: 75, right: 20),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        heroTag: "payment-hero-fab",
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (builder) => const PaymentForm(type: PaymentType.credit),
          ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
