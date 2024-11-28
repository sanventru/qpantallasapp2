import 'dart:io';
// import 'dart:js';
// import 'dart:typed_data';
// import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
//import 'package:video_viewer/video_viewer.dart';
import 'dart:convert' as convert;
import 'package:video_player/video_player.dart';

// import '../screens/config.dart';
// import 'package:image/image.dart' as im;
// import 'package:flutter_startup/flutter_startup.dart';
import 'package:pausable_timer/pausable_timer.dart';
import '../globals.dart' as globals;
import 'package:restart_app/restart_app.dart';

class Pantalla2ctrl extends GetxController {
  VideoPlayerController? videoController;

  bool isPlaying = false;
  bool actualizando = false;
  static var httpClient = new HttpClient();
  bool vervideo = false;
  bool verimagen = false;
  // String urlbase = 'http://164.90.148.158:5000';
  String urlbase = globals.urlbase;
  var texto = ''.obs;
  String url = '${globals.urlbase}/screens/basic/default';
  String orientacion = 'vertical';
  var cambio = ''.obs;
  var rotado = 0.obs;
  List zonas = [];
  int periodictime = 3;
  late Timer timerp;
  late final PausableTimer timer;
  var countDown = 5;
  final isVideoComplete = false.obs;

  @override
  void onClose() {
    videoController?.dispose();
    super.onClose();
  }

   void _initVideoController(String path) {
    videoController?.dispose();
    videoController = VideoPlayerController.file(File(path))
      ..initialize().then((_) {
        videoController?.play();
        videoController?.addListener(_onVideoStateChange);
      });
  }

  Widget mostrarw = Center(
    child: Text(
      'Iniciando bucle.....',
      style: TextStyle(color: Colors.white),
    ),
  );


    void _onVideoStateChange() {
     if (videoController?.value.isPlaying == false && 
        videoController?.value.position == videoController?.value.duration) {
      isVideoComplete.value = true;
      periodictime = 0;
    }
  }

