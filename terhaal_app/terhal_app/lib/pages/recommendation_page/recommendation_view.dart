import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:terhal_app/controllers/recommendation_controller.dart';
import 'package:terhal_app/controllers/user_favorite_controller.dart';
import 'package:terhal_app/widgets/empty_data.dart';
import 'package:terhal_app/widgets/loading.dart';
import 'package:terhal_app/widgets/place_item.dart';

class RecommendationView extends StatefulWidget {
  const RecommendationView({
    super.key,
    required this.appLocalizations,
    required this.recommendationController,
    required this.userFavoriteController,
  });

  final AppLocalizations? appLocalizations;
  final RecommendationController recommendationController;
  final UserFavoriteController userFavoriteController;

  @override
  State<RecommendationView> createState() => _RecommendationViewState();
}

class _RecommendationViewState extends State<RecommendationView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    widget.recommendationController.fetchRecommendations();
  }

  _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !widget.recommendationController.isLoading.value) {
      if (widget.recommendationController.next.isNotEmpty) {
        widget.recommendationController.fetchMoreRecommendations(
            widget.recommendationController.next.value);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Expanded(
        child: widget.recommendationController.isLoading.value
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
      ),
    );
  }

  Widget _buildGridView() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          if (_scrollController.position.extentAfter == 0) {
            if (widget.recommendationController.next.isNotEmpty) {
              widget.recommendationController.fetchMoreRecommendations(
                widget.recommendationController.next.value,
              );
            }
          }
        }
        return true;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          await widget.recommendationController.fetchRecommendations();
        },
        child: AnimationLimiter(
          child: GridView.builder(
            controller: _scrollController,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              childAspectRatio: 1 / 0.8,
            ),
            physics: const AlwaysScrollableScrollPhysics(),
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
                          recommendation.id,
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
      ),
    );
  }
}
