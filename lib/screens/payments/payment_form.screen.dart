import 'package:penniverse/widgets/dialog/category_form.dialog.dart';
import 'package:intl/intl.dart';
import 'package:penniverse/exports.dart';

typedef OnCloseCallback = Function(Payment payment);
final DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm a');

class PaymentForm extends StatefulWidget {
  final PaymentType type;
  final Payment? payment;
  final OnCloseCallback? onClose;

  const PaymentForm(
      {super.key, required this.type, this.payment, this.onClose});

  @override
  State<PaymentForm> createState() => _PaymentForm();
}

class _PaymentForm extends State<PaymentForm> {
  bool _initialised = false;
  final PaymentDao _paymentDao = PaymentDao();
  final AccountDao _accountDao = AccountDao();
  final CategoryDao _categoryDao = CategoryDao();

  EventListener? _accountEventListener;
  EventListener? _categoryEventListener;

  List<Account> _accounts = [];
  List<Category> _categories = [];

  //values
  int? _id;
  String _title = "";
  String _description = "";
  Account? _account;
  Category? _category;
  double _amount = 0;
  PaymentType _type = PaymentType.credit;
  DateTime _datetime = DateTime.now();
  File? _receiptImage;

  loadAccounts() {
    _accountDao.find().then((value) {
      setState(() {
        _accounts = value;
      });
    });
  }

