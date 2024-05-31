import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:penniverse/exports.dart';

class PDFGenerator {
  final PaymentDao _paymentDao = PaymentDao();
  final AccountDao _accountDao = AccountDao();
  late List<Payment> _payments;
  late List<Account> _accounts;
  late double _income;
  late double _expense;
  late String _currencySymbol;
  late BuildContext _context;

  PDFGenerator(this._context);

  Future<void> generatePDF(String username, DateTimeRange dateRange) async {
    try {
      await _fetchData(dateRange);
      final dateFormat = DateFormat("yyyy-MM-dd hh:mma");
      final ByteData logoImage =
      await rootBundle.load('assets/logo/penniverse_logo.png');
      final Uint8List logoImageUint8List = logoImage.buffer.asUint8List();
      final pw.MemoryImage logo = pw.MemoryImage(logoImageUint8List);
      final ByteData signatureImage =
      await rootBundle.load('assets/images/signature.png');
      final Uint8List signatureImageUint8List =
      signatureImage.buffer.asUint8List();
      final pw.MemoryImage signature = pw.MemoryImage(signatureImageUint8List);

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
          build: (context) =>
              _buildPdfContent(username, dateRange, dateFormat),
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      debugPrint('Error generating PDF: $e');
    }
  }

  Future<void> _fetchData(DateTimeRange dateRange) async {
    try{
    _payments = await _paymentDao.find(range: dateRange);
    _accounts = await _accountDao.find(withSummary: true);
    _income = _payments
        .where((payment) => payment.type == PaymentType.credit)
        .fold(0, (sum, payment) => sum + payment.amount);
    _expense = _payments
        .where((payment) => payment.type == PaymentType.debit)
        .fold(0, (sum, payment) => sum + payment.amount);
    _currencySymbol =
    Provider.of<AppProvider>(_context, listen: false).currency!;
  }catch (e) {
      debugPrint('Error fetching date range: $e');

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
          pw.SizedBox(height: 10),
          pw.Image(signature, width: 100, height: 50),
        ],
      ),
    );
  }

  List<pw.Widget> _buildPdfContent(
      String username, DateTimeRange dateRange, DateFormat dateFormat) {
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
          pw.Text("General Accounts:",
              style:
              pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellHeight: 30,
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {0: pw.Alignment.centerLeft},
            cellPadding: const pw.EdgeInsets.all(5),
            headers: [
              'Name',
              'Holder',
              'Account Number',
              'Balance ($_currencySymbol)',
              'Income ($_currencySymbol)',
              'Expense ($_currencySymbol)'
            ],
            data: _accounts
                .map((account) => [
              account.name,
              account.holderName,
              account.accountNumber,
              '${account.balance ?? 0}',
              '${account.income ?? 0}',
              '${account.expense ?? 0}',
            ])
                .toList(),
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
            border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.black, width: 1.0)),
          ),
        ),
      ),
      pw.SizedBox(height: 16),
      pw.Text("Total Income ($_currencySymbol): ${(_income.toString())}"),
      pw.Text("Total Expenses ($_currencySymbol): ${_expense.toString()}"),
      pw.TableHelper.fromTextArray(
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
        cellHeight: 30,
        cellAlignment: pw.Alignment.centerLeft,
        cellAlignments: {0: pw.Alignment.centerLeft},
        cellPadding: const pw.EdgeInsets.all(5),
        headers: ['Date', 'Category', 'Amount ($_currencySymbol)', 'Type'],
        data: _payments
            .map((payment) => [
          dateFormat
              .format(payment.datetime)
              .replaceFirst('AM', 'am')
              .replaceFirst('PM', 'pm'),
          payment.category.name,
          payment.amount.toString(),
          payment.type == PaymentType.credit ? 'CR' : 'DR',
        ])
            .toList(),
      ),
    ];
  }
}
