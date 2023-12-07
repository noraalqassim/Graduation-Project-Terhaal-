import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:terhal_app/controller_bindings.dart';
import 'package:terhal_app/controllers/theme_controller.dart';
import 'package:terhal_app/home.dart';
import 'package:terhal_app/pages/change_password_page/change_password_page.dart';
import 'package:terhal_app/pages/details_page/details_map_page.dart';
import 'package:terhal_app/pages/details_page/details_page.dart';
import 'package:terhal_app/pages/details_page/post_ratings_and_reviews/post_ratings_and_reviews_page.dart';
import 'package:terhal_app/pages/details_page/ratings_and_reviews/ratings_and_reviews_page.dart';
import 'package:terhal_app/pages/explore_page/explore_page.dart';
import 'package:terhal_app/pages/favorite_page/favorite_page.dart';
import 'package:terhal_app/pages/forgot_password_page/forgot_password_page.dart';
import 'package:terhal_app/pages/interest_page/interest_page.dart';
import 'package:terhal_app/pages/profile_page/profile_page.dart';
import 'package:terhal_app/pages/recommendation_page/recommendation_page.dart';
import 'package:terhal_app/pages/signin_page/signin_page.dart';
import 'package:terhal_app/pages/signup_page/signup_page.dart';
import 'package:terhal_app/pages/trending_page/trending_page.dart';
import 'package:terhal_app/theme/app_theme.dart';

import 'firebase_options.dart';
import 'l10n/ln10.dart';

late final FirebaseApp app;
late final FirebaseAuth auth;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  auth = FirebaseAuth.instanceFor(app: app);

  ThemeController themeController = Get.put(ThemeController());
  await themeController.loadThemePreference();

  runApp(TerhalApp(themeController: themeController));
}

class TerhalApp extends StatelessWidget {
  const TerhalApp({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: themeController.isDarkMode.value ? darkThemeData : lightThemeData,
      darkTheme: darkThemeData,
      themeMode: ThemeMode.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      initialBinding: ControllerBindings(),
      supportedLocales: L10n.all,
      home: const AuthGate(),
      getPages: [
        GetPage(
          name: '/home',
          page: () => const HomePage(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/signup',
          page: () => const SignUpPage(),
        ),
        GetPage(
          name: '/signin',
          page: () => const SignInPage(),
        ),
        GetPage(
          name: '/forgot-password',
          page: () => const ForgotPasswordPage(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/recommended',
          page: () => const RecommendationPage(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/interests',
          page: () => const InterestsPage(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/trending',
          page: () => const TrendingPage(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/explore',
          page: () => const ExplorePage(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/favorite',
          page: () => const FavoritePage(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/details',
          page: () => const DetailsPage(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/details-map',
          page: () => const DetailsMapPage(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/profile',
          page: () => const ProfilePage(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/change-password',
          page: () => const ChangePasswordPage(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/ratings-and-reviews',
          page: () => const RatingsAndReviewsPage(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/post-ratings-and-reviews',
          page: () => const PostRatingsAndReviewsPage(),
          transition: Transition.zoom,
        ),
      ],
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return const HomePage();
    } else {
      return const SignInPage();
    }
  }
}
