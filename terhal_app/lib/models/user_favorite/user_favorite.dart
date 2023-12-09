import 'package:json_annotation/json_annotation.dart';

part 'user_favorite.g.dart';

@JsonSerializable()
class UserFavorite {
  final int user;
  final String email;
  final String uid;
  final List<dynamic> favorites;

  UserFavorite({
    required this.user,
    required this.email,
    required this.uid,
    required this.favorites,
  });

  factory UserFavorite.fromJson(Map<String, dynamic> json) {
    return _$UserFavoriteFromJson(json);
  }
}
