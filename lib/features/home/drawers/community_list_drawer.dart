import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/common/loader.dart';
import '../../../core/common/sign_in_button.dart';
import '../../../models/community_model.dart';
import '../../auth/controller/auth_controller.dart';
import '../../community/controller/community_controller.dart';

class CommunityListDarwer extends ConsumerWidget {
  const CommunityListDarwer({super.key});

  void navigateToCreateCommunity(BuildContext context) {
    Routemaster.of(context).pop();
    Routemaster.of(context).push('/create-community');
  }

  void navigateToCommunity(BuildContext context, Community community) {
    Routemaster.of(context).push('/r/${community.name}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    return SafeArea(
      child: Drawer(
        child: ListView(
          children: [
            isGuest
                ? SignInButton(isFromLogin: false,)
                : ListTile(
                    title: const Text('Create a community'),
                    leading: const Icon(Icons.add),
                    onTap: () => navigateToCreateCommunity(context),
                  ),
            if (!isGuest)
              ref.watch(getUserCommunitiesProvider(user.uid)).when(
                    data: (userCommunities) {
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: userCommunities.length,
                          itemBuilder: (BuildContext context, int index) {
                            final userCommnunity = userCommunities[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(userCommnunity.avatar),
                              ),
                              title: Text(
                                'r/${userCommnunity.name}',
                                style: TextStyle(color: Pallete.whiteColor),
                              ),
                              // trailing:
                              //     const Icon(Icons.arrow_forward_ios_outlined),
                              onTap: () =>
                                  navigateToCommunity(context, userCommnunity),
                            );
                          });
                    },
                    error: (error, stackTrace) =>
                        ErrorText(error: error.toString()),
                    loading: () => const Loader(),
                  )
          ],
        ),
      ),
    );
  }
}
