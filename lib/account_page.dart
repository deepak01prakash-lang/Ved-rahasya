import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_config.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _createAccount = false;
  bool _busy = false;
  bool _hidePassword = true;
  String? _message;
  bool _messageIsError = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String _friendlyError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'ईमेल पता सही नहीं है।';
      case 'user-not-found':
      case 'invalid-credential':
        return 'ईमेल या पासवर्ड सही नहीं है।';
      case 'wrong-password':
        return 'पासवर्ड सही नहीं है।';
      case 'email-already-in-use':
        return 'इस ईमेल से अकाउंट पहले से बना हुआ है।';
      case 'weak-password':
        return 'कम-से-कम 8 अक्षरों का मजबूत पासवर्ड रखें।';
      case 'too-many-requests':
        return 'बहुत अधिक प्रयास हुए हैं। कुछ देर बाद फिर कोशिश करें।';
      case 'network-request-failed':
        return 'इंटरनेट कनेक्शन जाँचें और फिर कोशिश करें।';
      case 'operation-not-allowed':
        return 'Firebase Console में Email/Password sign-in चालू करना बाकी है।';
      default:
        return error.message ?? 'अभी अनुरोध पूरा नहीं हुआ। फिर कोशिश करें।';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final auth = FirebaseAuth.instance;
      if (_createAccount) {
        final result = await auth.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
        await result.user?.sendEmailVerification();
        if (mounted) {
          setState(() {
            _message = 'अकाउंट बन गया। ईमेल में भेजे गए verification link को खोलें।';
            _messageIsError = false;
          });
        }
      } else {
        await auth.signInWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() {
          _message = _friendlyError(error);
          _messageIsError = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _message = 'अनुरोध पूरा नहीं हो सका। इंटरनेट और Firebase सेटअप जाँचें।';
          _messageIsError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _message = 'पासवर्ड रीसेट करने के लिए पहले सही ईमेल लिखें।';
        _messageIsError = true;
      });
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        setState(() {
          _message = 'पासवर्ड रीसेट लिंक आपके ईमेल पर भेज दिया गया है।';
          _messageIsError = false;
        });
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() {
          _message = _friendlyError(error);
          _messageIsError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!FirebaseConfig.initialized) {
      final detail = FirebaseConfig.initializationError;
      return Scaffold(
        appBar: AppBar(title: const Text('यूज़र अकाउंट')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(Icons.cloud_off_outlined, size: 58, color: Colors.brown),
            const SizedBox(height: 12),
            const Text(
              'लॉगिन सेटअप अभी पूरा नहीं हुआ है',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Firebase project वेद रहस्य के लिए बनाया गया है। ऐप का Android registration और Email/Password provider चालू होने के बाद सुरक्षित लॉगिन उपलब्ध होगा। अभी आपकी स्थानीय सुविधाएँ बिना लॉगिन चलती रहेंगी।',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.5),
            ),
            if (detail != null) ...[
              const SizedBox(height: 12),
              Text('Firebase initialization error: $detail',
                  style: const TextStyle(color: Colors.red, fontSize: 12)),
            ],
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Firebase Console में Android app package name com.vedrahasya.ved_rahasya से register करें। फिर FIREBASE_API_KEY और FIREBASE_ANDROID_APP_ID को GitHub Actions secrets में जोड़ें।',
                  style: TextStyle(height: 1.5),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('वेद रहस्य अकाउंट')),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (user != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_user_outlined,
                        size: 58, color: Colors.green),
                    const SizedBox(height: 12),
                    const Text('आप लॉगिन हैं',
                        style: TextStyle(
                            fontSize: 21, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SelectableText(user.email ?? ''),
                    const SizedBox(height: 8),
                    Text(user.emailVerified
                        ? 'ईमेल सत्यापित है'
                        : 'ईमेल सत्यापन बाकी है'),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _busy
                          ? null
                          : () => FirebaseAuth.instance.signOut(),
                      icon: const Icon(Icons.logout),
                      label: const Text('लॉगआउट'),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Icon(Icons.account_circle_outlined,
                  size: 58, color: Color(0xFF754414)),
              const SizedBox(height: 10),
              Text(
                _createAccount ? 'नया अकाउंट बनाएँ' : 'अपने अकाउंट में लॉगिन करें',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'ईमेल पता',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (!text.contains('@') || text.endsWith('@')) {
                          return 'सही ईमेल पता लिखें।';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: _hidePassword,
                      autofillHints: _createAccount
                          ? const [AutofillHints.newPassword]
                          : const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'पासवर्ड',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                              () => _hidePassword = !_hidePassword),
                          icon: Icon(_hidePassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                      ),
                      validator: (value) {
                        if ((value ?? '').length < 8) {
                          return 'पासवर्ड कम-से-कम 8 अक्षरों का रखें।';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              if (_message != null) ...[
                const SizedBox(height: 12),
                Text(
                  _message!,
                  style: TextStyle(
                      color: _messageIsError ? Colors.red : Colors.green,
                      height: 1.4),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_createAccount ? 'अकाउंट बनाएँ' : 'लॉगिन करें'),
              ),
              if (!_createAccount)
                TextButton(
                  onPressed: _busy ? null : _resetPassword,
                  child: const Text('पासवर्ड भूल गए?'),
                ),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => setState(() {
                          _createAccount = !_createAccount;
                          _message = null;
                        }),
                child: Text(_createAccount
                    ? 'पहले से अकाउंट है? लॉगिन करें'
                    : 'नया अकाउंट बनाएँ'),
              ),
            ],
          );
        },
      ),
    );
  }
}
