import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:terhal_app/controllers/firebase_auth_controller.dart';
import 'package:terhal_app/controllers/recommendation_controller.dart';
import 'package:terhal_app/controllers/theme_controller.dart';
import 'package:terhal_app/controllers/user_favorite_controller.dart';
import 'package:terhal_app/pages/explore_page/explore_view.dart';
import 'package:terhal_app/pages/favorite_page/favorite_view.dart';
import 'package:terhal_app/pages/profile_page/profile_view.dart';
import 'package:terhal_app/utils/constants.dart';
import 'package:terhal_app/views/home_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuthController authController = Get.find();
  final recommendationController = Get.put(RecommendationController());
  final ThemeController themeController = Get.find();
  Color appBarColor = Colors.transparent;
  Color textColor = const Color.fromRGBO(0, 0, 0, 1);
  IconThemeData iconThemeData =
      const IconThemeData(color: Constants.primaryColor);
  String appBarTitle = "";
  bool hideBottomPreferredSize = false;
  int _selectedIndex = 0;

  void _onItemTapped(int index, AppLocalizations? appLocalizations) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 3) {
      _updateAppBarColors(
        Constants.primaryColor,
        Colors.white,
        const IconThemeData(color: Colors.white),
      );
      _updateAppBarTitle("Edit Profile");
      _hideBottomPreferredSize(true);
    } else {
      _updateAppBarColors(
        Colors.transparent,
        const Color.fromRGBO(0, 0, 0, 1),
        const IconThemeData(color: Constants.primaryColor),
      );
      _updateAppBarTitle(appLocalizations!
          .hello(authController.currentUser!.displayName ?? ""));
      _hideBottomPreferredSize(false);
    }
  }

  void _updateAppBarColors(
      Color backgroundColor, Color txtColor, IconThemeData iconTheme) {
    appBarColor = backgroundColor;
    textColor = txtColor;
    iconThemeData = iconTheme;
  }

  void _updateAppBarTitle(String title) {
    setState(() {
      appBarTitle = title;
    });
  }

  void _hideBottomPreferredSize(bool hide) {
    setState(() {
      hideBottomPreferredSize = hide;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appBarTitle = AppLocalizations.of(context)!
        .hello(authController.currentUser!.displayName ?? "");
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    List<Widget> widgetOptions = [
      HomeView(appLocalizations: appLocalizations),
      ExploreView(
        appLocalizations: appLocalizations,
        userFavoriteController: Get.put(UserFavoriteController()),
      ),
      FavoriteView(
        appLocalizations: appLocalizations,
        userFavoriteController: Get.put(
          UserFavoriteController(),
        ),
      ),
      ProfileView(appLocalizations: appLocalizations),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        iconTheme: iconThemeData,
        elevation: 0,
        centerTitle: true,
        title: GetBuilder<ThemeController>(
          builder: (controller) {
            return Text(
              appBarTitle,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: controller.isDarkMode.value
                        ? Colors.white
                        : Colors.black,
                  ),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () async {
              themeController.isDarkMode.toggle();
              Get.changeTheme(themeController.isDarkMode.value
                  ? ThemeData.dark()
                  : ThemeData.light());
              await themeController.saveThemePreference();
            },
            icon: Obx(
              () => themeController.isDarkMode.value
                  ? const Icon(Icons.dark_mode)
                  : const Icon(Icons.light_mode),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: !hideBottomPreferredSize
              ? Text(appLocalizations!.exploreTheUnknown)
              : const Text(""),
        ),
        bottomOpacity: 0.5,
      ),
      drawer: _buildDrawer(appLocalizations),
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: _buildBottomNavigationBar(appLocalizations),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(
      AppLocalizations? appLocalizations) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          label: appLocalizations!.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.search),
          label: appLocalizations.explore,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.access_time_rounded),
          label: appLocalizations.favorites,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline_rounded),
          label: appLocalizations.profile,
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Constants.primaryColor,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
      elevation: 0,
      onTap: (index) => _onItemTapped(index, appLocalizations),
    );
  }

  Drawer _buildDrawer(AppLocalizations? appLocalizations) {
    final user = authController.currentUser!.displayName ?? '';
    List<String> userNames = user.split(' ');
    String firstLetter = userNames.isNotEmpty && userNames[0].isNotEmpty
        ? userNames[0][0].toUpperCase()
        : '';
    String lastLetter = userNames.length > 1 && userNames.last.isNotEmpty
        ? userNames.last[0].toUpperCase()
        : '';

    return Drawer(
      elevation: 0,
      surfaceTintColor: Colors.red,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Constants.primaryColor,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(120),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.blue,
                    child: Text(
                      "$firstLetter$lastLetter",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: Get.height * 0.01),
                  Text(user, style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
          _buildLogoutDrawer(appLocalizations),
        ],
      ),
    );
  }

  ListTile _buildLogoutDrawer(AppLocalizations? appLocalizations) {
    return ListTile(
      leading: const Icon(Icons.logout),
      title: Text(appLocalizations!.logout),
      onTap: () {
        Get.defaultDialog(
          title: appLocalizations.logout,
          titleStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          middleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          cancelTextColor: Get.isDarkMode ? Colors.white : Colors.black,
          confirmTextColor: Colors.white,
          contentPadding: const EdgeInsets.all(20),
          buttonColor: Colors.red,
          middleText: appLocalizations.logoutConfirmation,
          textConfirm: appLocalizations.yes,
          textCancel: appLocalizations.no,
          onConfirm: () {
            FirebaseAuthController().signOut();
          },
          onCancel: () {
            Get.back();
          },
        );
      },
    );
  }
}
