import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'repositories/mock_repository.dart';
import 'repositories/data_repository.dart';
import 'services/auth_service.dart';
import 'screens/auth/splash_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<DataRepository>(
          create: (_) => MockRepository(),
        ),
        ChangeNotifierProxyProvider<DataRepository, AuthService>(
          create: (context) => AuthService(context.read<DataRepository>()),
          update: (context, repository, previous) => previous ?? AuthService(repository),
        ),
      ],
      child: const HostelMateApp(),
    ),
  );
}

class HostelMateApp extends StatelessWidget {
  const HostelMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HostelMate',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
