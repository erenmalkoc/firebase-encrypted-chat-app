import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants/app_constants.dart';
import 'constants/color_constants.dart';
import 'pages/pages.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) =>
              AuthProvider(
                firebaseAuth: FirebaseAuth.instance,
                googleSignIn: GoogleSignIn(),
                prefs: prefs,
                firebaseFirestore: firebaseFirestore,
              ),
        ),
        Provider<SettingProvider>(
          create: (_) =>
              SettingProvider(
                prefs: prefs,
                firebaseFirestore: firebaseFirestore,
                firebaseStorage: firebaseStorage,
              ),
        ),
        Provider<HomeProvider>(
          create: (_) =>
              HomeProvider(
                firebaseFirestore: firebaseFirestore,
              ),
        ),
        Provider<ChatProvider>(
          create: (_) =>
              ChatProvider(
                prefs: prefs,
                firebaseFirestore: firebaseFirestore,
                firebaseStorage: firebaseStorage,
              ),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appTitle,
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: ColorConstants.themeColor,
          primarySwatch: MaterialColor(0xfff5a623, ColorConstants.swatchColor),
        ),
        home: SplashPage(),
        debugShowCheckedModeBanner: false,

      ),
    );
  }
}
