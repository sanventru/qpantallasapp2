// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/confogctrl.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../screens/pantalla2.dart';

class Config extends StatelessWidget {
  final a = Get.put(Configctrl());

  @override
  Widget build(BuildContext context) {
    // var size = MediaQuery.of(context).size;

    return Obx(() {
      print(a.cambio.value);
      return RotatedBox(
        quarterTurns: a.rotado.value,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,  
              children: [
                Image.asset('assets/dunkin_logo.png', height: 40),
                SizedBox(width: 12),
                Text(
                  '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange[400],
          ),
          body: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.orange[100]!, Colors.white],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Obx(() {
                  print(a.cambio.value);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'URL del Servidor',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: a.txturl,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Ingrese la URL',
                            prefixIcon: Icon(Icons.link, color: Colors.orange[400]),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => a.txturl.clear(),
                                  icon: Icon(Icons.clear, color: Colors.red[400]),
                                ),
                                IconButton(
                                  onPressed: a.seturl,
                                  icon: Icon(Icons.save, color: Colors.green[400]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Orientación de Pantalla',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: DropdownSearch<String>(
                          popupProps: PopupProps.menu(
                            fit: FlexFit.loose,
                            menuProps: MenuProps(
                              backgroundColor: Colors.white,
                              elevation: 8,
                            ),
                          ),
                                  items:  (filter, infiniteScrollProps) =>
                      ["horizontal", "vertical"],
                          // dropdownDecoratorProps: DropDownDecoratorProps(
                          //   dropdownSearchDecoration: InputDecoration(
                          //     border: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(12),
                          //       borderSide: BorderSide.none,
                          //     ),
                          //     filled: true,
                          //     fillColor: Colors.white,
                          //     contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          //   ),
                          // ),
                          onChanged: a.setorientacion,
                          selectedItem: a.orientacion,
                        ),
                      ),
                      Spacer(),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Get.to(() => Pantalla2()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[400],
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Guardar configuración',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      );
    });
  }
}