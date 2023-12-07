import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:terhal_app/controllers/user_favorite_controller.dart';
import 'package:terhal_app/widgets/empty_data.dart';
import 'package:terhal_app/widgets/favorite_item.dart';
import 'package:terhal_app/widgets/loading.dart';

class FavoriteView extends StatefulWidget {
  const FavoriteView({
    super.key,
    required this.appLocalizations,
    required this.userFavoriteController,
  });

  final AppLocalizations? appLocalizations;
  final UserFavoriteController userFavoriteController;

  @override
  State<FavoriteView> createState() => _FavoriteViewState();
}

class _FavoriteViewState extends State<FavoriteView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    Get.find<UserFavoriteController>().fetchUserFavorites();
  }

  _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !widget.userFavoriteController.isLoading.value) {
      if (widget.userFavoriteController.next.isNotEmpty) {
        widget.userFavoriteController
            .fetchMoreUserFavorites(widget.userFavoriteController.next.value);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Get.height * 0.02),
            _buildFavoriteWidget(),
          ],
        ),
      ),
    );
  }

  Expanded _buildFavoriteWidget() {
    return Expanded(
      child: widget.userFavoriteController.isLoading.value
          ? Loading.circle
          : widget.userFavoriteController.userFavorites.isEmpty
              ? Center(
                  child: EmptyData(
                    text: widget.appLocalizations!.emptyData('User Favorites'),
                    onRefresh: () =>
                        widget.userFavoriteController.fetchUserFavorites(),
                  ),
                )
              : _buildFavoriteListView(),
    );
  }

  Widget _buildFavoriteListView() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          if (_scrollController.position.extentAfter == 0) {
            if (widget.userFavoriteController.next.isNotEmpty) {
              widget.userFavoriteController.fetchMoreUserFavorites(
                widget.userFavoriteController.next.value,
              );
            }
          }
        }
        return true;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          await widget.userFavoriteController.fetchUserFavorites();
        },
        child: AnimationLimiter(
          child: ListView.separated(
            controller: _scrollController,
            itemCount: widget.userFavoriteController.userFavorites.length,
            separatorBuilder: (context, index) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(),
            ),
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredGrid(
                columnCount: widget.userFavoriteController.userFavorites.length,
                position: index,
                duration: const Duration(milliseconds: 375),
                child: ScaleAnimation(
                  scale: 0.5,
                  child: FadeInAnimation(
                    child: FavoriteItem(
                      recommendation:
                          widget.userFavoriteController.userFavorites[index],
                      onFavoriteTap: () {
                        widget.userFavoriteController.toggleFavorite(
                          widget.userFavoriteController.userFavorites[index].id,
                        );
                      },
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
