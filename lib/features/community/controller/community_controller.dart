import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/constants/constants.dart';
import '../../../core/utils.dart';
import '../../../models/community_model.dart';
import '../../auth/controller/auth_controller.dart';
import '../repository/community_repository.dart';

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>(
  (ref) => CommunityController(
    communityRepository: ref.read(communityRepositoryProvider),
    ref: ref,
  ),
);

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final Ref _ref;
  CommunityController(
      {required CommunityRepository communityRepository, required Ref ref})
      : _communityRepository = communityRepository,
        _ref = ref,
        super(false);

  void createCommnity(
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
      mods: [],
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
}
