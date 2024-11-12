import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? token = await user.getIdToken();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('authToken', token ?? '');
      }
      return 'Success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      } else {
        return 'Invalid login credentials.';
      }
    } catch (e) {
      return e.toString();
    }
  }
}
