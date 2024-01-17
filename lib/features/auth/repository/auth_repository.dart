import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:reddit_clone/models/user_model.dart';

import '../../../core/constants/constants.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/failure.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/type_defs.dart';

// Provider
final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
      firestore: ref.read(firestoreProvider),
      auth: ref.read(authProvider),
      googleSignIn: ref.read(googleSignInProvider)),
);

// Auth repository is going to contain all the logic for the Firebase calls
// This also where we receive errors from the outside and throw it to the controller to handle
class AuthRepository {
  // we don't want these fields to be accessible outside of this class so we make them private
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  // User is from firebase_auth
  Stream<User?> get authStateChange => _auth.authStateChanges();

  FutureEither<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth?.idToken,
        accessToken: googleAuth?.accessToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      var user = userCredential.user;

      late UserModel userModel;

      if (userCredential.additionalUserInfo!.isNewUser) {
        userModel = UserModel(
          name: user?.displayName ?? 'No Name',
          profilePic: user?.photoURL ?? Constants.avatarDefault,
          banner: Constants.bannerDefault,
          uid: user?.uid ?? '',
          isAuthenticated: true,
          karma: 0,
          awards: [],
        );

        await _users.doc(user!.uid).set(userModel.toMap());
      } else {
        userModel = await getUserData(user!.uid).first;
      }
      return right(userModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  void logOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map(
          (event) => UserModel.fromMap(event.data() as Map<String, dynamic>),
        );
  }
}
