import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert' as convert;
import 'package:video_player/video_player.dart';
import 'package:pausable_timer/pausable_timer.dart';
import '../globals.dart' as globals;
import 'package:restart_app/restart_app.dart';

class Pantalla2ctrl extends GetxController {
  Map<int, VideoPlayerController?> videoControllers = {};
  Map<int, Widget> zonasWidgets = {};
  
  bool actualizando = false;
  static var httpClient = HttpClient();
  String urlbase = globals.urlbase;
  var texto = ''.obs;
  String url = '${globals.urlbase}/screens/basic/default';
  String orientacion = 'vertical';
  var cambio = ''.obs;
  var rotado = 0.obs;
  List zonas = [];
  Map<int, bool> verVideo = {};
  Map<int, bool> verImagen = {};
  Map<int, bool> isVideoComplete = {};
  // int periodictime = 3;
    Map<int, int> periodictimes = {};  
  late final PausableTimer timer;

  @override
  void onClose() {
    for (var controller in videoControllers.values) {
      controller?.dispose();
    }
    super.onClose();
  }

  void _initVideoController(String path, int zoneIndex) {
    videoControllers[zoneIndex]?.dispose();
    videoControllers[zoneIndex] = VideoPlayerController.file(File(path))
      ..initialize().then((_) {
        videoControllers[zoneIndex]?.play();
        videoControllers[zoneIndex]?.addListener(() => _onVideoStateChange(zoneIndex));
      });
  }

  void _onVideoStateChange(int zoneIndex) {
    var controller = videoControllers[zoneIndex];
    if (controller == null) return;

    // Si el video terminó
    if (!controller.value.isPlaying && 
        controller.value.position >= controller.value.duration) {
      print('Video completado en zona $zoneIndex');
      isVideoComplete[zoneIndex] = true;
      periodictimes[zoneIndex] = 0;  // Forzar actualización inmediata
      cambio.value = DateTime.now().toString();  // Forzar actualización de UI
    }
  }

