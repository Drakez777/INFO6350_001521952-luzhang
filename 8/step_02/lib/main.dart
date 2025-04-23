// lib/main.dart

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'home_page.dart';

/// 1) GoRouter configuration with sign-in and profile routes
final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        /// /sign-in
        GoRoute(
          path: 'sign-in',
          builder: (context, state) {
            return SignInScreen(
              actions: [
                ForgotPasswordAction((context, email) {
                  final uri = Uri(
                    path: '/sign-in/forgot-password',
                    queryParameters: {'email': email},
                  );
                  context.push(uri.toString());
                }),
                AuthStateChangeAction((context, authState) {
                  final user = switch (authState) {
                    SignedIn state => state.user,
                    UserCreated state => state.credential.user,
                    _ => null,
                  };
                  if (user == null) return;
                  if (authState is UserCreated) {
                    user.updateDisplayName(user.email!.split('@')[0]);
                  }
                  if (!user.emailVerified) {
                    user.sendEmailVerification();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please check your email to verify your address',
                        ),
                      ),
                    );
                  }
                  context.pushReplacement('/');
                }),
              ],
            );
          },
          routes: [
            /// /sign-in/forgot-password
            GoRoute(
              path: 'forgot-password',
              builder: (context, state) {
                final email = state.uri.queryParameters['email'];
                return ForgotPasswordScreen(
                  email: email,
                  headerMaxExtent: 200,
                );
              },
            ),
          ],
        ),

        /// /profile
        GoRoute(
          path: 'profile',
          builder: (context, state) => ProfileScreen(
            providers: const [],
            actions: [
              SignedOutAction((context) {
                context.pushReplacement('/');
              }),
            ],
          ),
        ),
      ],
    ),
  ],
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ApplicationState(),
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Firebase Meetup',
      theme: ThemeData(
        useMaterial3: true,
        buttonTheme: Theme.of(context)
            .buttonTheme
            .copyWith(highlightColor: Colors.deepPurple),
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routerConfig: _router,
    );
  }
}