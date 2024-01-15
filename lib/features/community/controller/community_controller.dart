import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/constants/constants.dart';
import '../../../core/providers/storage_repository_provider.dart';
import '../../../core/utils.dart';
import '../../../models/community_model.dart';
import '../../auth/controller/auth_controller.dart';
import '../repository/community_repository.dart';

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>(
  (ref) => CommunityController(
    communityRepository: ref.watch(communityRepositoryProvider),
    storageRepository: ref.watch(storageRepositoryProvider),
    ref: ref,
  ),
);

final getUserCommunitiesProvider = StreamProvider(
  (ref) => ref.watch(communityControllerProvider.notifier).getUserCommunities(),
);

final getCommunityByNameProvider = StreamProvider.family(
  (ref, String name) =>
      ref.watch(communityControllerProvider.notifier).getCommunityByName(name),
);

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final StorageRepository _storageRepository;
  final Ref _ref;
  CommunityController({
    required CommunityRepository communityRepository,
    required StorageRepository storageRepository,
    required Ref ref,
  })  : _communityRepository = communityRepository,
        _storageRepository = storageRepository,
        _ref = ref,
        super(false);

  void createCommunity(
    String name,
    BuildContext context,
  ) async {
    state = true;
    final uid = _ref.read(userProvider)?.uid ?? '';

    Community community = Community(
      id: name,
      name: name,
      banner: Constants.bannerDefault,
      avatar: Constants.avatarDefault,
      members: [uid],
      mods: [uid],
    );
    final result = await _communityRepository.createCommnity(community);
    state = false;
    result.fold(
      (failure) => showSnackBar(context, failure.message),
      (r) {
        showSnackBar(context, 'Community created successfully!');
        Routemaster.of(context).pop();
      },
    );
  }

  void editCommunity({
    required File? avatarFile,
    required File? bannerFile,
    required BuildContext context,
    required Community community,
  }) async {
    state = true;
    if (avatarFile != null) {
      final result = await _storageRepository.storeFile(
          path: 'community/avatar', id: community.id, file: avatarFile);
      result.fold(
        (failure) => showSnackBar(context, failure.message),
        (newAvatar) => community = community.copyWith(avatar: newAvatar),
      );
    }
    if (bannerFile != null) {
      final result = await _storageRepository.storeFile(
          path: 'community/banner', id: community.id, file: bannerFile);
      result.fold(
        (failure) => showSnackBar(context, failure.message),
        (newBanner) => community = community.copyWith(banner: newBanner),
      );
    }

    final result = await _communityRepository.editCommunity(community);
    state = false;
    result.fold(
      (failure) => showSnackBar(context, failure.message),
      (r) {
        showSnackBar(context, 'Community updated successfully!');
        Routemaster.of(context).pop();
      },
    );
  }

  Stream<List<Community>> getUserCommunities() {
    final uid = _ref.read(userProvider)?.uid ?? '';
    return _communityRepository.getUserCommunities(uid);
  }

  Stream<Community> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }
}
