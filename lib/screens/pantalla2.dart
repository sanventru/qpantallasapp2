import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/state_manager.dart';
// import 'package:get_storage/get_storage.dart';
import '../controllers/pantalla2ctrl.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:auto_orientation/auto_orientation.dart';
// import 'package:extended_image/extended_image.dart';
// import 'package:image/image.dart' as im;
// import 'package:better_player/better_player.dart';
// import 'package:video_viewer/video_viewer.dart';

import 'config.dart';

class Pantalla2 extends StatefulWidget {
  Pantalla2({Key? key}) : super(key: key);

  @override
  _Pantalla2State createState() => _Pantalla2State();
}

class _Pantalla2State extends State<Pantalla2> {
  Pantalla2ctrl c = Pantalla2ctrl();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    // SystemChrome.setPreferredOrientations(
    //           [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    // c.controllerg.addListener(c.listenToPlayingChanges);
    c.onReady();
  }

  @override
  void dispose() {
    // c.controllerg.removeListener(c.listenToPlayingChanges);
    // c.controllerg.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // try {
    //   final box = GetStorage();
    //   c.zonas = box.read('qpantallas_zonas');
    // } catch (e) {
    //   c.zonas = [];
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => Config()),
    //   );
    //   print((e.toString()));
    // }

    var size = MediaQuery.of(context).size;
    if (c.zonas.length == 0) {
      return Scaffold(
        body: GestureDetector(
          onDoubleTap: () {
            Get.off(() => Config());
          },
          child: Center(
            child: Text('Ir a configuración'),
          ),
        ),
      );
    }
    return Obx(() {
      print(c.cambio.value);
      return SafeArea(
        child: GestureDetector(
          onDoubleTap: () {
            // c.timerp.cancel();
            c.timer.cancel();
            Get.off(() => Config());
          },
          // onTap: () {
          //   c.inicio();
          // },
          child: RotatedBox(
            quarterTurns: c.rotado.value,
            child: Scaffold(
              body: Container(
                color: Colors.black,
                child: Stack(
                  children: [
                    if (c.rotado.value == 1)
                      for (var i = 0; i < c.zonas.length; i++)
                        if (i > -1)
                          Positioned(
                              left: (double.parse(c.zonas[i]['left']
                                      .toString()
                                      .replaceAll('%', ''))) /
                                  100 *
                                  size.height,
                              right: (double.parse(c.zonas[i]['right']
                                      .toString()
                                      .replaceAll('%', ''))) /
                                  100 *
                                  size.height,
                              top:
                                  double.parse(c.zonas[i]['top'].toString().replaceAll('%', '')) /
                                      100 *
                                      size.width,
                              bottom: double.parse(c.zonas[i]['bottom']
                                      .toString()
                                      .replaceAll('%', '')) /
                                  100 *
                                  size.width,
                              child: Obx(() {
                                print(c.cambio.value);
                                return c.mostrarw;
                              })),
                    if (c.rotado.value == 0)
                      for (var i = 0; i < c.zonas.length; i++)
                        Positioned(
                            left: (double.parse(c.zonas[i]['left']
                                    .toString()
                                    .replaceAll('%', ''))) /
                                100 *
                                size.width,
                            right: (double.parse(c.zonas[i]['right']
                                    .toString()
                                    .replaceAll('%', ''))) /
                                100 *
                                size.width,
                            top:
                                double.parse(c.zonas[i]['top'].toString().replaceAll('%', '')) /
                                    100 *
                                    size.height,
                            bottom: double.parse(c.zonas[i]['bottom']
                                    .toString()
                                    .replaceAll('%', '')) /
                                100 *
                                size.height,
                            child: Obx(() {
                              print(c.cambio.value);
                              // print(
                              //     '************************************${c.zonas[i]['imagen']}**********************************');
                              return c.mostrarw;
                            }))
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
