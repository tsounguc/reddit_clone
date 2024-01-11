import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/features/auth/repository/auth_repository.dart';

import '../../../core/utils.dart';
import '../../../models/user_model.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);

// Provider
final authControllerProvider =
    StateNotifierProvider<AuthController, bool>(((ref) => AuthController(
          authRepository: ref.read(authRepositoryProvider),
          ref: ref,
        )));

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;
  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false);

  void signInWithGoogle(BuildContext context) async {
    state = true;
    final userModel = await _authRepository.signInWithGoogle();

    userModel.fold(
      (failure) => showSnackBar(context, failure.message),
      (updatedUserModel) => _ref
          .read(userProvider.notifier)
          .update((previdousUserModel) => updatedUserModel),
    );
  }
}
