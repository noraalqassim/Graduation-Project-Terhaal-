import 'package:json_annotation/json_annotation.dart';

part 'place_image.g.dart';

@JsonSerializable()
class PlaceImage {
  final String image;
  final bool primary;

  PlaceImage({required this.image, required this.primary});

  factory PlaceImage.fromJson(Map<String, dynamic> json) {
    return _$PlaceImageFromJson(json);
  }
}
