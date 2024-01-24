import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

import '../../../responsive/responsive.dart';

class ModToolsScreen extends StatelessWidget {
  final String name;
  const ModToolsScreen({super.key, required this.name});

  void navitageToEditCommunity(BuildContext context) {
    Routemaster.of(context).push('/edit-community/$name');
  }

  void navigateToAddModerators(BuildContext context) {
    Routemaster.of(context).push('/add-mods/$name');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mod Tools'),
      ),
      body: Responsive(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.add_moderator),
              title: const Text('Add Moderators'),
              onTap: () => navigateToAddModerators(context),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Community'),
              onTap: () => navitageToEditCommunity(context),
            ),
          ],
        ),
      ),
    );
  }
}
