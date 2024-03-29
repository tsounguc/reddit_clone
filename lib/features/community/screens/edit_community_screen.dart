import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';

import '../../../core/common/loader.dart';
import '../../../core/constants/constants.dart';
import '../../../core/utils.dart';
import '../../../models/community_model.dart';
import '../../../responsive/responsive.dart';
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
  File? bannerFile;
  File? avatarFile;
  Uint8List? bannerWebFile;
  Uint8List? avatarWebFile;
  void selectBannerImage() async {
    final result = await pickImage();

    if (result != null) {
      if (kIsWeb) {
        bannerWebFile = result.files.first.bytes;
      } else {
        bannerFile = File(result.files.first.path!);
      }
    }
  }

  void selectAvatarImage() async {
    final result = await pickImage();
    if (result != null) {
      if (kIsWeb) {
        avatarWebFile = result.files.first.bytes;
      } else {
        avatarFile = File(result.files.first.path!);
      }
    }
  }

  void save(Community community) {
    ref.read(communityControllerProvider.notifier).editCommunity(
          avatarFile: avatarFile,
          bannerFile: bannerFile,
          avatarWebFile: avatarWebFile,
          bannerWebFile: bannerWebFile,
          context: context,
          community: community,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    final currentTheme = ref.watch(themeNotifierProvider);

    return isLoading
        ? const Loader()
        : ref.watch(getCommunityByNameProvider(widget.name)).when(
              data: (community) {
                return Scaffold(
                  backgroundColor: currentTheme.colorScheme.background,
                  appBar: AppBar(
                    title: const Text('Edit Community'),
                    centerTitle: false,
                    actions: [
                      TextButton(
                        onPressed: () => save(community),
                        style: TextButton.styleFrom(
                            foregroundColor: Pallete.blueColor),
                        child: Text(
                          'Save',
                          style: TextStyle(color: Pallete.blueColor),
                        ),
                      ),
                    ],
                  ),
                  body: Responsive(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 200,
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: selectBannerImage,
                              child: DottedBorder(
                                radius: const Radius.circular(10),
                                borderType: BorderType.RRect,
                                dashPattern: const [10, 4],
                                strokeCap: StrokeCap.round,
                                color:
                                    currentTheme.textTheme.bodyMedium!.color!,
                                child: Container(
                                  width: double.infinity,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: bannerWebFile != null
                                      ? Image.memory(bannerWebFile!)
                                      : bannerFile != null
                                          ? Image.file(bannerFile!)
                                          : community.banner.isEmpty ||
                                                  community.banner ==
                                                      Constants.bannerDefault
                                              ? const Center(
                                                  child: Icon(
                                                    Icons.camera_alt_outlined,
                                                    size: 40,
                                                  ),
                                                )
                                              : Image.network(community.banner),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 20,
                              bottom: 20,
                              child: GestureDetector(
                                onTap: selectAvatarImage,
                                child: avatarWebFile != null
                                    ? CircleAvatar(
                                        backgroundImage:
                                            MemoryImage(avatarWebFile!),
                                        radius: 32,
                                      )
                                    : avatarFile != null
                                        ? CircleAvatar(
                                            backgroundImage:
                                                FileImage(avatarFile!),
                                            radius: 32,
                                          )
                                        : CircleAvatar(
                                            backgroundImage:
                                                NetworkImage(community.avatar),
                                            radius: 32,
                                          ),
                              ),
                            ),
                          ],
                        ),
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
