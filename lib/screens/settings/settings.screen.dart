import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:penniverse/helpers/db.helper.dart';
import 'package:penniverse/providers/app_provider.dart';
import 'package:penniverse/widgets/buttons/button.dart';
import 'package:penniverse/widgets/dialog/confirm.modal.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildCurrencyTile(provider, context),
                const Divider(),
                _buildNameTile(provider, context),
                const Divider(),
                _buildResetTile(provider, context),
                const Divider(),
                _buildAboutUsTile(context),
                const Divider(),
                _buildFeedbackTile(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ListTile _buildCurrencyTile(AppProvider provider, BuildContext context) {
    return ListTile(
      title: const Text(
        "Currency",
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      visualDensity: const VisualDensity(vertical: -2),
      subtitle: Selector<AppProvider, String?>(
        selector: (_, provider) => provider.currency,
        builder: (context, state, _) {
          Currency? currency = CurrencyService().findByCode(state);
          return Text(
            currency?.name ?? "",
            style: Theme.of(context).textTheme.bodySmall,
          );
        },
      ),
      onTap: () {
        showCurrencyPicker(
          context: context,
          onSelect: (Currency currency) {
            provider.updateCurrency(currency.code);
          },
        );
      },
    );
  }

  ListTile _buildNameTile(AppProvider provider, BuildContext context) {
    return ListTile(
      title: const Text(
        "Name",
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      visualDensity: const VisualDensity(vertical: -2),
      subtitle: Selector<AppProvider, String?>(
        selector: (_, provider) => provider.username,
        builder: (context, state, _) {
          return Text(
            state ?? "",
            style: Theme.of(context).textTheme.bodySmall,
          );
        },
      ),
      onTap: () => _showEditProfileDialog(context, provider),
    );
  }

  ListTile _buildResetTile(AppProvider provider, BuildContext context) {
    return ListTile(
      title: const Text(
        "Reset",
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      visualDensity: const VisualDensity(vertical: -2),
      subtitle: Text(
        "Delete all the data",
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: () => _showResetConfirmDialog(context, provider),
    );
  }

  ListTile _buildAboutUsTile(BuildContext context) {
    return ListTile(
      title: const Text(
        "About Us",
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      visualDensity: const VisualDensity(vertical: -2),
      onTap: () {
        showAboutDialog(
          context: context,
          applicationName: 'Penniverse',
          applicationVersion: '1.0.0',
          applicationIcon: SizedBox(
            height: 50,
            width: 50,
            child: Image.asset('assets/logo/penniverse_logo.png'),
          ),
          applicationLegalese: '© 2024 Thrive Nexa Tech',
          children: [
            const Text(
              'Penniverse is a finance management app designed to help you organize your expenses, track your budgets, and manage your accounts with ease.',
              softWrap: true,
            ),
          ],
        );
      },
    );
  }

  ListTile _buildFeedbackTile(BuildContext context) {
    return ListTile(
      title: const Text(
        "Feedback",
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      visualDensity: const VisualDensity(vertical: -2),
      subtitle: Text(
        "We'll be glad to hear from you!",
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: () => _showFeedbackOptions(context),
    );
  }

  void _showEditProfileDialog(BuildContext context, AppProvider provider) {
    TextEditingController controller = TextEditingController(text: provider.username);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Edit Profile",
            style: Theme.of(context).textTheme.titleLarge!.apply(fontWeightDelta: 2),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SizedBox(
            width: MediaQuery.of(context).size.width - 60 < 500
                ? MediaQuery.of(context).size.width - 60
                : 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: "What should we call you?",
                    hintText: "Enter your name",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    onPressed: () {
                      if (controller.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter name")),
                        );
                      } else {
                        provider.updateUsername(controller.text);
                        Navigator.of(context).pop();
                      }
                    },
                    label: "Save my profile",
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showResetConfirmDialog(BuildContext context, AppProvider provider) {
    ConfirmModal.showConfirmDialog(
      context,
      title: "Are you sure?",
      content: const Text("After deleting data can't be recovered"),
      onConfirm: () async {
        Navigator.of(context).popUntil((route) => route.isFirst);
        await provider.reset();
        await resetDatabase();
      },
      onCancel: () {
        Navigator.of(context).pop();
      },
    );
  }

  void _showFeedbackOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: const Text('Send Feedback'),
              onTap: () {
                _launchURL();
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Report Bug'),
              onTap: () {
                _launchURL();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _launchURL() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: 'delbarton2@gmail.com',
    );
    String url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not launch email app")),
      );
      debugPrint('Could not launch $url');
    }
  }
}