  Widget buildZoneWidget(int zoneIndex, Map zonaData) {
    if (verVideo[zoneIndex] == true) {
      return AspectRatio(
        aspectRatio: 16/9,
        child: VideoPlayer(videoControllers[zoneIndex]!),
      );
    } else if (verImagen[zoneIndex] == true) {
      if (zonaData['imagen'].toString().isEmpty) {
        return const SizedBox.shrink();
      }
      return ExtendedImage.file(
        File(zonaData['imagen']),
        fit: BoxFit.cover,
      );
    }
    return const Center(
      child: Text(
        'Iniciando bucle.....',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  onReady() {
    print('Pantalla2ctrl onReady');
    final box = GetStorage();
    try {
      if (box.read('qpantallas_zonas') != null) {
        zonas = box.read('qpantallas_zonas');
        // Inicializar los mapas para cada zona
        for (var i = 0; i < zonas.length; i++) {
          verVideo[i] = false;
          verImagen[i] = false;
          isVideoComplete[i] = false;
          periodictimes[i] = 3; 
          zonasWidgets[i] = buildZoneWidget(i, zonas[i]);
        }
      }
    } catch (e) {
      print((e.toString()));
    }

    var hayzona = false;
    try {
      if (box.read('qpantalla_url') != null) {
        url = box.read('qpantalla_url');
        hayzona = true;
      }
      box.write('qpantalla_url', url);
    } catch (e) {
      print('errrrrrrrooooooooor');
    }

    try {
      if (box.read('qpantalla_orientacion') != null) {
        orientacion = box.read('qpantalla_orientacion');
      }
      box.write('qpantallas_orientacion', orientacion);
    } catch (e) {
      box.write('qpantalla_orientacion', 'vertical');
      orientacion = 'vertical';
    }

    if (orientacion == 'vertical') {
      rotado.value = 1;
    } else {
      rotado.value = 0;
    }
    
    if (hayzona) {
      startTimer();
    }
  }

  startTimer() {
    timer = PausableTimer(
      const Duration(seconds: 1),
      () {
        bool anyVideoPlaying = false;
         // Primero verificamos videos en reproducción
        for (var i = 0; i < zonas.length; i++) {
          if (verVideo[i] == true) {
            // Si el video está completo, lo marcamos para actualizar
            if (isVideoComplete[i] == true) {
              periodictimes[i] = 0;
            } else {
              // Si el video está reproduciéndose, no decrementamos su tiempo
              anyVideoPlaying = true;
              // Verificar si el video está efectivamente reproduciéndose
              if (videoControllers[i]?.value.isPlaying == true) {
                print('Video reproduciéndose en zona $i');
                timer..reset()..start();
                return;
              }
            }
          }
        }

        // if (anyVideoPlaying) {
        //   timer..reset()..start();
        //   return;
        // }

         if (!anyVideoPlaying) {
          bool needsUpdate = false;

          // Actualizar tiempos y determinar si continuar
        for (var i = 0; i < zonas.length; i++) {
          if (periodictimes[i]! > 0) {
            periodictimes[i] = periodictimes[i]! - 1;
            print('periodictimes[i] ${periodictimes[i]}');
            // shouldContinue = true;
          }
            // Si alguna zona llegó a 0, necesitamos actualizar
            if (periodictimes[i] == 0) {
              needsUpdate = true;
            }
        }

          if (needsUpdate) {
            for (var i = 0; i < zonas.length; i++) {
              if (periodictimes[i] == 0) {
                updateZone(i);
              }
            }
          }
        }

       // Reiniciar el timer
        timer..reset()..start();
        cambio.value = DateTime.now().toString();
      },
    )..start();
  }

  void updateZone(int zoneIndex) {
    if (zonas[zoneIndex]['assets'].isEmpty) return;

      // Limpiar estado anterior
    verVideo[zoneIndex] = false;
    verImagen[zoneIndex] = false;
    isVideoComplete[zoneIndex] = false;

    bool antesvideo = false;
    var zona = zonas[zoneIndex];

    if (zona['imagenindex'] + 1 < zona['assets'].length) {
      if (zona['imagen'].toString().contains('mp4') ||
          zona['imagen'].toString().contains('.mov')) {
        String futurovideo = zona['assets'][zona['imagenindex'] + 1]['content']['file'];
        if (futurovideo.contains('mp4') || futurovideo.contains('.mov')) {
          antesvideo = true;
          zona['imagen'] = 'test.png';
          zona['imagenindex'] = zona['imagenindex'];
        } else {
          zona['imagenindex'] = zona['imagenindex'] + 1;
        }
      } else {
        zona['imagenindex'] = zona['imagenindex'] + 1;
      }
    } else {
      String futurovideo = zona['assets'][0]['content']['file'];
      if (futurovideo.contains('mp4') || futurovideo.contains('.mov')) {
        antesvideo = true;
        zona['imagen'] = 'test.png';
        zona['imagenindex'] = -1;
      } else {
        zona['imagenindex'] = 0;
      }
      cargahtml(false);
      ping();
    }

    if (antesvideo) {
      periodictimes[zoneIndex] = 0;
    } else {
       periodictimes[zoneIndex] = int.parse((zona['assets'][zona['imagenindex']]['display_time'] / 1000)
          .toString()
          .split('.')[0]);
    }

   if (!antesvideo) {
      zona['imagen'] = zona['assets'][zona['imagenindex']]['content']['file'];
      // Establecer tiempo para imágenes
      periodictimes[zoneIndex] = int.parse(
        (zona['assets'][zona['imagenindex']]['display_time'] / 1000)
          .toString()
          .split('.')[0]
      );
    }

    if (zona['imagen'].toString().contains('.mp4') ||
        zona['imagen'].toString().contains('.mov')) {
      verVideo[zoneIndex] = true;
      verImagen[zoneIndex] = false;
      isVideoComplete[zoneIndex] = false;
      print('reproduciendo video@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
      _initVideoController(zona['imagen'], zoneIndex);
    } else {
      verVideo[zoneIndex] = false;
      verImagen[zoneIndex] = true;
    }

    zonasWidgets[zoneIndex] = buildZoneWidget(zoneIndex, zona);
    
    print('${zona['imagenindex']} : ${zona['imagen']} : ${periodictimes[zoneIndex]}');
    cambio.value = '${DateTime.now().toString()} __   ${zona['imagenindex']} : ${zona['imagen']} : $periodictimes[zoneIndex] ';
  }

  checkexists(path) async {
    if (await File(path).exists()) {
      print("File exists");
    } else {
      print("File don't exists");
    }
  }

  ping() async {
    final box = GetStorage();
    String urlt = '';
    try {
      urlt = box.read('qpantalla_url');
    } catch (e) {
      box.write('qpantalla_url', '${globals.urlbase}/screens/basic/default');
      urlt = '${globals.urlbase}screens/basic/default';
    }
    String namepantalla = urlt.split('/').last;

    var urlping = Uri.parse('$urlbase/screensping/$namepantalla');
    try {
      var resp = await http.get(urlping);
      if (resp.statusCode == 200) {
        if (resp.body == 'si') {
          box.write('qhash', '');
          cargahtml(true);
        }
        print('ping ok');
      } else {
        print('ping error');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  cargahtml(reiniciar) async {
    try {
      final box = GetStorage();
      if (box.read('qpantalla_url') != null) {
        url = box.read('qpantalla_url');
      }
      box.write('qpantalla_url', url);
    } catch (e) {
      print('errrrrrrrooooooooor');
    }
    try {
      var response = await http.get(Uri.parse(url));
      int hash1 = 0;

      if (response.statusCode == 200) {
        hash1 = response.body.hashCode;
        String data = response.body;
        var id0 = data.split('"id":')[1];
        var id1 = id0.split(',')[0].toString().trim();
        var url = Uri.parse('$urlbase/screens/json/$id1');
        final box = GetStorage();
        var resp = await http.get(url);

        if (resp.statusCode == 200) {
          hash1 += resp.body.hashCode;
          var infozonas = convert.jsonDecode(resp.body);
          List zonast = infozonas['screen']['zones'];
          
          for (var i = 0; i < zonast.length; i++) {
            var z = zonast[i];
            List feeds = z['feeds'];
            String feedstring = '[';
            for (var j = 0; j < feeds.length; j++) {
              feedstring = '$feedstring${feeds[j]},';
            }
            feedstring = '${feedstring.substring(0, feedstring.length - 1)}]';
            url = Uri.parse('$urlbase/screens/posts_from_feeds/$feedstring');
            var resp1 = await http.get(url);
            List assests = [];
            
            if (resp1.statusCode == 200) {
              hash1 += resp1.body.hashCode;
              var posts = convert.jsonDecode(resp1.body)['posts'];
              for (var k = 0; k < posts.length; k++) {
                var p = posts[k];
                var resp2 = await http.get(Uri.parse(
                    '$urlbase/posts/${p['id']}/json'));
                if (resp2.statusCode == 200) {
                  hash1 += resp2.body.hashCode;
                  var post = convert.jsonDecode(resp2.body);
                  assests.add(post);
                }
              }
            }
            z['assets'] = assests;
            z['imagen'] = assests.isNotEmpty ? assests[0]['content']['file'] : '';
            z['imagenindex'] = 0;
          }

          String hash0 = box.read('qhash');
          print('hashes son diferentes?');
          print(hash1.toString() != hash0);
          print('actualizandoooooooooo     $actualizando');
          
          if (hash1.toString() != hash0 && actualizando == false) {
            actualizando = true;
            print('empieza a descargar ##########################');
            await descargarporcambios(zonast, hash1, reiniciar);
          }

          try {
            var zonastempp = box.read('qpantallas_zonas');
            zonas = zonastempp;
            // Reinicializar los widgets de zona después de actualizar zonas
            for (var i = 0; i < zonas.length; i++) {
              zonasWidgets[i] = buildZoneWidget(i, zonas[i]);
            }
            if (reiniciar) {
              Restart.restartApp();
            }
          } catch (e) {
            try {
              if (zonas.isEmpty) {
                zonas = [];
              }
            } catch (e) {
              zonas = [];
            }
          }
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  descargarporcambios(List zonast, hashnuevo, reiniciar) async {
    try {
      final box = GetStorage();
      for (var i = 0; i < zonast.length; i++) {
        var zt = zonast[i];
        for (var k = 0; k < zt['assets'].length; k++) {
          String filep = await downloadFile(
              urlbase + zt['assets'][k]['content']['file_url'],
              zt['assets'][k]['content']['filename'].toString());
          zt['assets'][k]['content']['file'] = filep;
          if (filep.toString().contains('.mp4') ||
              filep.toString().contains('.mov')) {
            zt['assets'][k]['display_time'] = 1000;
          }
        }
      }
      if (zonast[0]['assets'].length > 0) {
        box.write('qhash', hashnuevo.toString());
        box.write('qpantallas_zonas', zonast);
        if (reiniciar) {
          Restart.restartApp();
        }
      }
    } catch (e) {
      print('error en la desscarga $e');
    }
    actualizando = false;
  }
  Future<String> downloadFile(String url, String filename) async {
    print('descargando fileeeeeeeeee');
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
