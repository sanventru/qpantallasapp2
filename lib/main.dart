import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
// import '../screens/config.dart';
import 'package:get_storage/get_storage.dart';
import '../screens/pantalla2.dart';

void main() async {
  await GetStorage.init();
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]).then((_) {
  //   runApp(MyApp());
  // });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Qpantallas',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        hintColor: Colors.pink,

        // brightness: Brightness.light,
      ),
      home: Pantalla2(),
      builder: EasyLoading.init(),
    );
  }
}
