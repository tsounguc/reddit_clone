import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/common/loader.dart';
import '../../community/controller/community_controller.dart';

class CommunityListDarwer extends ConsumerWidget {
  const CommunityListDarwer({super.key});

  void navigateToCreateCommunity(BuildContext context) {
    Routemaster.of(context).push('/create-community');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Create a community'),
              leading: const Icon(Icons.add),
              onTap: () => navigateToCreateCommunity(context),
            ),
            ref.watch(getUserCommunitiesProvider).when(
                  data: (userCommunities) {
                    return Expanded(
                      child: ListView.builder(
                          itemCount: userCommunities.length,
                          itemBuilder: (BuildContext context, int index) {
                            final userCommnunity = userCommunities[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(userCommnunity.avatar),
                              ),
                              title: Text('r/${userCommnunity.name}'),
                              trailing:
                                  const Icon(Icons.arrow_forward_ios_outlined),
                              onTap: () {},
                            );
                          }),
                    );
                  },
                  error: (error, stackTrack) =>
                      ErrorText(error: error.toString()),
                  loading: () => const Loader(),
                )
          ],
        ),
      ),
    );
  }
}
