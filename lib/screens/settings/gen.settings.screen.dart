import 'package:penniverse/exports.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final String title;
  late String subtitle;
  bool isSwitched = false;
  bool isSwitched1 = false;

  @override
  Widget build(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Settings"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20.0,
        ),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.logout_sharp),
              onPressed: () {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (builder) => AlertDialog(
                          title: const Text("Log Out"),
                          content: const Text("Do you want to log out?"),
                          actions: [
                            TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                },
                                child: const Text("Yes")),
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("NO")),
                          ],
                        ));

              })
        ],
      ),
      body: SettingsList(
        sections: [
          SettingsSection(title: const Text('ChatBot'),
              tiles: [
                SettingsTile(
                  title: const Text('Penni Bot AI'),
                  leading: const Icon(Icons.reddit_rounded),
                  onPressed: (BuildContext context) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PenniBot(title: 'Penni Bot AI')));
                  },
                ),
          ]),
          SettingsSection(title: const Text('Trans.'),
              tiles: [
                SettingsTile(
                  title: const Text('Categories'),
                  leading: const Icon(IconsaxBold.category),
                  onPressed: (BuildContext context) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CategoriesScreen()));
                  },
                ),
          ]),

          SettingsSection(
            title: const Text('Gen. Settings'),
            tiles: [
              SettingsTile(
                title: const Text('Currency'),
                value: Selector<AppProvider, String?>(
                  selector: (_, provider) => provider.currency,
                  builder: (context, state, _) {
                    Currency? currency = CurrencyService().findByCode(state);
                    return Text(
                      currency?.name ?? "",
                      style: Theme.of(context).textTheme.bodySmall,
                    );
                  },
                ),
                leading: Selector<AppProvider, String?>(
                  selector: (_, provider) => provider.currency,
                  builder: (context, state, _) {
                    Currency? currency = CurrencyService().findByCode(state);
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        currency?.symbol ?? "",
                        style: const TextStyle(
                            fontSize: 20), // Customize the font size as needed
                      ),
                    );
                  },
                ),
                onPressed: (BuildContext context) {
                  showCurrencyPicker(
                      context: context,
                      onSelect: (Currency currency) {
                        provider.updateCurrency(currency.code);
                      });
                },
              ),
              SettingsTile(
                title: const Text('Name'),
                value: Selector<AppProvider, String?>(
                  selector: (_, provider) => provider.username,
                  builder: (context, state, _) {
                    return Text(
                      state ?? "",
                      style: Theme.of(context).textTheme.bodySmall,
                    );
                  },
                ),
                leading: const Icon(Icons.account_circle),
                onPressed: (BuildContext context) {
                  _showEditProfileDialog(context, provider);
                },
              ),
              SettingsTile(
                title: const Text('Style'),
                leading: const Icon(Icons.color_lens),
                onPressed: (BuildContext context) {
                },
              ),
              SettingsTile(
                title: const Text('Reset'),
                value: Text(
                  "Delete all the data",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                leading: const Icon(IconsaxBold.danger),
                onPressed: (BuildContext context) {
                  _showResetConfirmDialog(context, provider);
                },
              ),
              SettingsTile(
                title: const Text('Feedback'),
                value: Text(
                    "Get in touch with us!",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                leading: const Icon(IconsaxBold.message),
                onPressed: (BuildContext context) {
                  _showFeedbackOptions(context);
                },
              ),
              SettingsTile(
                title: const Text('Privacy Policy'),
                leading: const Icon(Icons.privacy_tip),
                onPressed: (BuildContext context) {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PrivacyPolicyPage()));
                },
              ),
              SettingsTile(
                title: const Text('About Us'),
                leading: const Icon(IconsaxBold.information),
                onPressed: (BuildContext context) {
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AppProvider provider) {
    TextEditingController controller =
        TextEditingController(text: provider.username);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Edit Profile",
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .apply(fontWeightDelta: 2),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
      path: 'bartonpratt@gmail.com',
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
