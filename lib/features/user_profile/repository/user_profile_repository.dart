import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reddit_clone/core/failure.dart';
import 'package:reddit_clone/core/providers/firebase_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/models/post_model.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/type_defs.dart';
import '../../../models/user_model.dart';
import 'package:fpdart/fpdart.dart';

final userProfileRepositoryProvider = Provider((ref) {
  return UserProfileRepository(firestore: ref.watch(firestoreProvider));
});

class UserProfileRepository {
  final FirebaseFirestore _firestore;
  UserProfileRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  FutureVoid editUser(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update(user.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> getUserPosts(String uid) {
    return _posts
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) {
      List<Post> userPosts = [];
      for (var doc in event.docs) {
        Post post = Post.fromMap(doc.data() as Map<String, dynamic>);
        userPosts.add(post);
      }
      return userPosts;
    });
  }

  FutureVoid updateUserKarma(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update({'karma': user.karma}));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);
}
