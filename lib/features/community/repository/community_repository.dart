import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/constants/firebase_constants.dart';
import 'package:reddit_clone/core/failure.dart';
import 'package:reddit_clone/core/providers/firebase_providers.dart';

import '../../../core/type_defs.dart';
import '../../../models/community_model.dart';

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

  Stream<List<Community>> getUserCommunities(String uid) {
    return _communities
        .where('menbers', arrayContains: uid)
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
    // the snapshot her is a document snapshot
    return _communities.doc(name).snapshots().map((event) {
      return Community.fromMap(event.data() as Map<String, dynamic>);
    });
  }

  CollectionReference get _communities =>
      _firestore.collection(FirebaseConstants.communitiesCollection);
}
