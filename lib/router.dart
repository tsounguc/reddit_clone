// LoggedOut
import 'package:flutter/material.dart';
import 'package:reddit_clone/features/auth/screen/login_screen.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (routeData) => const MaterialPage(child: LoginScreen()),
});
// LoggedIn