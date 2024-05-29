import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/logo/penniverse_logo.png', // Make sure to add your logo to the assets folder
                height: 70,
                width: 70,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Privacy Policy for Penniverse',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Introduction',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Welcome to Penniverse. Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your information when you use our app.',
            ),
            const SizedBox(height: 10),
            const Text(
              'Information Collection',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Our app collects the following types of information:',
            ),
            const Text(
              '1. Personal Information: This includes your name and the transactions you make. This information is stored locally on your device.',
            ),
            const Text(
              '2. Account Details: Any account details you input are masked and stored locally. We do not store or collect any personal financial information that can identify you outside of the app.',
            ),
            const SizedBox(height: 10),
            const Text(
              'Use of Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'The information collected by Penniverse is used solely for the purpose of providing you with the service. Specifically, your transaction history and personal settings are used to help you manage your expenses effectively.',
            ),
            const SizedBox(height: 10),
            const Text(
              'Data Storage',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'All the data you enter into the app is stored locally on your device using the SQLite database provided by the sqflite package. We do not transfer, store, or share your data on any external servers or with any third parties.',
            ),
            const SizedBox(height: 10),
            const Text(
              'Security',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'We take reasonable measures to protect the information you provide through the app. This includes using secure coding practices and regularly updating the app to fix potential security vulnerabilities. However, please note that no method of electronic storage is 100% secure and we cannot guarantee absolute security.',
            ),
            const SizedBox(height: 10),
            const Text(
              'Sharing of Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Penniverse does not share your personal information with any third parties. All data remains on your device and is not accessible to anyone else unless you explicitly share it.',
            ),
            const SizedBox(height: 10),
            const Text(
              'User Rights',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'As a user of Penniverse, you have the following rights:',
            ),
            const Text(
              'Access: You can access your data at any time through the app.',
            ),
            const Text(
              'Correction: You can correct any inaccuracies in your data directly through the app.',
            ),
            const Text(
              'Deletion: You can delete your data at any time by uninstalling the app. This will remove all local data stored on your device.',
            ),
            const SizedBox(height: 10),
            const Text(
              'Changes to this Privacy Policy',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page. It is advised to review this Privacy Policy periodically for any changes.',
            ),
            const SizedBox(height: 10),
            const Text(
              'Contact Us',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'If you have any questions about this Privacy Policy, please contact us at:',
            ),
            const Text(
              'Email: support@penniverse.com',
            ),
            const SizedBox(height: 10),
            const Text(
              'Thank you for using Penniverse. We are committed to protecting your privacy and providing a secure and efficient expense management experience.',
            ),
            const SizedBox(height: 10),
            const Text(
              'Last updated: 5/29/2024',
            ),
          ],
        ),
      ),
    );
  }
}
