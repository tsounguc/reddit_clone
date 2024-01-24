import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/loader.dart';
import '../../../core/constants/constants.dart';
import '../../../core/utils.dart';
import '../../../models/user_model.dart';
import '../../../responsive/responsive.dart';
import '../../../theme/pallete.dart';
import '../../auth/controller/auth_controller.dart';
import '../controller/user_profile_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  const EditProfileScreen({super.key, required this.uid});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  File? bannerFile;
  File? profileFile;
  Uint8List? profileWebFile;
  Uint8List? bannerWebFile;
  late TextEditingController nameController;
  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: ref.read(userProvider)!.name);
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

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

  void selectProfileImage() async {
    final result = await pickImage();

    if (result != null) {
      if (kIsWeb) {
        profileWebFile = result.files.first.bytes;
      } else {
        profileFile = File(result.files.first.path!);
      }
    }
  }

  void save(UserModel user) {
    ref.read(userProfileControllerProvider.notifier).editUserProfile(
          profileFile: profileFile,
          bannerFile: bannerFile,
          profileWebFile: profileWebFile,
          bannerWebFile: bannerWebFile,
          context: context,
          user: user.copyWith(name: nameController.text.trim()),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(userProfileControllerProvider);
    final currentTheme = ref.watch(themeNotifierProvider);

    return isLoading
        ? const Loader()
        : ref.watch(getUserDataProvider(widget.uid)).when(
              data: (user) {
                return Scaffold(
                  backgroundColor: currentTheme.colorScheme.background,
                  appBar: AppBar(
                    title: const Text('Edit Profile'),
                    centerTitle: false,
                    actions: [
                      TextButton(
                        onPressed: () {
                          save(user);
                        },
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
                      child: Column(
                        children: [
                          SizedBox(
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
                                    color: currentTheme
                                        .textTheme.bodyMedium!.color!,
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
                                              : user.banner.isEmpty ||
                                                      user.banner ==
                                                          Constants
                                                              .bannerDefault
                                                  ? const Center(
                                                      child: Icon(
                                                        Icons
                                                            .camera_alt_outlined,
                                                        size: 40,
                                                      ),
                                                    )
                                                  : Image.network(user.banner),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 20,
                                  bottom: 20,
                                  child: GestureDetector(
                                    onTap: selectProfileImage,
                                    child: profileWebFile != null
                                        ? CircleAvatar(
                                            backgroundImage:
                                                MemoryImage(profileWebFile!),
                                            radius: 32,
                                          )
                                        : profileFile != null
                                            ? CircleAvatar(
                                                backgroundImage:
                                                    FileImage(profileFile!),
                                                radius: 32,
                                              )
                                            : CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    user.profilePic),
                                                radius: 32,
                                              ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              filled: true,
                              hintText: 'Name',
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(18),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
              error: (error, stackTrack) => ErrorText(error: error.toString()),
              loading: () => const Loader(),
            );
  }
}
