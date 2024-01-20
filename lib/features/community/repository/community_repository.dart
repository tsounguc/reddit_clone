import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/constants/firebase_constants.dart';
import 'package:reddit_clone/core/failure.dart';
import 'package:reddit_clone/core/providers/firebase_providers.dart';

import '../../../core/type_defs.dart';
import '../../../models/community_model.dart';
import '../../../models/post_model.dart';

final communityRepositoryProvider = Provider((ref) {
  return CommunityRepository(firestore: ref.watch(firestoreProvider));
});

class CommunityRepository {
  final FirebaseFirestore _firestore;
  CommunityRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  FutureVoid createCommnity(Community community) async {
    try {
      var communityDoc = await _communities.doc(community.name).get();
      if (communityDoc.exists) {
        throw 'Community with the same name already exists';
      }

      return Right(_communities.doc(community.id).set(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid joinCommunity(String communityName, String userId) async {
    try {
      return right(
        _communities.doc(communityName).update({
          'members': FieldValue.arrayUnion([userId]),
        }),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid leaveCommunity(String communityName, String userId) async {
    try {
      return right(
        _communities.doc(communityName).update({
          'members': FieldValue.arrayRemove([userId]),
        }),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> getUserCommunities(String uid) {
    debugPrint(uid);
    return _communities
        .where('members', arrayContains: uid)
        .snapshots() // This is a query snapshot
        .map((event) {
      List<Community> userCommunities = [];
      for (var doc in event.docs) {
        Community community =
            Community.fromMap(doc.data() as Map<String, dynamic>);
        userCommunities.add(community);
      }
      return userCommunities;
    });
  }

  Stream<Community> getCommunityByName(String name) {
    // the snapshot here is a document snapshot
    return _communities.doc(name).snapshots().map((event) {
      return Community.fromMap(event.data() as Map<String, dynamic>);
    });
  }

  FutureVoid editCommunity(Community community) async {
    try {
      return right(_communities.doc(community.name).update(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communities
        .where(
          'name',
          isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
          isLessThan: query.isEmpty
              ? null
              : query.substring(0, query.length - 1) +
                  String.fromCharCode(
                    query.codeUnitAt(query.length - 1) + 1,
                  ),
        )
        .snapshots()
        .map(
      (event) {
        List<Community> communities = [];
        for (var doc in event.docs) {
          Community community =
              Community.fromMap(doc.data() as Map<String, dynamic>);
          communities.add(community);
        }
        return communities;
      },
    );
  }

  FutureVoid addModerators(String communityName, List<String> uids) async {
    try {
      return right(_communities.doc(communityName).update({
        'mods': uids,
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> getCommunityPosts(String communityName){
    return _posts.where('communityName', isEqualTo: communityName).orderBy('createdAt', descending: true).snapshots().map((event){
      List<Post> userPosts = [];
      for (var doc in event.docs) {
        Post post = Post.fromMap(doc.data() as Map<String, dynamic>);
        userPosts.add(post);
      }
      return userPosts;
    });
  }

  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);

  CollectionReference get _communities =>
      _firestore.collection(FirebaseConstants.communitiesCollection);
}
