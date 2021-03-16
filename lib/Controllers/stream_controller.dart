import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatController extends GetxController {
  final isDisplaySticker = false.obs;
  final isLoading = false.obs;
  File imageFile;
  final imageUrl = "".obs;
  final chatId = "".obs;
  final loading = false.obs;
  final isDownloaded = false.obs;
  FocusNode focusNode = FocusNode();
  final Dio dio = Dio();
  final progress = "".obs;

  onFocusChanged() {
    if (focusNode.hasFocus) {
      isDisplaySticker(false);
    } else {}
  }

  getSticker() {
    focusNode.unfocus();
    // setState(() {
    //   isDisplaySticker = !isDisplaySticker;
    // });
    isDisplaySticker(!isDisplaySticker());
  }

  Future<bool> onBackPress(context) {
    print("on will pop *********************");
    if (isDisplaySticker()) {
      isDisplaySticker(false);
    } else {
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  Future<bool> saveFile(
    String url,
  ) async {
    Directory directory;
    try {
      if (Platform.isAndroid) {
        if (await requestPermission(Permission.storage)) {
          directory = await getExternalStorageDirectory();
          print("Path is --${directory.path}");
          String newPath = "";
          // /storage/emulated/0/Android/data/com.example.file_demo/files
          List<String> folders = directory.path.split("/");
          for (int x = 1; x < folders.length; x++) {
            String folder = folders[x];
            if (folder != "Android") {
              newPath += "/" + folder;
            } else {
              break;
            }
          }
          newPath = newPath + "/shubhDemo";
          directory = Directory(newPath);
          print("value of new Directory ${directory.path}");
        } else {
          return false;
        }
      } else {}
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
        File savedFile = File(directory.path + "/${DateTime.now()}");
        await dio.download(url, savedFile.path,
            onReceiveProgress: (downloaded, totalSize) {
          print(progress);
          progress(((downloaded / totalSize) * 100).toStringAsFixed(0));
        });
        return true;
      }
    } catch (e) {
      print("errrrr -$e");
    }
    return false;
  }

  Future<bool> requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  downloadingFile(String url) async {
    loading(true);
    print(loading(true));

    print("url is " + url);
    bool downloaded = await saveFile(url);
    if (downloaded) {
      print("fileDownloaded");
    } else {
      print("error in fileDownloaded");
    }

    loading(false);
    isDownloaded(true);
  }

  uploadImage() {
    isLoading(false);
  }
}
