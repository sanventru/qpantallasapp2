import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/confogctrl.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../screens/pantalla2.dart';
// import 'package:auto_orientation/auto_orientation.dart';

class Config_old extends StatelessWidget {
  final a = Get.put(Configctrl());

   Config_old({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Obx(() {
      print(a.cambio.value);
      return RotatedBox(
        quarterTurns: a.rotado.value,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Dunkin'),
            backgroundColor: Colors.orange,
          ),
          body: SafeArea(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Obx(() {
                    print(a.cambio.value);
                    return Column(
                      children: [
                        // Image.file(File(a.imgprueba)),
                        SizedBox(
                          width: size.width * 0.9,
                          // height: 20,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: size.height * 0.1,
                                width: size.width * 0.7,
                                child: TextField(
                                  controller: a.txturl,
                                  decoration: InputDecoration(
                                    label: const Text('url'),
                                    prefixIcon: IconButton(
                                        onPressed: () {
                                          a.txturl.clear();
                                        },
                                        icon: const Icon(
                                          Icons.clear,
                                          size: 20,
                                          color: Colors.red,
                                        )),
                                    // suffixIcon: IconButton(
                                    //     onPressed: a.seturl,
                                    //     icon: Icon(Icons.save)
                                    //     )
                                  ),
                                ),
                              ),
                              IconButton(
                                  onPressed: a.seturl, icon: const Icon(Icons.save))
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        DropdownSearch<String>(
                            // mode: Mode.MENU,
                            // showSelectedItem: true,
                            items:  (filter, infiniteScrollProps) =>
                      ["horizontal", "vertical"],
                            // label: "Orientación",
                            // hint: "Seleccione la orientación",
                            // popupItemDisabled: (String s) => s.startsWith('I'),
                            onChanged: (v) {
                              print(v);
                              a.setorientacion(v);
                            },
                            selectedItem: a.orientacion),
                        
                        const SizedBox(
                          height: 10,
                        ),
                        // TextButton(
                        //     onPressed: () {
                        //       Get.reloadAll();
                        //     },
                        //     child: Text('Recargar valores')),
                        const SizedBox(
                          height: 10,
                        ),
                        TextButton(
                            onPressed: () {
                              // Get.to(Pantalla());
                              Get.to(() => Pantalla2());
                              // exit(0);
                            },
                            child: const Text('Guardar configuración'))
                      ],
                    );
                  }))),
        ),
      );
    });
  }
}
