import 'package:flutter/material.dart';
import 'package:terhal_app/models/recommendation.dart';
import 'package:terhal_app/pages/details_page/details_map_view.dart';

class DetailsMapPage extends StatefulWidget {
  const DetailsMapPage({super.key});

  @override
  State<DetailsMapPage> createState() => _DetailsMapPageState();
}

class _DetailsMapPageState extends State<DetailsMapPage> {
  @override
  Widget build(BuildContext context) {
    final recommendation =
        ModalRoute.of(context)!.settings.arguments as Recommendation;

    return Scaffold(
      body: SafeArea(
        child: DetailsMapView(recommendation: recommendation),
      ),
    );
  }
}
