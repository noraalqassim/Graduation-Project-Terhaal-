import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:terhal_app/controllers/home_trending_controller.dart';
import 'package:terhal_app/controllers/user_favorite_controller.dart';
import 'package:terhal_app/widgets/empty_data.dart';
import 'package:terhal_app/widgets/loading.dart';
import 'package:terhal_app/widgets/place_item.dart';

class HomeTrendingView extends StatefulWidget {
  const HomeTrendingView({
    super.key,
    required this.appLocalizations,
    required this.trendingController,
    required this.userFavoriteController,
  });
  final AppLocalizations? appLocalizations;
  final HomeTrendingController trendingController;
  final UserFavoriteController userFavoriteController;

  @override
  State<HomeTrendingView> createState() => _HomeTrendingViewState();
}

class _HomeTrendingViewState extends State<HomeTrendingView> {
  @override
  void initState() {
    super.initState();
    widget.trendingController.fetchTrending();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => widget.trendingController.isLoading.value
          ? Loading.circle
          : widget.trendingController.trending.isEmpty
              ? EmptyData(
                  text: widget.appLocalizations!.emptyData('Trending'),
                  onRefresh: () async {
                    await widget.trendingController.fetchTrending();
                  },
                )
              : _buildGrideView(),
    );
  }

  RefreshIndicator _buildGrideView() {
    return RefreshIndicator(
      onRefresh: () async {
        await widget.trendingController.fetchTrending();
      },
      child: AnimationLimiter(
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            childAspectRatio: 1 / 0.8,
          ),
          itemCount: widget.trendingController.trending.length,
          itemBuilder: (context, index) {
            final recommendation = widget.trendingController.trending[index];
            final isInFavorites = widget
                    .userFavoriteController.userFavorite.value?.favorites
                    .contains(recommendation.id) ??
                widget.userFavoriteController.userFavorites
                    .any((favorite) => favorite.id == recommendation.id);
            return AnimationConfiguration.staggeredGrid(
              columnCount: widget.trendingController.trending.length,
              position: index,
              duration: const Duration(milliseconds: 375),
              child: ScaleAnimation(
                scale: 0.5,
                child: FadeInAnimation(
                  child: PlaceItem(
                    recommendation: recommendation,
                    onFavoriteTap: () {
                      widget.userFavoriteController.toggleFavorite(
                        widget.trendingController.trending[index].id,
                      );
                      widget.trendingController.fetchTrending();
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
