import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/state_manager.dart';
import '../controllers/pantalla2ctrl.dart';
import 'config.dart';

class Pantalla2 extends StatefulWidget {
  const Pantalla2({super.key});

  @override
  _Pantalla2State createState() => _Pantalla2State();
}

class _Pantalla2State extends State<Pantalla2> {
  Pantalla2ctrl c = Pantalla2ctrl();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    c.onReady();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    if (c.zonas.isEmpty) {
      return Scaffold(
        body: GestureDetector(
          onDoubleTap: () {
            Get.off(() => Config());
          },
          child: const Center(
            child: Text('Ir a configuración'),
          ),
        ),
      );
    }

    return SafeArea(
      child: GestureDetector(
        onDoubleTap: () {
          c.timer.cancel();
          Get.off(() => Config());
        },
        child: Obx(() {
          print(c.cambio.value);
          return RotatedBox(
            quarterTurns: c.rotado.value,
            child: Scaffold(
              body: Container(
                color: Colors.black,
                child: Stack(
                  children: [
                    // Cuando está rotado verticalmente
                    if (c.rotado.value == 1)
                      for (var i = 0; i < c.zonas.length; i++)
                        if (i > -1)
                          Positioned(
                            left: (double.parse(c.zonas[i]['left'].toString().replaceAll('%', ''))) / 100 * size.height,
                            right: (double.parse(c.zonas[i]['right'].toString().replaceAll('%', ''))) / 100 * size.height,
                            top: double.parse(c.zonas[i]['top'].toString().replaceAll('%', '')) / 100 * size.width,
                            bottom: double.parse(c.zonas[i]['bottom'].toString().replaceAll('%', '')) / 100 * size.width,
                            child: Obx(() {
                              print(c.cambio.value);
                              return c.zonasWidgets[i] ?? const SizedBox.shrink();
                            }),
                          ),
                    // Cuando está en horizontal
                    if (c.rotado.value == 0)
                      for (var i = 0; i < c.zonas.length; i++)
                        Positioned(
                          left: (double.parse(c.zonas[i]['left'].toString().replaceAll('%', ''))) / 100 * size.width,
                          right: (double.parse(c.zonas[i]['right'].toString().replaceAll('%', ''))) / 100 * size.width,
                          top: double.parse(c.zonas[i]['top'].toString().replaceAll('%', '')) / 100 * size.height,
                          bottom: double.parse(c.zonas[i]['bottom'].toString().replaceAll('%', '')) / 100 * size.height,
                          child: Obx(() {
                            print(c.cambio.value);
                            return c.zonasWidgets[i] ?? const SizedBox.shrink();
                          }),
                        ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}