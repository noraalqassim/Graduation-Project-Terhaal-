import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:terhal_app/controllers/trending_controller.dart';
import 'package:terhal_app/form/controls/search.dart';
import 'package:terhal_app/pages/trending_page/trending_view.dart';

class TrendingPage extends StatefulWidget {
  const TrendingPage({super.key});
  @override
  State<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
  final trendingController = Get.put(TrendingController());

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trending Places',
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
                  trendingController.fetchTrending(params: {"q": value});
                } else if (value == null || value.isEmpty) {
                  trendingController.fetchTrending();
                }
              },
            ),
            SizedBox(height: Get.height * 0.01),
            TrendingView(
              appLocalizations: appLocalizations,
              trendingController: trendingController,
              userFavoriteController: Get.find(),
            ),
          ],
        ),
      ),
    );
  }
}
