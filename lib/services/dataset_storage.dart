import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class DatasetStorage{
  static const String rootFolder = "Annotater/datasets";

  /// Full PATH : /storage/emulated/0/Annotater/datasets
///
    static Future<String> getRootPath() async{
      Directory? dir = Directory("/storage/emulated/0/$rootFolder");

      if (!await dir.exists()){
        await dir.create(recursive: true);
      }

      return dir.path;
    }

  static Future listClasses(String dataset) async {

      return ['Cat', 'Dog'];
  }
}