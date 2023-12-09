import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:terhal_app/controllers/interest_controller.dart';
import 'package:terhal_app/controllers/user_favorite_controller.dart';
import 'package:terhal_app/widgets/empty_data.dart';
import 'package:terhal_app/widgets/loading.dart';
import 'package:terhal_app/widgets/place_item.dart';

class InterestsView extends StatefulWidget {
  const InterestsView({
    super.key,
    required this.appLocalizations,
    required this.interestController,
    required this.userFavoriteController,
  });

  final AppLocalizations? appLocalizations;
  final InterestController interestController;
  final UserFavoriteController userFavoriteController;

  @override
  State<InterestsView> createState() => _InterestsViewState();
}

class _InterestsViewState extends State<InterestsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    widget.interestController.fetchInterests();
  }

  _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !widget.interestController.isLoading.value) {
      if (widget.interestController.next.isNotEmpty) {
        widget.interestController
            .fetchMoreInterests(widget.interestController.next.value);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Expanded(
        child: widget.interestController.isLoading.value
            ? Loading.circle
            : widget.interestController.interests.isEmpty
                ? EmptyData(
                    text: widget.appLocalizations!.emptyData('Your interests'),
                    onRefresh: () async {
                      await widget.interestController.fetchInterests();
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
            if (widget.interestController.next.isNotEmpty) {
              widget.interestController.fetchMoreInterests(
                widget.interestController.next.value,
              );
            }
          }
        }
        return true;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          await widget.interestController.fetchInterests();
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
                          recommendation.id,
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
      ),
    );
  }
}
