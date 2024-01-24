import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/loader.dart';
import '../../../responsive/responsive.dart';
import '../../auth/controller/auth_controller.dart';
import '../controller/community_controller.dart';

class AddModsScreen extends ConsumerStatefulWidget {
  final String name;
  const AddModsScreen({
    super.key,
    required this.name,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddModScreenState();
}

class _AddModScreenState extends ConsumerState<AddModsScreen> {
  Set<String> uids = {};
  int counter = 0;

  void addUid(String uid) {
    setState(() {
      uids.add(uid);
    });
  }

  void removeUid(String uid) {
    setState(() {
      uids.remove(uid);
    });
  }

  void saveMods() {
    ref
        .read(communityControllerProvider.notifier)
        .addModerators(widget.name, uids.toList(), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: saveMods,
            icon: const Icon(Icons.done),
          )
        ],
      ),
      body: Responsive(
        child: ref.watch(getCommunityByNameProvider(widget.name)).when(
              data: (community) => ListView.builder(
                  itemCount: community.members.length,
                  itemBuilder: (BuildContext context, int index) {
                    final memberUid = community.members[index];
                    return ref.watch(getUserDataProvider(memberUid)).when(
                        data: (member) {
                          if (community.mods.contains(member.uid) &&
                              counter == 0) {
                            uids.add(member.uid);
                          }
                          counter++;
                          return CheckboxListTile(
                              value: uids.contains(member.uid),
                              onChanged: (value) {
                                if (value!) {
                                  addUid(member.uid);
                                } else {
                                  removeUid(member.uid);
                                }
                              },
                              title: Text(member.name));
                        },
                        error: (error, stackTrace) =>
                            ErrorText(error: error.toString()),
                        loading: () => const Loader());
                  }),
              error: (error, stackTrace) => ErrorText(error: error.toString()),
              loading: () => const Loader(),
            ),
      ),
    );
  }
}
