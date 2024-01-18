import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/loader.dart';
import '../../../core/utils.dart';
import '../../../models/community_model.dart';
import '../../../theme/pallete.dart';
import '../../auth/controller/auth_controller.dart';
import '../../community/controller/community_controller.dart';
import '../controller/post_controller.dart';

class AddPostTypeScreen extends ConsumerStatefulWidget {
  final String type;
  const AddPostTypeScreen({required this.type, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddPostTypeScreenState();
}

class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController linkController = TextEditingController();
  File? imageFile;
  List<Community> communitiesList = [];
  Community? selectedCommunity;

  void selectBannerImage() async {
    final result = await pickImage();

    if (result != null) {
      imageFile = File(result.files.first.path!);
    }
  }

  void sharePost() {
    if (widget.type == 'image' &&
        imageFile != null &&
        titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareImagePost(
            context: context,
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity ?? communitiesList[0],
            file: imageFile!,
          );
    } else if (widget.type == 'link' &&
        titleController.text.isNotEmpty &&
        linkController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareLinkPost(
            context: context,
            title: titleController.text,
            selectedCommunity: selectedCommunity ?? communitiesList[0],
            link: linkController.text.trim(),
          );
    } else if (widget.type == 'text' && titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareTextPost(
            context: context,
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity ?? communitiesList[0],
            description: descriptionController.text.trim(),
          );
    } else {
      showSnackBar(context, 'Please enter all the fields');
    }
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTypeImage = widget.type == 'image';
    final isTypeLink = widget.type == 'link';
    final isTypeText = widget.type == 'text';
    final currentTheme = ref.watch(themeNotifierProvider);
    final user = ref.watch(userProvider)!;
    final isLoading = ref.watch(postControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Post ${widget.type.replaceFirst(widget.type[0], widget.type[0].toUpperCase())}',
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: sharePost,
            style: TextButton.styleFrom(foregroundColor: Pallete.blueColor),
            child: Text(
              'Share',
              style: TextStyle(color: Pallete.blueColor),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Loader()
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      filled: true,
                      hintText: 'Enter Title Here',
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.blue,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(18),
                    ),
                    maxLength: 30,
                  ),
                  const SizedBox(height: 10),
                  if (isTypeImage)
                    GestureDetector(
                      onTap: selectBannerImage,
                      child: DottedBorder(
                        radius: const Radius.circular(10),
                        borderType: BorderType.RRect,
                        dashPattern: const [10, 4],
                        strokeCap: StrokeCap.round,
                        color: currentTheme.textTheme.bodyMedium!.color!,
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: imageFile != null
                              ? Image.file(imageFile!)
                              : const Center(
                                  child: Icon(
                                    Icons.camera_alt_outlined,
                                    size: 40,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  if (isTypeText)
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        filled: true,
                        hintText: 'Enter Description Here',
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.blue,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(18),
                      ),
                      maxLines: null,
                      minLines: 8,
                    ),
                  if (isTypeLink)
                    TextField(
                      controller: linkController,
                      decoration: InputDecoration(
                        filled: true,
                        hintText: 'Enter Link Here',
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.blue,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(18),
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Select Community',
                    ),
                  ),
                  ref.watch(getUserCommunitiesProvider(user.uid)).when(
                      data: (communities) {
                        communitiesList = communities;
                        if (communities.isEmpty) {
                          return const SizedBox();
                        }
                        return DropdownButton(
                          value: selectedCommunity ?? communities[0],
                          items: communities
                              .map((community) => DropdownMenuItem(
                                  value: community,
                                  child: Text(community.name)))
                              .toList(),
                          onChanged: (newCommunity) {
                            setState(() {
                              selectedCommunity = newCommunity;
                            });
                          },
                        );
                      },
                      error: (error, stackTrace) =>
                          ErrorText(error: error.toString()),
                      loading: () => const Loader())
                ],
              ),
            ),
    );
  }
}
