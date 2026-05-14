import 'package:flutter/material.dart';

class FollowManager {
  static ValueNotifier<int> followingCount = ValueNotifier<int>(16);

  static List<String> followedUserIds = [];

  static void toggleFollow(String userId) {
    if (followedUserIds.contains(userId)) {
      followedUserIds.remove(userId);
      followingCount.value--;
    } else {
      followedUserIds.add(userId);
      followingCount.value++;
    }
  }

  static bool isFollowing(String userId) {
    return followedUserIds.contains(userId);
  }
}