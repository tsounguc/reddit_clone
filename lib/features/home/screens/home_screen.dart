import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/features/home/drawers/profile_drawer.dart';
import 'package:reddit_clone/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/constants/constants.dart';
import '../../auth/controller/auth_controller.dart';
import '../delegates/search_community_delegate.dart';
import '../drawers/community_list_drawer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentPage = 0;

  void onPageChange(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void displayProfileDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void navigateToAddPostScreen(BuildContext context) {
    Routemaster.of(context).push('/add-post');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    // print(isGuest);
    final currentTheme = ref.watch(themeNotifierProvider);
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
          if (kIsWeb)
            IconButton(
              onPressed: () => navigateToAddPostScreen(context),
              icon: const Icon(Icons.add),
            ),
          Builder(builder: (context) {
            return IconButton(
              onPressed: () => displayProfileDrawer(context),
              icon:
                  CircleAvatar(backgroundImage: NetworkImage(user.profilePic)),
            );
          })
        ],
      ),
      drawer: const CommunityListDarwer(),
      endDrawer: isGuest ? null : const ProfileDrawer(),
      body: Constants.tabWidgets[_currentPage],
      bottomNavigationBar: isGuest || kIsWeb
          ? null
          : CupertinoTabBar(
              currentIndex: _currentPage,
              activeColor: currentTheme.iconTheme.color,
              backgroundColor: currentTheme.colorScheme.background,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.add), label: '')
              ],
              onTap: onPageChange,
            ),
    );
  }
}
