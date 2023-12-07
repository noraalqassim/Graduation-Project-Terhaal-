import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:terhal_app/controllers/interest_controller.dart';
import 'package:terhal_app/form/controls/search.dart';
import 'package:terhal_app/pages/interest_page/interest_view.dart';

class InterestsPage extends StatefulWidget {
  const InterestsPage({super.key});
  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  final interestController = Get.put(InterestController());

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Based on your interests',
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
                  interestController.fetchInterests(params: {"q": value});
                } else if (value == null || value.isEmpty) {
                  interestController.fetchInterests();
                }
              },
            ),
            SizedBox(height: Get.height * 0.01),
            InterestsView(
              appLocalizations: appLocalizations,
              interestController: interestController,
              userFavoriteController: Get.find(),
            ),
          ],
        ),
      ),
    );
  }
}
