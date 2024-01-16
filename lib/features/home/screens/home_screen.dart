import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/features/home/drawers/profile_drawer.dart';

import '../../auth/controller/auth_controller.dart';
import '../delegates/search_community_delegate.dart';
import '../drawers/community_list_drawer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void displayProfileDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => displayDrawer(context),
            );
          },
        ),
        title: const Text('Home'),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: SearchCommunityDelegate(ref),
                );
              },
              icon: const Icon(Icons.search)),
          Builder(builder: (context) {
            return IconButton(
              onPressed: () => displayProfileDrawer(context),
              icon: CircleAvatar(
                  backgroundImage: NetworkImage(user?.profilePic ?? '')),
            );
          })
        ],
      ),
      drawer: const CommunityListDarwer(),
      endDrawer: const ProfileDrawer(),
      body: Center(child: Text(user!.name)),
    );
  }
}
