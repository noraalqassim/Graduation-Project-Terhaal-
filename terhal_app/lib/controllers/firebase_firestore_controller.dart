import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:terhal_app/models/user.dart';

class FirebaseFirestoreController extends GetxController {
  final RxBool isLoading = false.obs;

  final _store = FirebaseFirestore.instance;

  static FirebaseFirestoreController get to =>
      Get.put(FirebaseFirestoreController());

  Future<void> createUser(String uid, User user) async {
    try {
      isLoading.value = true;
      await _store.collection("users").doc(uid).set(user.toJson());
    } finally {
      isLoading.value = false;
    }
  }

  Future<User?> getUser(String uid) async {
    try {
      isLoading.value = true;
      final DocumentSnapshot doc =
          await _store.collection("users").doc(uid).get();
      if (doc.exists) {
        return User.fromDocumentSnapshot(documentSnapshot: doc);
      }
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> user) async {
    try {
      isLoading.value = true;
      await _store.collection("users").doc(uid).update(user);
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<String>> getUsernames() async {
    try {
      isLoading.value = true;
      final QuerySnapshot querySnapshot =
          await _store.collection("users").get();
      final List<String> usernames = <String>[];
      for (final QueryDocumentSnapshot doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (doc.data() != null) {
          usernames.add(data["username"]);
        }
      }
      return usernames;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteUser(String uid) async {
    try {
      isLoading.value = true;
      await _store.collection("users").doc(uid).delete();
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