  Future<void> loadCategories(PaymentType type) async {
    try {
      String categoryType = type == PaymentType.credit ? 'CR' : 'DR';
      List<Category> categories = await _categoryDao.findByType(categoryType);
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  void populateState() async {
    try {
      await loadAccounts();
      await loadCategories(widget.type);
      if (widget.payment != null) {
        setState(() {
          _id = widget.payment!.id;
          _title = widget.payment!.title;
          _description = widget.payment!.description;
          _account = widget.payment!.account;
          _category = widget.payment!.category;
          _amount = widget.payment!.amount;
          _type = widget.payment!.type;
          _datetime = widget.payment!.datetime;
          _receiptImage = widget.payment!.receipt; // Add receipt handling
          _initialised = true;
        });
      } else {
        setState(() {
          _type = widget.type;
          _initialised = true;
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

// Method to handle image selection from gallery
  Future<void> _pickReceiptImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _receiptImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  // UI method to display image picker button
  bool _showReceiptImage = false;

  Widget _buildReceiptImagePicker() {
    return Column(
      children: [
        if (_receiptImage != null)
          GestureDetector(
            onTap: _toggleReceiptImageVisibility,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                    10), // Adjust the border radius as needed
                border: Border.all(
                    color: Colors.red,
                    width: 2), // Adjust the border color and width as needed
              ),
              padding: const EdgeInsets.all(8), // Adjust padding as needed
              child: Text(
                _showReceiptImage ? 'Hide Receipt Image' : 'Show Receipt Image',
                style: const TextStyle(
                  color: Colors.black, // Adjust text color as needed
                  fontWeight: FontWeight.bold, // Adjust text style as needed
                ),
              ),
            ),
          ),
        if (_showReceiptImage && _receiptImage != null)
          Padding(
            padding: const EdgeInsets.all(
                8.0), // Adjust padding around the image as needed
            child: SizedBox(
              width: 200, // Adjust width as needed
              height: 200, // Adjust height as needed
              child: Image.file(
                _receiptImage!,
                fit: BoxFit.cover, // Adjust fit property as needed
              ),
            ),
          ),
        ElevatedButton(
          onPressed: _pickReceiptImage,
          child: Text(_receiptImage == null
              ? 'Add Receipt Image'
              : 'Change Receipt Image'),
        ),
      ],
    );
  }

  void _toggleReceiptImageVisibility() {
    setState(() {
      _showReceiptImage = !_showReceiptImage;
    });
  }

  Future<void> chooseDate(BuildContext context) async {
    try {
      DateTime initialDate = _datetime;
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now());
      if (picked != null && initialDate != picked) {
        setState(() {
          _datetime = DateTime(picked.year, picked.month, picked.day,
              initialDate.hour, initialDate.minute);
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  Future<void> chooseTime(BuildContext context) async {
    try {
      DateTime initialDate = _datetime;
      TimeOfDay initialTime =
          TimeOfDay(hour: initialDate.hour, minute: initialDate.minute);
      final TimeOfDay? time = await showTimePicker(
          context: context,
          initialTime: initialTime,
          initialEntryMode: TimePickerEntryMode.input);
      if (time != null && initialTime != time) {
        setState(() {
          _datetime = DateTime(initialDate.year, initialDate.month,
              initialDate.day, time.hour, time.minute);
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  void handleSaveTransaction(context) async {
    try {
      Payment payment = Payment(
        id: _id,
        account: _account!,
        category: _category!,
        amount: _amount,
        type: _type,
        datetime: _datetime,
        title: _title,
        description: _description,
        receipt: _receiptImage,
      );
      await _paymentDao.upsert(payment);
      if (widget.onClose != null) {
        widget.onClose!(payment);
      }
      Navigator.of(context).pop();
      globalEvent.emit("payment_update");
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    populateState();
    _accountEventListener = globalEvent.on("account_update", (data) {
      debugPrint("accounts are changed");
      loadAccounts();
    });

    _categoryEventListener = globalEvent.on("category_update", (data) {
      debugPrint("categories are changed");
      loadCategories(_type);
    });
  }

  @override
  void dispose() {
    _accountEventListener?.cancel();
    _categoryEventListener?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialised) return const CircularProgressIndicator();

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(IconsaxOutline.arrow_left_2),
          ),
          title: Text(
            "${widget.payment == null ? "New" : "Edit"} Payment",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
                child: SingleChildScrollView(
                    child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 25,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, bottom: 20),
                      child: Wrap(
                        spacing: 10,
                        children: [
                          AppButton(
                            onPressed: () {
                              setState(() {
                                _type = PaymentType.credit;
                                loadCategories(_type);
                              });
                            },
                            label: "Income",
                            color: Theme.of(context).colorScheme.primary,
                            type: _type == PaymentType.credit
                                ? AppButtonType.filled
                                : AppButtonType.outlined,
                            borderRadius: BorderRadius.circular(45),
                          ),
                          AppButton(
                            onPressed: () {
                              setState(() {
                                _type = PaymentType.debit;
                                loadCategories(_type);
                              });
                            },
                            label: "Expense",
                            color: Theme.of(context).colorScheme.primary,
                            type: _type == PaymentType.debit
                                ? AppButtonType.filled
                                : AppButtonType.outlined,
                            borderRadius: BorderRadius.circular(45),
                          ),
                        ],
                      )),
                  Container(
                    margin:
                        const EdgeInsets.only(left: 15, right: 15, bottom: 25),
                    child: TextFormField(
                      decoration: InputDecoration(
                          filled: true,
                          hintText: "Please enter title",
                          label: const Text("Title"),
                          border: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 15)),
                      initialValue: _title,
                      onChanged: (text) {
                        setState(() {
                          _title = text;
                        });
                      },
                    ),
                  ),
                  Container(
                      margin: const EdgeInsets.only(
                          left: 15, right: 15, bottom: 25),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,4}')),
                        ],
                        decoration: InputDecoration(
                            filled: true,
                            hintText: "0.0",
                            label: const Text("Amount"),
                            prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: CurrencyText(
                                  null,
                                )),
                            prefixIconConstraints:
                                const BoxConstraints(minWidth: 0, minHeight: 0),
                            border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 15)),
                        initialValue: _amount == 0 ? "" : _amount.toString(),
                        onChanged: (String text) {
                          setState(() {
                            _amount = double.parse(text == "" ? "0" : text);
                          });
                        },
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildReceiptImagePicker(),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Container(
                      margin: const EdgeInsets.only(
                          left: 15, right: 15, bottom: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: InkWell(
                                  onTap: () {
                                    chooseDate(context);
                                  },
                                  child: Wrap(
                                    spacing: 10,
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      Text(DateFormat("dd/MM/yyyy")
                                          .format(_datetime))
                                    ],
                                  ))),
                          Expanded(
                              child: InkWell(
                                  onTap: () {
                                    chooseTime(context);
                                  },
                                  child: Wrap(
                                    spacing: 10,
                                    children: [
                                      Icon(
                                        Icons.watch_later_outlined,
                                        size: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      Text(DateFormat("hh:mm a")
                                          .format(_datetime))
                                    ],
                                  ))),
                        ],
                      )),
                  Container(
                    padding: const EdgeInsets.only(left: 15, bottom: 15),
                    child: const Text(
                      "Select Account",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                  Container(
                    height: 70,
                    margin: const EdgeInsets.only(bottom: 25),
                    width: double.infinity,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                      children: List.generate(_accounts.length + 1, (index) {
                        if (index == 0) {
                          return Container(
                            margin: const EdgeInsets.only(right: 5, left: 5),
                            width: 190,
                            child: MaterialButton(
                                minWidth: double.infinity,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                    side: const BorderSide(
                                        width: 1.5, color: Colors.transparent)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 15),
                                elevation: 0,
                                focusElevation: 0,
                                hoverElevation: 0,
                                highlightElevation: 0,
                                disabledElevation: 0,
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (builder) =>
                                          const AccountForm());
                                },
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.3),
                                        child: const Icon(Icons.add,
                                            color: Colors.white),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("New",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.apply(fontWeightDelta: 2)),
                                          Text(
                                            "Create account",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                )),
                          );
                        }
                        Account account = _accounts[index - 1];
                        return Container(
                            margin: const EdgeInsets.only(right: 5, left: 5),
                            child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minWidth: 0,
                                ),
                                child: IntrinsicWidth(
                                  child: MaterialButton(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.1),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          side: BorderSide(
                                              width: 1.5,
                                              color: _account?.id == account.id
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : Colors.transparent)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 15),
                                      elevation: 0,
                                      focusElevation: 0,
                                      hoverElevation: 0,
                                      highlightElevation: 0,
                                      disabledElevation: 0,
                                      onPressed: () {
                                        setState(() {
                                          _account = account;
                                        });
                                      },
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: account.color
                                                  .withOpacity(0.2),
                                              child: Icon(account.icon,
                                                  color: account.color),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Visibility(
                                                  visible: account
                                                      .holderName.isNotEmpty,
                                                  child: Text(
                                                      account.holderName,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.apply(
                                                              fontWeightDelta:
                                                                  2)),
                                                ),
                                                Text(
                                                  account.name,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      )),
                                )));
                      }),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 15, bottom: 15),
                    child: const Text(
                      "Select Category",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                  Container(
                    margin:
                        const EdgeInsets.only(bottom: 25, left: 15, right: 15),
                    width: double.infinity,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(_categories.length + 1, (index) {
                        if (_categories.length == index) {
                          return ConstrainedBox(
                            constraints: const BoxConstraints(
                              minWidth: 0,
                            ),
                            child: IntrinsicWidth(
                              child: MaterialButton(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  side: const BorderSide(
                                    width: 1.5,
                                    color: Colors.transparent,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 0),
                                elevation: 0,
                                focusElevation: 0,
                                hoverElevation: 0,
                                highlightElevation: 0,
                                disabledElevation: 0,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (builder) => const CategoryForm(),
                                  );
                                },
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.add,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "New Category",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        Category category = _categories[index];
                        return ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 0,
                          ),
                          child: IntrinsicWidth(
                            child: MaterialButton(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                                side: BorderSide(
                                  width: 1.5,
                                  color: _category?.id == category.id
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 0),
                              elevation: 0,
                              focusElevation: 0,
                              hoverElevation: 0,
                              highlightElevation: 0,
                              disabledElevation: 0,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              onPressed: () {
                                setState(() {
                                  _category = category;
                                });
                              },
                              onLongPress: () {
                                showDialog(
                                  context: context,
                                  builder: (builder) =>
                                      CategoryForm(category: category),
                                );
                              },
                              child: SizedBox(
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    Icon(category.icon, color: category.color),
                                    const SizedBox(width: 10),
                                    Text(
                                      category.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  Container(
                    margin:
                        const EdgeInsets.only(left: 15, right: 15, bottom: 25),
                    child: TextFormField(
                      minLines: 2,
                      maxLines: 10,
                      decoration: InputDecoration(
                          filled: true,
                          hintText: "Please enter any description if there.",
                          label: const Text("Description"),
                          border: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 15)),
                      initialValue: _description,
                      onChanged: (text) {
                        setState(() {
                          _description = text;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  if (widget.payment != null)
                    AppButton(
                      height: 50,
                      width: 50,
                      onPressed: () {
                        ConfirmModal.showConfirmDialog(context,
                            title: "Are you sure?",
                            content: const Text(
                                "After deleting payment can't be recovered."),
                            onConfirm: () {
                          _paymentDao.deleteTransaction(_id!).then((value) {
                            globalEvent.emit("payment_update");
                            Navigator.pop(context);
                            Navigator.pop(context);
                          });
                        }, onCancel: () {
                          Navigator.pop(context);
                        });
                      },
                      icon: IconsaxOutline.trash,
                      color: ThemeColors.error,
                      iconSize: 20,
                    ),
                  if (widget.payment != null)
                    const SizedBox(
                      width: 10,
                    ),
                  Expanded(
                      child: AppButton(
                    label: "Save Transaction",
                    height: 50,
                    isFullWidth: true,
                    borderRadius: BorderRadius.circular(100),
                    onPressed:
                        _amount > 0 && _account != null && _category != null
                            ? () {
                                handleSaveTransaction(context);
                              }
                            : null,
                    color: Theme.of(context).colorScheme.primary,
                  )),
                ],
              ),
            )
          ],
        ));
  }
}
