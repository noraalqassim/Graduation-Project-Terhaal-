import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:terhal_app/controllers/home_interest_controller.dart';
import 'package:terhal_app/controllers/user_favorite_controller.dart';
import 'package:terhal_app/widgets/empty_data.dart';
import 'package:terhal_app/widgets/loading.dart';
import 'package:terhal_app/widgets/place_item.dart';

class HomeInterestView extends StatefulWidget {
  const HomeInterestView({
    super.key,
    required this.appLocalizations,
    required this.interestController,
    required this.userFavoriteController,
  });

  final AppLocalizations? appLocalizations;
  final HomeInterestController interestController;
  final UserFavoriteController userFavoriteController;

  @override
  State<HomeInterestView> createState() => _HomeInterestViewState();
}

class _HomeInterestViewState extends State<HomeInterestView> {
  @override
  void initState() {
    super.initState();
    widget.interestController.fetchInterests();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => widget.interestController.isLoading.value
          ? Loading.circle
          : widget.interestController.interests.isEmpty
              ? EmptyData(
                  text: widget.appLocalizations!.emptyData('Interest'),
                  onRefresh: () async {
                    await widget.interestController.fetchInterests();
                  },
                )
              : _buildGridView(),
    );
  }

  RefreshIndicator _buildGridView() {
    return RefreshIndicator(
      onRefresh: () async {
        await widget.interestController.fetchInterests();
      },
      child: AnimationLimiter(
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            childAspectRatio: 1 / 0.8,
          ),
          itemCount: widget.interestController.interests.length,
          itemBuilder: (context, index) {
            final recommendation = widget.interestController.interests[index];
            final isInFavorites = widget
                    .userFavoriteController.userFavorite.value?.favorites
                    .contains(recommendation.id) ??
                widget.userFavoriteController.userFavorites
                    .any((favorite) => favorite.id == recommendation.id);
            return AnimationConfiguration.staggeredGrid(
              columnCount: widget.interestController.interests.length,
              position: index,
              duration: const Duration(milliseconds: 375),
              child: ScaleAnimation(
                scale: 0.5,
                child: FadeInAnimation(
                  child: PlaceItem(
                    recommendation: recommendation,
                    onFavoriteTap: () {
                      widget.userFavoriteController.toggleFavorite(
                        widget.interestController.interests[index].id,
                      );
                      widget.interestController.fetchInterests();
                    },
                    isInFavorites: isInFavorites,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
