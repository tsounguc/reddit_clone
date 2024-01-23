import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/models/comment_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

import '../../../core/enums/enums.dart';
import '../../../core/providers/storage_repository_provider.dart';
import '../../../models/community_model.dart';
import '../../../models/post_model.dart';
import '../../auth/controller/auth_controller.dart';
import '../../user_profile/controller/user_profile_controller.dart';
import '../repository/post_repository.dart';

final postControllerProvider = StateNotifierProvider<PostController, bool>(
  (ref) => PostController(
    postRepository: ref.watch(postRepositoryProvider),
    storageRepository: ref.watch(storageRepositoryProvider),
    ref: ref,
  ),
);

final userPostsProvider = StreamProvider.family(
  (ref, List<Community> communities) =>
      ref.watch(postControllerProvider.notifier).fetchUserPosts(communities),
);

final guestPostsProvider = StreamProvider(
  (ref) => ref.watch(postControllerProvider.notifier).fetchGuestPosts(),
);

final getPostByIdProvider = StreamProvider.family(
  (ref, String postId) =>
      ref.watch(postControllerProvider.notifier).getPostById(postId),
);

final postCommentsProvider = StreamProvider.family(
  (ref, String postId) =>
      ref.watch(postControllerProvider.notifier).getPostComments(postId),
);

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final StorageRepository _storageRepository;
  final Ref _ref;
  PostController({
    required PostRepository postRepository,
    required StorageRepository storageRepository,
    required Ref ref,
  })  : _postRepository = postRepository,
        _storageRepository = storageRepository,
        _ref = ref,
        super(false);

  void shareTextPost(
      {required BuildContext context,
      required String title,
      required Community selectedCommunity,
      required String description}) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    final Post post = Post(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user.name,
      uid: user.uid,
      type: 'text',
      createdAt: DateTime.now(),
      awards: [],
      description: description,
    );

    final result = await _postRepository.addPost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.textPost);
    state = false;

    result.fold((failure) => showSnackBar(context, failure.message), (r) {
      showSnackBar(context, 'Posted successfully!');
      Routemaster.of(context).pop();
    });
  }

  void shareLinkPost(
      {required BuildContext context,
      required String title,
      required Community selectedCommunity,
      required String link}) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    final Post post = Post(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user.name,
      uid: user.uid,
      type: 'link',
      createdAt: DateTime.now(),
      awards: [],
      link: link,
    );

    final result = await _postRepository.addPost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.linkPost);
    state = false;

    result.fold((failure) => showSnackBar(context, failure.message), (r) {
      showSnackBar(context, 'Posted successfully!');
      Routemaster.of(context).pop();
    });
  }

  void shareImagePost(
      {required BuildContext context,
      required String title,
      required Community selectedCommunity,
      required File file}) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    final imageResult = await _storageRepository.storeFile(
        path: 'posts/${selectedCommunity.name}', id: postId, file: file);
    imageResult.fold((failure) => showSnackBar(context, failure.message),
        (imagePath) async {
      final Post post = Post(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user.name,
        uid: user.uid,
        type: 'image',
        createdAt: DateTime.now(),
        awards: [],
        link: imagePath,
      );

      final result = await _postRepository.addPost(post);
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.imagePost);
      state = false;

      result.fold((failure) => showSnackBar(context, failure.message), (r) {
        showSnackBar(context, 'Posted successfully!');
        Routemaster.of(context).pop();
      });
    });
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    if (communities.isNotEmpty) {
      return _postRepository.fetchUserPosts(communities);
    }
    return Stream.value([]);
  }

  Stream<List<Post>> fetchGuestPosts() {
    return _postRepository.fetchGuestPosts();
  }

  void deletePost(BuildContext context, Post post) async {
    state = true;
    final result = await _postRepository.deletePost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.deletePost);
    state = false;

    result.fold(
      (failure) => showSnackBar(context, failure.message),
      (r) => showSnackBar(context, 'Post deleted successfully!'),
    );
  }

  void upvote(Post post) async {
    final user = _ref.read(userProvider)!;
    _postRepository.upvote(post, user.uid);
  }

  void downvote(Post post) async {
    final user = _ref.read(userProvider)!;
    _postRepository.downvote(post, user.uid);
  }

  Stream<Post> getPostById(String postId) {
    return _postRepository.getPostById(postId);
  }

  void addComment(
      {required BuildContext context,
      required String text,
      required Post post,
      required String username,
      required String userProfilePic}) async {
    String commentId = const Uuid().v1();

    Comment comment = Comment(
      id: commentId,
      text: text,
      createdAt: DateTime.now(),
      postId: post.id,
      username: username,
      profilePic: userProfilePic,
    );

    final result = await _postRepository.addComment(comment);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.comment);

    result.fold(
      (failure) => showSnackBar(context, failure.message),
      (r) => null,
    );
  }

  void awardPost(
      {required Post post,
      required String award,
      required BuildContext context,
      required String senderId}) async {
    final result = await _postRepository.awardPost(post, award, senderId);

    result.fold((failure) => showSnackBar(context, failure.message), (r) {
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.awardPost);

      _ref.read(userProvider.notifier).update((userData) {
        userData?.awards.remove(award);
        return userData;
      });
      Routemaster.of(context).pop();
    });
  }

  Stream<List<Comment>> getPostComments(String postId) {
    return _postRepository.getPostComments(postId);
  }
}
