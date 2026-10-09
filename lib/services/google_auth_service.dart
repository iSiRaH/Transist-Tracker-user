import 'package:google_sign_in/google_sign_in.dart';
import 'package:transist_tracker/utils/api_config.dart';

class GoogleAuthUser {
  final String? idToken;
  final String email;
  final String? displayName;
  final String? id;
  final String? photoUrl;

  const GoogleAuthUser({
    this.idToken,
    required this.email,
    this.displayName,
    this.id,
    this.photoUrl,
  });
}

class GoogleAuthService {
  final GoogleSignIn _googleSignIn;

  GoogleAuthService({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              clientId: ApiConfig.googleClientId,
              serverClientId: ApiConfig.googleServerClientId,
              scopes: const <String>[
                'email',
                'profile',
              ],
            );

  Future<GoogleAuthUser?> signIn() async {
    final account = await _googleSignIn.signIn();
    if (account == null) {
      return null;
    }

    final authentication = await account.authentication;

    return GoogleAuthUser(
      idToken: authentication.idToken,
      email: account.email,
      displayName: account.displayName,
      id: account.id,
      photoUrl: account.photoUrl,
    );
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }
}
