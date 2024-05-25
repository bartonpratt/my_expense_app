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

  void loadMore() async {
    if (_count > _payments.length || _payments.isEmpty) {
      List<Payment> payments = await _paymentDao.find(
          limit: 20, offset: _payments.length);
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
      if (_selectedFilter == PaymentFilter.debit) {
        _filteredPayments = _payments.where((p) => p.type == PaymentType.debit).toList();
      } else if (_selectedFilter == PaymentFilter.credit) {
        _filteredPayments = _payments.where((p) => p.type == PaymentType.credit).toList();
      } else {
        _filteredPayments = List.from(_payments);
      }
    });
  }

  @override
  void initState() {
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
    super.initState();
  }

  @override
  void dispose() {
    _paymentEventListener?.cancel();
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
        title: const Text(
          "Payments",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        actions: [
          PopupMenuButton<PaymentFilter>(
            onSelected: _onFilterChanged,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<PaymentFilter>>[
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
      body: RefreshIndicator(
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
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
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

