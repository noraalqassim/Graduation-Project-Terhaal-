import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:terhal_app/controllers/trending_controller.dart';
import 'package:terhal_app/controllers/user_favorite_controller.dart';
import 'package:terhal_app/widgets/empty_data.dart';
import 'package:terhal_app/widgets/loading.dart';
import 'package:terhal_app/widgets/place_item.dart';

class TrendingView extends StatefulWidget {
  const TrendingView({
    super.key,
    required this.appLocalizations,
    required this.trendingController,
    required this.userFavoriteController,
  });
  final AppLocalizations? appLocalizations;
  final TrendingController trendingController;
  final UserFavoriteController userFavoriteController;

  @override
  State<TrendingView> createState() => _TrendingViewState();
}

class _TrendingViewState extends State<TrendingView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    widget.trendingController.fetchTrending();
  }

  _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !widget.trendingController.isLoading.value) {
      if (widget.trendingController.next.isNotEmpty) {
        widget.trendingController
            .fetchMoreTrending(widget.trendingController.next.value);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Expanded(
        child: widget.trendingController.isLoading.value
            ? Loading.circle
            : widget.trendingController.trending.isEmpty
                ? EmptyData(
                    text: widget.appLocalizations!.emptyData('Trending'),
                    onRefresh: () async {
                      await widget.trendingController.fetchTrending();
                    },
                  )
                : _buildGrideView(),
      ),
    );
  }

  Widget _buildGrideView() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          if (_scrollController.position.extentAfter == 0) {
            if (widget.trendingController.next.isNotEmpty) {
              widget.trendingController.fetchMoreTrending(
                widget.trendingController.next.value,
              );
            }
          }
        }
        return true;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          await widget.trendingController.fetchTrending();
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
      ),
    );
  }
}
