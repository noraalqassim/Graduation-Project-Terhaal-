import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terhal_app/models/category/category.dart';

class CategoryItem extends StatelessWidget {
  final Category category;
  final Function onTap;
  final bool selected;

  const CategoryItem({
    super.key,
    required this.category,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget categoryImage;

    if (category.id == 0) {
      categoryImage = Image.asset(category.icon);
    } else {
      categoryImage = CachedNetworkImage(
        imageUrl: category.icon,
      );
    }

    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.blueGrey),
          color: selected
              ? Colors.blueGrey
              : Get.isDarkMode
                  ? Colors.grey[800]
                  : Colors.white,
        ),
        child: Row(
          children: [
            categoryImage,
            const SizedBox(width: 10),
            Text(
              category.name,
              style: selected
                  ? TextStyle(
                      color: Get.isDarkMode ? Colors.white : Colors.grey[800])
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
