import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:terhal_app/controllers/user_favorite_controller.dart';
import 'package:terhal_app/pages/favorite_page/favorite_view.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});
  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final UserFavoriteController userFavoriteController = Get.find();

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite'),
      ),
      body: FavoriteView(
        appLocalizations: appLocalizations,
        userFavoriteController: userFavoriteController,
      ),
    );
  }
}
