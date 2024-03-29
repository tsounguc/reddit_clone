import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';

import '../../theme/pallete.dart';
import '../constants/constants.dart';
import '../providers/global_key_provider.dart';

class SignInButton extends ConsumerWidget {
  final bool isFromLogin; 
  const SignInButton({super.key, this.isFromLogin = true});
  void signInWithGoogle(WidgetRef ref) {
    final context = ref.read(globalKeyProvider).currentContext;
    ref.watch(authControllerProvider.notifier).signInWithGoogle(context, isFromLogin);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: ElevatedButton.icon(
        onPressed: () => signInWithGoogle(ref),
        icon: Image.asset(
          Constants.googlePath,
          width: 35,
        ),
        label: const Text(
          "Continue with Google",
          style: TextStyle(fontSize: 18, color: Pallete.whiteColor),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Pallete.greyColor,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
