import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/presentation/login_screen.dart';
import 'shared/services/auth_service.dart';
import 'features/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  await dotenv.load(fileName: ".env");
  
  await supabase.Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: const supabase.FlutterAuthClientOptions(
      authFlowType: supabase.AuthFlowType.pkce,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        authService: AuthService(),
        supabaseClient: supabase.Supabase.instance.client,
      )..add(AuthCheckRequested()),
      child: MaterialApp(
        title: 'Tickt',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return const HomeScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}