 import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
 import 'package:path/path.dart' as pathx;
import '../viewmodels/permission_provider.dart';

class CameraUtil{

   static saveImageToDirectory(BuildContext context) async {
     //path: ^1.8.3
     final permissionProvider =
     Provider.of<PermissionProvider>(context, listen: false);
     final pathDir = Directory("storage/emulated/0/DCIM/ProfilePic");
     if ((await pathDir.exists())) {
     } else {
       pathDir.create();
     }
     String fileName = pathx.basename(permissionProvider.profilePic!.path);
     // debugPrint("fileName--->${fileName}");
     final String pathPic = '${pathDir.path}/$fileName';
     final File newImage = File(pathPic);
     final imagePath =
     await newImage.writeAsBytes(await permissionProvider.profilePic!.readAsBytes());
     debugPrint("imagePath--->${imagePath}");
   }
 }