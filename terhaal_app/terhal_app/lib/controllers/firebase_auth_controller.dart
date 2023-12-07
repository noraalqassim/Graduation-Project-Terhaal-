import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:terhal_app/controllers/firebase_firestore_controller.dart';
import 'package:terhal_app/controllers/user_controller.dart';
import 'package:terhal_app/exceptions/auth_exception.dart';
import 'package:terhal_app/utils/alert.dart';
import 'package:terhal_app/models/user.dart' as user;

class FirebaseAuthController extends GetxController {
  final RxBool isLoading = false.obs;
  final _auth = FirebaseAuth.instance;

  static FirebaseAuthController get to => Get.find();
  final _firestoreController = FirebaseFirestoreController.to;
  final _userController = UserController.to;

  User? get currentUser {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      _firestoreController.getUser(currentUser.uid).then((user) {
        currentUser.updateDisplayName("${user?.firstName} ${user?.lastName}");
      });
    }
    return currentUser;
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication gAuth = await gUser!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _auth.signOut();
      await GoogleSignIn().signOut();
      Get.offAllNamed('/signin');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Get.offAllNamed('/home');
    } on FirebaseAuthException catch (e) {
      AuthException.fromCode(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<UserCredential?> signUpWithEmailAndPassword(
      user.User user, password) async {
    try {
      isLoading.value = true;
      return await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      AuthException.fromCode(e);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      isLoading.value = true;
      await _auth.currentUser!.sendEmailVerification();
      Alert.snackbar(
        "Success",
        "Verification link has been sent to your email",
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } on FirebaseAuthException catch (e) {
      AuthException.fromCode(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      isLoading.value = true;
      await _auth
          .sendPasswordResetEmail(email: email)
          .then((value) => Get.back());
      Alert.snackbar(
        "Success",
        "Reset password link has been sent to your email",
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } on FirebaseAuthException catch (e) {
      AuthException.fromCode(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword(String newPassword) async {
    try {
      isLoading.value = true;
      await _auth.currentUser!.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      AuthException.fromCode(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<UserCredential?> reauthenticate({required String password}) async {
    try {
      isLoading.value = true;
      AuthCredential credential = EmailAuthProvider.credential(
        email: _auth.currentUser!.email!,
        password: password,
      );

      return await _auth.currentUser!.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        Alert.snackbar(
          "Error",
          "Password entered is incorrect",
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      isLoading.value = true;
      await _firestoreController.deleteUser(_auth.currentUser!.uid);
      await _userController.deleteUser(_auth.currentUser!.uid);
      await _auth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      AuthException.fromCode(e);
    } finally {
      isLoading.value = false;
    }
  }
}
