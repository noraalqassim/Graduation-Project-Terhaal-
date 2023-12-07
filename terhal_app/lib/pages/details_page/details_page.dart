import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:terhal_app/models/recommendation.dart';
import 'package:terhal_app/pages/details_page/details_view.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final recommendation =
        ModalRoute.of(context)!.settings.arguments as Recommendation;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${recommendation.name} Details",
          style: TextStyle(
            color: Get.textTheme.bodyLarge!.color,
          ),
        ),
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
      body: DetailsView(
        appLocalizations: appLocalizations,
        recommendation: recommendation,
      ),
    );
  }
}