  onReady() {

       // Inicializar el video controller
    // videoController = CustomVideoPlayerController();
    // Agregar listener para el estado del video
    videoController?.addListener(_onVideoStateChange);
    print('Pantalla2ctrl onReady');
    final box = GetStorage();
    try {
      if (box.read('qpantallas_zonas') != null) {
        zonas = box.read('qpantallas_zonas');
      }
      // box.write('zonas', zonas);
    } catch (e) {
      // zonas = [];
      print((e.toString()));
    }

    // print(zonas);
    // print(zonas[0]['assets'][0]['content']['file_url']);
    // "/static/user_files/post_images/cb24ef1e-3591-4c8c-bcc3-36ce053d1f0dNUEVO_MENU_TERMINALOUTLINES_360-02.jpg"
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
    String v;
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
      // inicio();
      startTimer();
      // compruebacambioszona();
    }
  }



  inicio() async {
    compute(startTimer(), periodictime);
  }

  startTimer() {
    // el 8 cambiar por una variable global que se actualiza al igual que zona[imagen]

    timer = PausableTimer(
      Duration(seconds: 1),
      () {
        if (vervideo && !isVideoComplete.value) {
          timer..reset()..start();
          return;
        }
        periodictime--;
        if (periodictime > 0) {
          timer
            ..reset()
            ..start();
        } else {
          periodictime = 3;
          try {
            if (zonas[0]['assets'].length == 0) {
              ping();
            }
            bool antesvideo = false;
            for (var i = 0; i < zonas.length; i++) {
              if (zonas[i]['imagenindex'] + 1 < zonas[i]['assets'].length) {
                if (zonas[i]['imagen'].toString().contains('mp4') ||
                    zonas[i]['imagen'].toString().contains('.mov')) {
                  String futurovideo = zonas[i]['assets']
                      [zonas[i]['imagenindex'] + 1]['content']['file'];
                  if (futurovideo.contains('mp4') ||
                      futurovideo.contains('.mov')) {
                    antesvideo = true;
                    zonas[i]['imagen'] = 'test.png';
                    antesvideo = true;
                    zonas[i]['imagenindex'] = zonas[i]['imagenindex'];
                  } else {
                    // if (zonas[i]['imagenindex'] ==
                    //     zonas[i]['assets'].length - 1) {
                    //   zonas[i]['imagenindex'] = zonas[i]['imagenindex'] - 1;
                    // }
                    zonas[i]['imagenindex'] = zonas[i]['imagenindex'] + 1;
                  }
                } else {
                  zonas[i]['imagenindex'] = zonas[i]['imagenindex'] + 1;
                }
              } else {
                String futurovideo = zonas[i]['assets'][0]['content']['file'];
                if (futurovideo.contains('mp4') ||
                    futurovideo.contains('.mov')) {
                  antesvideo = true;
                  zonas[i]['imagen'] = 'test.png';
                  antesvideo = true;
                  zonas[i]['imagenindex'] = -1;
                } else {
                  zonas[i]['imagenindex'] = 0;
                }
                cargahtml(false);
                ping();
              }
              if (antesvideo) {
                periodictime = 0;
              } else {
                periodictime = int.parse((zonas[i]['assets']
                            [zonas[i]['imagenindex']]['display_time'] /
                        1000)
                    .toString()
                    .split('.')[0]);
              }

              if (!antesvideo) {
                zonas[i]['imagen'] = zonas[i]['assets'][zonas[i]['imagenindex']]
                    ['content']['file'];
              } else {
                vervideo = false;
                verimagen = true;
              }

              if (zonas[i]['imagen'].toString().contains('.mp4') ||
                  zonas[i]['imagen'].toString().contains('.mov')) {
                vervideo = true;
                verimagen = false;
                isVideoComplete.value = false; 
                 _initVideoController(zonas[i]['imagen']);
                // mostrarw = CustomVideoPlayer(
                //   videoPath: (zonas[i]['imagen']),
                //   showControls: true, // Si quieres mostrar controles o no
                //   controller: videoController,
                // );
                // periodictime = 10;
                    mostrarw = AspectRatio(
                  aspectRatio: 16/9,
                  child: VideoPlayer(videoController!),
                );
                // VideoViewerController controller = VideoViewerController();
                // controllerg = controller;
                // controller.addListener(listenToPlayingChanges);
                // mostrarw = VideoViewer(
                //   controller: controllerg,
                //   autoPlay: true,
                //   // looping: true,
                //   source: {
                //     "${zonas[i]['imagen']}": VideoSource(
                //       video:
                //           VideoPlayerController.file(File(zonas[i]['imagen'])),
                //     )
                //   },

                //   // onFullscreenFixLandscape: true,
                //   // enableFullscreenScale: false,
                //   // defaultAspectRatio: 1 / 1,
                //   style: VideoViewerStyle(
                //     loading: Text(
                //       '',
                //       style: const TextStyle(color: Colors.black),
                //     ),
                //   ),
                //   enableShowReplayIconAtVideoEnd: false,
                // );
                // if (controllerg.video != null) {
                //   controllerg.play();
                // }
              } else {
                vervideo = false;
                verimagen = true;
                if (antesvideo) {
                  mostrarw = Text('',
                      style: TextStyle(
                        color: Colors.black,
                      ));
                } else {
                  mostrarw = ExtendedImage.file(
                    File(zonas[i]['imagen']),
                    fit: BoxFit.cover,
                  );
                }
              }

              print(
                  '${zonas[i]['imagenindex']} : ${zonas[i]['imagen']} : $periodictime');
              cambio.value =
                  '${DateTime.now().toString()} __   ${zonas[i]['imagenindex']} : ${zonas[i]['imagen']} : $periodictime ';
            }
            timer.reset();
            timer.start();
            // timer
            //   ..reset()
            //   ..start();
          } catch (e) {
            timer.reset();
            timer.start();
            periodictime = 3;
          }
        }
        print('\t$periodictime');
      },
    )..start();
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
      // print('errrrrrrrooooooooor de ping');
      box.write('qpantalla_url', '${globals.urlbase}/screens/basic/default');
      urlt = '${globals.urlbase}screens/basic/default';
    }
    String namepantalla = urlt.split('/').last;

    var urlping = Uri.parse(urlbase + '/screensping/' + namepantalla); //esto es para ver si se rei
    try {
      var resp = await http.get(urlping);
      if (resp.statusCode == 200) {
        if (resp.body == 'si') {
          box.write('qhash', '');
          cargahtml(true);

          // box.write('qpantallas_zonas', []);
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
        // print(id1);
        var url = Uri.parse(urlbase + '/screens/json/' + id1.toString());
        final box = GetStorage();
        var resp = await http.get(url);

        if (resp.statusCode == 200) {
          hash1 += resp.body.hashCode;
          var infozonas = convert.jsonDecode(resp.body);
          List zonast = infozonas['screen']['zones'];
          // box.write('qpantallas_zonas', zonas);
          for (var i = 0; i < zonast.length; i++) {
            var z = zonast[i];

            List feeds = z['feeds'];
            String feedstring = '[';
            for (var j = 0; j < feeds.length; j++) {
              feedstring = feedstring + feeds[j].toString() + ',';
            }
            ;
            feedstring = feedstring.substring(0, feedstring.length - 1) + ']';
            url = Uri.parse(urlbase + '/screens/posts_from_feeds/$feedstring');
            var resp1 = await http.get(url);
            List assests = [];
            if (resp1.statusCode == 200) {
              hash1 += resp1.body.hashCode;
              var posts = convert.jsonDecode(resp1.body)['posts'];
              for (var k = 0; k < posts.length; k++) {
                var p = posts[k];
                var resp2 = await http.get(Uri.parse(
                    urlbase + '/posts/' + p['id'].toString() + '/json'));
                if (resp2.statusCode == 200) {
                  hash1 += resp2.body.hashCode;
                  var post = convert.jsonDecode(resp2.body);
                  // String fileurl = urlbase + post['content']['file_url'];
                  // String filep = await downloadFile(
                  //     fileurl, post['content']['filename'].toString());
                  // post['content']['file'] = filep;
                  assests.add(post);
                }
              }
              ;
            }
            z['assets'] = assests;
            // z['imagen'] = assests.length > 0
            //     ? urlbase + assests[0]['content']['file_url']
            //     : '';
            z['imagen'] =
                assests.isNotEmpty ? assests[0]['content']['file'] : '';
            z['imagenindex'] = 0;
            // if (z['hash'] != hash1.toString()) {}
          }
          ;
          String hash0 = box.read('qhash');
          print('hashes son diferentes?');
          print(hash1.toString() != hash0);
          print('actualizandoooooooooo     $actualizando');
          if (hash1.toString() != hash0 && actualizando == false) {
            actualizando = true;
            print('empieza a descargar ##########################');
            await descargarporcambios(zonast, hash1, reiniciar);
          }
          // box.write('qpantallas_zonas', zonast);
          try {
            var zonastempp = box.read('qpantallas_zonas');
            zonas = zonastempp;
            if (reiniciar) {
               Restart.restartApp();
            }
          } catch (e) {
            try {
              if (zonas.length == 0) {
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
          // String as_url = urlbase + zt['assets'][k]['content']['file_url'];
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
      ;
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
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
