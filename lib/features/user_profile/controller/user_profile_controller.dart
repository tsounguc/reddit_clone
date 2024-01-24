import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/enums/enums.dart';
import '../../../core/providers/storage_repository_provider.dart';
import '../../../core/utils.dart';
import '../../../models/post_model.dart';
import '../../../models/user_model.dart';
import '../repository/user_profile_repository.dart';

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>(
  (ref) => UserProfileController(
    userProfileRepository: ref.watch(userProfileRepositoryProvider),
    storageRepository: ref.watch(storageRepositoryProvider),
    ref: ref,
  ),
);

final getUserPostsProvider = StreamProvider.family(
  (ref, String uid) =>
      ref.watch(userProfileControllerProvider.notifier).getUserPosts(uid),
);

class UserProfileController extends StateNotifier<bool> {
  final UserProfileRepository _userProfileRepository;
  final StorageRepository _storageRepository;
  final Ref _ref;
  UserProfileController({
    required UserProfileRepository userProfileRepository,
    required StorageRepository storageRepository,
    required Ref ref,
  })  : _userProfileRepository = userProfileRepository,
        _storageRepository = storageRepository,
        _ref = ref,
        super(false);

  void editUserProfile({
    required File? profileFile,
    required File? bannerFile,
    required Uint8List? profileWebFile,
    required Uint8List? bannerWebFile,
    required BuildContext context,
    required UserModel user,
  }) async {
    state = true;
    if (profileFile != null || profileWebFile != null) {
      final result = await _storageRepository.storeFile(
        path: 'users/profile',
        id: user.uid,
        file: profileFile,
        webFile: profileWebFile,
      );
      result.fold(
        (failure) => showSnackBar(context, failure.message),
        (newProfilePic) => user = user.copyWith(profilePic: newProfilePic),
      );
    }
    if (bannerFile != null || bannerWebFile != null) {
      final result = await _storageRepository.storeFile(
          path: 'users/banner', id: user.uid, file: bannerFile, webFile: bannerWebFile);
      result.fold(
        (failure) => showSnackBar(context, failure.message),
        (newBanner) => user = user.copyWith(banner: newBanner),
      );
    }

    final result = await _userProfileRepository.editUser(user);
    state = false;
    result.fold(
      (failure) => showSnackBar(context, failure.message),
      (r) {
        _ref.read(userProvider.notifier).update((previousUserData) => user);
        showSnackBar(context, 'Profile updated successfully!');
        Routemaster.of(context).pop();
      },
    );
  }

  Stream<List<Post>> getUserPosts(String uid) {
    return _userProfileRepository.getUserPosts(uid);
  }

  void updateUserKarma(UserKarma userKarma) async {
    state = true;
    UserModel user = _ref.read(userProvider)!;
    user = user.copyWith(karma: user.karma + userKarma.karma);

    final result = await _userProfileRepository.updateUserKarma(user);
    state = false;
    result.fold(
      (failure) => debugPrint(failure.message),
      (r) => _ref.read(userProvider.notifier).update((previouUserData) => user),
    );
  }
}
