import 'dart:io';

// import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
// import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter/services.dart';
// import 'dart:ui';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../globals.dart' as globals;

import 'package:path_provider/path_provider.dart';
// import 'package:image_picker_saver/image_picker_saver.dart';

// import 'package:flutter_html/flutter_html.dart';
// import 'package:html/parser.dart' as htmlparser;

class Configctrl extends GetxController {
  String imgprueba =
      '/data/user/0/com.example.qpant/app_flutter/1dec08df-92f3-45b6-a742-d53b59109ed302_expresso.webp';
  String urlprueba =
      '${globals.urlbase}/static/user_files/post_images/f47f62ce-ee95-4b2a-baa0-8632f188f6ee02_A-Board_collage-espresso_2.mp4';
  // String urlbase = 'http://164.90.148.158:5000';
  String urlbase = globals.urlbase;
  static var httpClient = new HttpClient();
  String url = '';
  String orientacion = 'vertical';
  var cambio = ''.obs;
  var rotado = 0.obs;
  TextEditingController txturl =
      TextEditingController(text: '${globals.urlbase}/screens/basic/default');
  onReady() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    print('Iniciando config');

    final box = GetStorage();
    try {
      txturl.text = box.read('qpantalla_url');
      orientacion = box.read('qpantalla_orientacion');
      setorientacion(orientacion);
      cambio.value = txturl.text;
    } catch (e) {}
  }

  seturl() async {
    // String i = await downloadFile(urlprueba, 'test.jpg');
    final box = GetStorage();
    box.write('qpantalla_url', txturl.text);
    await cargahtml();
    Get.defaultDialog(title: 'Mensaje', content: Text('Url almacenada'));
    cambio.value = url;
  }

  ///save network image to photo
  // Future<bool> saveNetworkImageToPhoto(String url,
  //     {bool useCache: false}) async {
  //   var data = await getNetworkImageData(url, useCache: useCache);
  //   var filePath = await ImagePickerSaver.saveFile(fileData: data);
  //   return filePath != null && filePath != "";
  // }

  cargahtml() async {
    EasyLoading.show(status: 'Cargando...');
    try {
      int hash1 = 0;
      var response = await http.get(Uri.parse(txturl.text));
      if (response.statusCode == 200) {
        hash1 = response.body.hashCode;
        String data = response.body;
        var id0 = data.split('"id":')[1];
        var id1 = id0.split(',')[0].toString().trim();
        print(id1);
        var url = Uri.parse(urlbase + '/screens/json/' + id1.toString());
        final box = GetStorage();
        var resp = await http.get(url);
        if (resp.statusCode == 200) {
          hash1 += resp.body.hashCode;
          var infozonas = convert.jsonDecode(resp.body);
          List zonas = infozonas['screen']['zones'];
          // box.write('qpantallas_zonas', zonas);
          for (var i = 0; i < zonas.length; i++) {
            var z = zonas[i];

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
                  print(post);
                  String fileurl = urlbase + post['content']['file_url'];
                  String filep = await downloadFile(
                      fileurl, post['content']['filename'].toString());
                  post['content']['file'] = filep;
                  if (filep.toString().contains('.mp4') ||
                      filep.toString().contains('.mov')) {
                    post['display_time'] = 1000;
                  }

                  assests.add(post);
                }
              }
              ;
            }

            z['assets'] = assests;
            z['imagen'] =
                assests.length > 0 ? assests[0]['content']['file'] : '';
            z['imagenindex'] = 0;
          }
          ;
          // print(zonas);
          List zonaslocales = [];

          box.write('qhash', hash1.toString());

          box.write('qpantallas_zonas', zonas);
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {}
    EasyLoading.dismiss();
  }

  Future<String> downloadFile(String url, String filename) async {
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = File('$dir/$filename');
    await file.writeAsBytes(bytes);
    if (await file.exists()) {
      print("File exists");
      print(file.length());
    } else {
      print("File don't exists");
    }
    return file.path;
  }

  setorientacion(v) {
    final box = GetStorage();
    // List z = box.read('qpantallas_zonas');
    // z.forEach((element) {
    //   element['assets'].forEach((e) {
    //     print(e['content']['file']);
    //   });
    // });

    box.write('qpantalla_orientacion', v);
    cambio.value = url;

    if (v == 'vertical') {
      rotado.value = 1;
    } else {
      rotado.value = 0;
    }
    cambio.value = DateTime.now().toString();
  }
}
