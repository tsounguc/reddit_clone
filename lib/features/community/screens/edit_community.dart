import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';

import '../../../core/common/loader.dart';
import '../../../core/constants/constants.dart';
import '../../../theme/pallete.dart';
import '../controller/community_controller.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String name;
  const EditCommunityScreen({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  @override
  Widget build(BuildContext context) {
    return ref.watch(getCommunityByNameProvider(widget.name)).when(
          data: (community) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Edit Community'),
                centerTitle: false,
                actions: [
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                        foregroundColor: Pallete.blueColor),
                    child: Text(
                      'Save',
                      style: TextStyle(color: Pallete.blueColor),
                    ),
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      DottedBorder(
                        radius: const Radius.circular(10),
                        borderType: BorderType.RRect,
                        dashPattern: const [10, 4],
                        strokeCap: StrokeCap.round,
                        color: Pallete.whiteColor,
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: community.banner.isEmpty ||
                                  community.banner == Constants.bannerDefault
                              ? const Center(
                                  child: Icon(
                                    Icons.camera_alt_outlined,
                                    size: 40,
                                  ),
                                )
                              : Image.network(community.banner),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        bottom: 20,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(community.avatar),
                          radius: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          error: (error, stackTrack) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
    //
  }
}
