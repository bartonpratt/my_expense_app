import 'dart:ui';

import 'package:currency_picker/currency_picker.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:penniverse/helpers/db.helper.dart';
import 'package:penniverse/providers/app_provider.dart';
import 'package:penniverse/widgets/buttons/button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<StatefulWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final CurrencyService currencyService = CurrencyService();
  String _username = "";
  Currency? _currency;

  @override
  void initState() {
    super.initState();
    _currency = currencyService.findByCode("USD");
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppProvider provider = Provider.of<AppProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Transparent background
          Positioned.fill(
            child: Image.asset(
              'assets/images/bgImg.jpg', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                height: 100,
                width: 100,
                child: Image.asset("assets/logo/penniverse_logo.png"),
              ),
            ),
          ),
          // Card with content
          SafeArea(
            child: Center(
              child: Card(
                color: Colors.black.withOpacity(0.5),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                margin:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Heyy! \nWelcome to Penniverse",
                        style: theme.textTheme.headlineMedium!.apply(
                            color: theme.primaryColor, fontWeightDelta: 2),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Please enter all details to continue.",
                        style: theme.textTheme.bodyLarge!.apply(
                          color: Colors.white,
                          fontWeightDelta: 1,
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        onChanged: (String username) {
                          setState(() {
                            _username = username;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          border: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          prefixIcon: const Icon(IconsaxOutline.profile_circle),
                          hintText: "Enter your name",
                          labelText: "What should we call you?",
                        ),
                      ),
                      const SizedBox(height: 40),
                      Autocomplete<Currency>(
                        initialValue: TextEditingValue(
                          text: _currency != null
                              ? "(${_currency?.code}) ${_currency?.name}"
                              : "",
                        ),
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            return const Iterable<Currency>.empty();
                          }
                          return currencyService
                              .getAll()
                              .where((Currency option) {
                            String keyword =
                            textEditingValue.text.toLowerCase();
                            return option.name
                                .toLowerCase()
                                .contains(keyword) ||
                                option.code.toLowerCase().contains(keyword);
                          });
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              filled: true,
                              border: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              prefixIcon:
                              const Icon(IconsaxOutline.dollar_circle),
                              hintText: "Select your currency",
                              labelText: "Default currency?",
                            ),
                          );
                        },
                        displayStringForOption: (selection) =>
                        "(${selection.code}) ${selection.name}",
                        onSelected: (Currency selection) {
                          setState(() {
                            _currency = selection;
                          });
                        },
                      ),
                      const SizedBox(height: 40),
                      AppButton(
                        borderRadius: BorderRadius.circular(100),
                        label: "Continue",
                        color: theme.primaryColor,
                        isFullWidth: true,
                        size: AppButtonSize.large,
                        onPressed: () async {
                          if (_username.isEmpty || _currency == null) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please fill all the details"),
                                ),
                              );
                            }
                          } else {
                            await resetDatabase();
                            await provider.reset();
                            provider
                                .update(
                              username: _username,
                              currency: _currency!.code,
                            )
                                .then((value) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Setup completed"),
                                  ),
                                );
                              }
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
