import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:terhal_app/controllers/home_recommendation_controller.dart';
import 'package:terhal_app/controllers/user_favorite_controller.dart';
import 'package:terhal_app/widgets/empty_data.dart';
import 'package:terhal_app/widgets/loading.dart';
import 'package:terhal_app/widgets/place_item.dart';

class HomeRecommendationView extends StatefulWidget {
  const HomeRecommendationView({
    super.key,
    required this.appLocalizations,
    required this.recommendationController,
    required this.userFavoriteController,
  });

  final AppLocalizations? appLocalizations;
  final HomeRecommendationController recommendationController;
  final UserFavoriteController userFavoriteController;

  @override
  State<HomeRecommendationView> createState() => _HomeRecommendationViewState();
}

class _HomeRecommendationViewState extends State<HomeRecommendationView> {
  @override
  void initState() {
    super.initState();
    widget.recommendationController.fetchRecommendations();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => widget.recommendationController.isLoading.value
          ? Loading.circle
          : widget.recommendationController.recommendations.isEmpty
              ? EmptyData(
                  text: widget.appLocalizations!.emptyData('Recommendation'),
                  onRefresh: () async {
                    await widget.recommendationController
                        .fetchRecommendations();
                  },
                )
              : _buildGridView(),
    );
  }

  RefreshIndicator _buildGridView() {
    return RefreshIndicator(
      onRefresh: () async {
        await widget.recommendationController.fetchRecommendations();
      },
      child: AnimationLimiter(
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            childAspectRatio: 1 / 0.8,
          ),
          itemCount: widget.recommendationController.recommendations.length,
          itemBuilder: (context, index) {
            final recommendation =
                widget.recommendationController.recommendations[index];
            final isInFavorites = widget
                    .userFavoriteController.userFavorite.value?.favorites
                    .contains(recommendation.id) ??
                widget.userFavoriteController.userFavorites
                    .any((favorite) => favorite.id == recommendation.id);
            return AnimationConfiguration.staggeredGrid(
              columnCount:
                  widget.recommendationController.recommendations.length,
              position: index,
              duration: const Duration(milliseconds: 375),
              child: ScaleAnimation(
                scale: 0.5,
                child: FadeInAnimation(
                  child: PlaceItem(
                    recommendation: recommendation,
                    onFavoriteTap: () {
                      widget.userFavoriteController.toggleFavorite(
                        widget
                            .recommendationController.recommendations[index].id,
                      );
                      widget.recommendationController.fetchRecommendations();
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
