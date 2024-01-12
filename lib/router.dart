import 'package:flutter/material.dart';
import 'package:reddit_clone/features/auth/screen/login_screen.dart';
import 'package:routemaster/routemaster.dart';

import 'features/community/screens/create_community_screen.dart';
import 'features/home/screens/home_screen.dart';

// LoggedOut
final loggedOutRoute = RouteMap(routes: {
  '/': (routeData) => const MaterialPage(child: LoginScreen()),
});

// LoggedIn
final loggedInRoute = RouteMap(routes: {
  '/': (routeData) => const MaterialPage(child: HomeScreen()),
  '/create-commnuinty': (_) =>
      const MaterialPage(child: CreateCommunityScreen()),
});
