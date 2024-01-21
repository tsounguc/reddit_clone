import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

import '../../features/auth/controller/auth_controller.dart';
import '../../features/community/controller/community_controller.dart';
import '../../features/post/controller/post_controller.dart';
import '../../models/post_model.dart';
import '../constants/constants.dart';
import 'loader.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  void deletePost(BuildContext context, WidgetRef ref) {
    ref.read(postControllerProvider.notifier).deletePost(context, post);
  }

  void upvote(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).upvote(post);
  }

  void downvote(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).downvote(post);
  }

  void navigateToUserProfile(BuildContext context, String uid) async {
    Routemaster.of(context).push('/user-profile/$uid');
  }

  void navigateToCommunity(BuildContext context) async {
    Routemaster.of(context).push('/r/${post.communityName}');
  }
  void navigateToCommentScreen(BuildContext context) async {
    Routemaster.of(context).push('/post/${post.id}/comments');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage = post.type == 'image';
    final isTypeLink = post.type == 'link';
    final isTypeText = post.type == 'text';
    final user = ref.watch(userProvider)!;
    final currentTheme = ref.watch(themeNotifierProvider);
    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration:
            BoxDecoration(color: currentTheme.drawerTheme.backgroundColor),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 16,
                    ).copyWith(right: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => navigateToCommunity(context),
                                  child: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(post.communityProfilePic),
                                    radius: 16,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'r/${post.communityName}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => navigateToUserProfile(
                                            context, user.uid),
                                        child: Text(
                                          'u/${post.username}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (post.uid == user.uid)
                              IconButton(
                                onPressed: () => deletePost(context, ref),
                                icon: Icon(
                                  Icons.delete,
                                  color: Pallete.redColor,
                                ),
                              )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Text(
                            post.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isTypeImage)
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.35,
                            width: double.infinity,
                            child: Image.network(
                              post.link!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        if (isTypeLink)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: AnyLinkPreview(
                                displayDirection:
                                    UIDirection.uiDirectionHorizontal,
                                link: post.link!),
                          ),
                        if (isTypeText)
                          Container(
                            alignment: Alignment.bottomLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              post.description!,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => upvote(ref),
                                  icon: Icon(
                                    Constants.up,
                                    size: 30,
                                    color: post.upvotes.contains(user.uid)
                                        ? Pallete.redColor
                                        : null,
                                  ),
                                ),
                                Text(
                                  '${post.upvotes.length - post.downvotes.length == 0 ? 'Vote' : post.upvotes.length - post.downvotes.length}',
                                  style: const TextStyle(fontSize: 17),
                                ),
                                IconButton(
                                  onPressed: () => downvote(ref),
                                  icon: Icon(
                                    Constants.down,
                                    size: 30,
                                    color: post.downvotes.contains(user.uid)
                                        ? Pallete.blueColor
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: ()=> navigateToCommentScreen(context),
                                  icon: const Icon(
                                    Icons.comment,
                                  ),
                                ),
                                Text(
                                  '${post.commentCount == 0 ? 'Comment' : post.commentCount}',
                                  style: const TextStyle(fontSize: 17),
                                ),
                              ],
                            ),
                            ref
                                .watch(getCommunityByNameProvider(
                                    post.communityName))
                                .when(
                                  data: (community) {
                                    if (community.mods.contains(user.uid)) {
                                      return IconButton(
                                        onPressed: () => navigateToUserProfile(
                                            context, user.uid),
                                        icon: const Icon(
                                          Icons.admin_panel_settings,
                                        ),
                                      );
                                    }
                                    return const SizedBox();
                                  },
                                  error: (error, stackTrace) =>
                                      ErrorText(error: error.toString()),
                                  loading: () => const Loader(),
                                ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}
