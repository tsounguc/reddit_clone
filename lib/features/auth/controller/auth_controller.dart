import 'package:firebase_auth/firebase_auth.dart';
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

final authStateChangeProvider = StreamProvider((ref) {
  return ref.watch(authControllerProvider.notifier).authStateChange;
});

final getUserDataProvider = StreamProvider.family((ref, String uid) {
  return ref.watch(authControllerProvider.notifier).getUserData(uid);
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;
  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false); // returns at first since it's not loading

  // User is from firebase_auth
  Stream<User?> get authStateChange => _authRepository.authStateChange;

  void signInWithGoogle(BuildContext? context) async {
    state = true;
    final userModel = await _authRepository.signInWithGoogle();
    state = false;
    userModel.fold(
      (failure) => showSnackBar(context!, failure.message),
      (updatedUserModel) => _ref
          .read(userProvider.notifier)
          .update((previdousUserModel) => updatedUserModel),
    );
  }

  void signInAsGuest(BuildContext? context) async {
    state = true;
    final userModel = await _authRepository.signInAsGuest();
    state = false;
    userModel.fold(
      (failure) => showSnackBar(context!, failure.message),
      (updatedUserModel) => _ref
          .read(userProvider.notifier)
          .update((previdousUserModel) => updatedUserModel),
    );
  }

  Stream<UserModel> getUserData(String uid) {
    return _authRepository.getUserData(uid);
  }

  void logOut() async {
    _authRepository.logOut();
  }
}
