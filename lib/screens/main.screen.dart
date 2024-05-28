import 'package:penniverse/exports.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:penniverse/screens/home/home.screen.dart';
import 'package:penniverse/screens/settings/gen.settings.screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selected = 0;

  final List<IconData> iconList = [
    IconsaxOutline.home,
    Icons.payment_outlined,
    IconsaxOutline.wallet,
    IconsaxOutline.more,
  ];

  final List<IconData> selectedIconList = [
    IconsaxBold.home,
    Icons.payment,
    IconsaxBold.wallet_money,
    IconsaxBold.more,
  ];

  final List<String> navigationLabels = [
    "Home",
    "Payments",
    "Accounts",
    "More",
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (provider.currency == null || provider.username == null) {
          return OnboardScreen();
        }
        return Scaffold(
          body: IndexedStack(
            index: _selected,
            children: const <Widget>[
              HomeScreen(),
              PaymentsScreen(),
              AccountsScreen(),
              SettingsPage(),
            ],
          ),
          bottomNavigationBar: AnimatedBottomNavigationBar.builder(
            itemCount: iconList.length,
            tabBuilder: (int index, bool isActive) {
              final color = isActive
                  ? Theme.of(context).colorScheme.inversePrimary
                  : Theme.of(context).dividerColor;
              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isActive ? selectedIconList[index] : iconList[index],
                    color: color,
                    size: 24,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    navigationLabels[index],
                    style: Theme.of(context).textTheme.labelSmall?.apply(
                          color: color,
                        ),
                  )
                ],
              );
            },
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white.withOpacity(0.5),
            activeIndex: _selected,
            splashColor: Theme.of(context).colorScheme.inversePrimary,
            notchSmoothness: NotchSmoothness.softEdge,
            gapLocation: GapLocation.none,
            leftCornerRadius: 32,
            rightCornerRadius: 32,
            onTap: (index) => setState(() => _selected = index),
          ),
        );
      },
    );
  }
}
