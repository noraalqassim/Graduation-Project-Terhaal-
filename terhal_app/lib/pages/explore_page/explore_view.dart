import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:terhal_app/controllers/category_controller.dart';
import 'package:terhal_app/controllers/explore_controller.dart';
import 'package:terhal_app/controllers/user_favorite_controller.dart';
import 'package:terhal_app/models/category/category.dart';
import 'package:terhal_app/utils/image_constant.dart';
import 'package:terhal_app/widgets/category_item.dart';
import 'package:terhal_app/widgets/empty_data.dart';
import 'package:terhal_app/widgets/explore_item.dart';
import 'package:terhal_app/widgets/loading.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({
    super.key,
    required this.appLocalizations,
    required this.userFavoriteController,
  });

  final AppLocalizations? appLocalizations;
  final UserFavoriteController userFavoriteController;

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  late Category selectedCategory;
  final categoryController = Get.put(CategoryController());
  final exploreController = Get.put(ExploreController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    selectedCategory = Category(
      id: 0,
      code: 'all',
      name: 'All',
      icon: Images.all,
    );
    exploreController.fetchExplores();
    categoryController.fetchCategories();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !exploreController.isLoading.value) {
      if (exploreController.next.isNotEmpty) {
        exploreController.fetchMoreExplores(exploreController.next.value);
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
            _buildCategoriesWidget(),
            SizedBox(height: Get.height * 0.02),
            _buildExploreWidget(),
          ],
        ),
      ),
    );
  }

  Expanded _buildExploreWidget() {
    return Expanded(
      child: exploreController.isLoading.value
          ? Loading.circle
          : exploreController.explores.isEmpty
              ? Center(
                  child: EmptyData(
                    text: widget.appLocalizations!.emptyData('Explore'),
                  ),
                )
              : _buildExploreListView(),
    );
  }

  Widget _buildExploreListView() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          if (_scrollController.position.extentAfter == 0) {
            if (exploreController.next.isNotEmpty) {
              exploreController.fetchMoreExplores(exploreController.next.value);
            }
          }
        }
        return true;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          await exploreController.fetchExplores();
        },
        child: AnimationLimiter(
          child: ListView.separated(
            controller: _scrollController,
            itemCount: exploreController.explores.length,
            separatorBuilder: (context, index) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(),
            ),
            itemBuilder: (context, index) {
              final recommendation = exploreController.explores[index];
              final isInFavorites = widget
                      .userFavoriteController.userFavorite.value?.favorites
                      .contains(recommendation.id) ??
                  widget.userFavoriteController.userFavorites
                      .any((favorite) => favorite.id == recommendation.id);
              return AnimationConfiguration.staggeredGrid(
                columnCount: exploreController.explores.length,
                position: index,
                duration: const Duration(milliseconds: 375),
                child: ScaleAnimation(
                  scale: 0.5,
                  child: FadeInAnimation(
                    child: ExploreItem(
                      recommendation: recommendation,
                      onFavoriteTap: () {
                        widget.userFavoriteController.toggleFavorite(
                          recommendation.id,
                        );
                        exploreController.fetchExplores();
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

  SizedBox _buildCategoriesWidget() {
    return SizedBox(
      height: 50,
      child: AnimationLimiter(
        child: categoryController.isLoading.value
            ? Loading.circle
            : categoryController.categories.isEmpty
                ? const Center(
                    child: Text(
                      'No categories available',
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                  )
                : _buildCategoryListView(),
      ),
    );
  }

  ListView _buildCategoryListView() {
    List<Category> categories = [
      Category(id: 0, code: 'all', name: 'All', icon: Images.all),
      ...categoryController.categories
    ];
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      shrinkWrap: true,
      separatorBuilder: (context, index) => const SizedBox(width: 5),
      itemBuilder: (context, index) {
        final category = categories[index];
        return AnimationConfiguration.staggeredGrid(
          columnCount: categories.length,
          position: index,
          duration: const Duration(milliseconds: 375),
          child: ScaleAnimation(
            scale: 0.5,
            child: FadeInAnimation(
              child: CategoryItem(
                category: category,
                onTap: () {
                  selectedCategory = category;
                  exploreController.fetchExplores(
                      params: {'category': category.id.toString()});
                  setState(() {});
                },
                selected: selectedCategory.id == category.id,
              ),
            ),
          ),
        );
      },
    );
  }
}
