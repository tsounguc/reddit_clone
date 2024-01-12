import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/controller/auth_controller.dart';
import '../drawers/community_list_drawer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
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
            onPressed: () {},
            icon: CircleAvatar(
                backgroundImage: NetworkImage(user?.profilePic ?? '')),
          )
        ],
      ),
      drawer: const CommunityListDarwer(),
      body: Center(child: Text(user!.name)),
    );
  }
}
