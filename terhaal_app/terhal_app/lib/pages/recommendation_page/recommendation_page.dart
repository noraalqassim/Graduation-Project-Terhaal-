import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:terhal_app/controllers/recommendation_controller.dart';
import 'package:terhal_app/form/controls/search.dart';
import 'package:terhal_app/pages/recommendation_page/recommendation_view.dart';

class RecommendationPage extends StatefulWidget {
  const RecommendationPage({super.key});
  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  final recommendationController = Get.put(RecommendationController());

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recommended Places',
          style: TextStyle(
            color: Get.textTheme.bodyLarge!.color,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Get.isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
        child: Column(
          children: [
            Search(
              name: 'search',
              hintText: appLocalizations!.findsThingsToDo,
              color: Colors.white,
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.black45,
                size: 25,
              ),
              onChanged: (value) {
                if (value != null && value.length > 3) {
                  recommendationController.fetchRecommendations(params: {"q": value});
                } else if (value == null || value.isEmpty) {
                  recommendationController.fetchRecommendations();
                }
              },
            ),
            SizedBox(height: Get.height * 0.01),
            RecommendationView(
              appLocalizations: appLocalizations,
              recommendationController: recommendationController,
              userFavoriteController: Get.find(),
            ),
          ],
        ),
      ),
    );
  }
}
