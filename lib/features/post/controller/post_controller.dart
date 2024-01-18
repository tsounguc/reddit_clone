import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/storage_repository_provider.dart';
import '../../../models/community_model.dart';
import '../../../models/post_model.dart';
import '../../auth/controller/auth_controller.dart';
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
      createAt: DateTime.now(),
      awards: [],
      description: description,
    );

    final result = await _postRepository.addPost(post);
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
      createAt: DateTime.now(),
      awards: [],
      link: link,
    );

    final result = await _postRepository.addPost(post);
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
        createAt: DateTime.now(),
        awards: [],
        link: imagePath,
      );

      final result = await _postRepository.addPost(post);
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

  void deletePost(BuildContext context, Post post) async {
    final result = await _postRepository.deletePost(post);

    result.fold(
      (failure) => showSnackBar(context, failure.message),
      (r) => showSnackBar(context, 'Post deleted successfully!'),
    );
  }
}
