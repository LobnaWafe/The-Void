import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_void/core/services/custom_bloc_observer.dart';
import 'package:the_void/core/utlis/app_router.dart';
import 'package:the_void/core/utlis/get_it.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
     Bloc.observer = CustomBlocObserver();
  
 SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

    setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
       routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    //  title: 'Flutter Demo',
     theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        // الطريقة الصحيحة لتعيين خط GoogleFonts كخط أساسي للتطبيق بالكامل
        textTheme: GoogleFonts.chakraPetchTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
      ),
    //  home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
