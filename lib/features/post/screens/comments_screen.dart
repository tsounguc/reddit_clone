import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/common/post_card.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';

import '../../../core/common/error_text.dart';
import '../../../models/post_model.dart';
import 'widgets/comment_card.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentsScreen({super.key, required this.postId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  void addComment(Post post) {
    ref.watch(postControllerProvider.notifier).addComment(
        context: context, text: commentController.text.trim(), post: post);
    setState(() {
      commentController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ref.watch(getPostByIdProvider(widget.postId)).when(
            data: (post) {
              return Column(
                children: [
                  PostCard(post: post),
                  TextField(
                    onSubmitted: (val) => addComment(post),
                    controller: commentController,
                    decoration: const InputDecoration(
                        hintText: 'What are your thoughts?',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(8)),
                  ),
                  ref.watch(commentsOfPostProvider(widget.postId)).when(
                        data: (comments) {
                          return ListView.builder(
                            itemCount: comments.length,
                            itemBuilder: (context, index) =>
                                CommentCard(comment: comments[index]),
                          );
                        },
                        error: (error, stackTrace) =>
                            ErrorText(error: error.toString()),
                        loading: () => const Loader(),
                      )
                ],
              );
            },
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
