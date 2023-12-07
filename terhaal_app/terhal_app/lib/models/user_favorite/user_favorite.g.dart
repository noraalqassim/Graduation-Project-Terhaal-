// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_favorite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserFavorite _$UserFavoriteFromJson(Map<String, dynamic> json) => UserFavorite(
      user: json['user'] as int,
      email: json['email'] as String,
      uid: json['uid'] as String,
      favorites: json['favorites'] as List<dynamic>,
    );

Map<String, dynamic> _$UserFavoriteToJson(UserFavorite instance) =>
    <String, dynamic>{
      'user': instance.user,
      'email': instance.email,
      'uid': instance.uid,
      'favorites': instance.favorites,
    };
