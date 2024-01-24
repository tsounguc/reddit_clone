import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/post_card.dart';
import 'package:reddit_clone/features/user_profile/controller/user_profile_controller.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/loader.dart';
import '../../../responsive/responsive.dart';
import '../../../theme/pallete.dart';
import '../../auth/controller/auth_controller.dart';

class UserProfileScreen extends ConsumerWidget {
  final String uid;
  const UserProfileScreen({super.key, required this.uid});

  void navigateToEditProfile(BuildContext context) {
    Routemaster.of(context).push('/edit-profile/$uid');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Responsive(
        child: ref.watch(getUserDataProvider(uid)).when(
              data: (user) {
                return NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        expandedHeight: 250,
                        floating: true,
                        snap: true,
                        flexibleSpace: Stack(children: [
                          Positioned.fill(
                            child: Image.network(
                              user.banner,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomLeft,
                            padding:
                                const EdgeInsets.all(20).copyWith(bottom: 70),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(user.profilePic),
                              radius: 45,
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomLeft,
                            padding: const EdgeInsets.all(20),
                            child: OutlinedButton(
                              onPressed: () => navigateToEditProfile(context),
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Pallete.blueColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25)),
                              child: const Text('Edit Profile'),
                            ),
                          )
                        ]),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'u/${user.name}',
                                    style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text('${user.karma} karma')),
                              const SizedBox(height: 10),
                              const Divider(thickness: 2),
                            ],
                          ),
                        ),
                      )
                    ];
                  },
                  body: ref.watch(getUserPostsProvider(user.uid)).when(
                        data: (posts) {
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: posts.length,
                            itemBuilder: (BuildContext context, int index) {
                              print(posts[index].title);
                              final post = posts[index];
                              return PostCard(post: post);
                            },
                          );
                        },
                        error: (error, stackTrace) =>
                            ErrorText(error: error.toString()),
                        loading: () => const Loader(),
                      ),
                );
              },
              error: (error, stackTrace) => ErrorText(error: error.toString()),
              loading: () => const Loader(),
            ),
      ),
    );
  }
}
