import 'dart:async';

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telegramchatapp/Controllers/stream_controller.dart';
import 'package:telegramchatapp/Widgets/FullImageWidget.dart';
import 'package:telegramchatapp/Widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chat extends StatelessWidget {
  final String recieverId;
  final String recieverAvatar;
  final String recieverName;

  Chat({Key key, this.recieverId, this.recieverAvatar, this.recieverName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.black,
              backgroundImage: CachedNetworkImageProvider(recieverAvatar),
            ),
          )
        ],
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.lightBlue,
        title: Text(
          recieverName,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ChatScreen(recieverId: recieverId, recieverAvatar: recieverAvatar),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String recieverId;
  final String recieverAvatar;

  ChatScreen({Key key, this.recieverId, this.recieverAvatar}) : super(key: key);
  @override
  State createState() =>
      ChatScreenState(recieverId: recieverId, recieverAvatar: recieverAvatar);
}

class ChatScreenState extends State<ChatScreen> {
  // ignore: close_sinks
  final ChatController chatController = Get.put(ChatController());
  final String recieverId;
  final String recieverAvatar;
  TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // FocusNode focusNode = FocusNode();
  // bool isDisplaySticker;
  // bool isLoading;
  File imageFile;
  String imageUrl;
  String chatId;
  SharedPreferences preferences;
  String id;
  var listMessage;

  // bool isDownloading = false;

  // bool loading = false;
  // final Dio dio = Dio();
  // String progress = "";

  bool isDownloaded = false;

  // var fileType;

  @override
  void initState() {
    print("init state");
    super.initState();
    chatController.focusNode.addListener(chatController.onFocusChanged());
    chatController.isDisplaySticker.value = false;
    chatController.isLoading.value = false;
    chatId = "";

    readLocal();
    //setState(() {});
  }

  readLocal() async {
    print("read local");
    preferences = await SharedPreferences.getInstance();
    // @see ---loginPage.dart controlSignin method
    id = preferences.getString("id") ?? "";
    if (id.hashCode <= recieverId.hashCode) {
      print("44444444444");
      // we are combining currentuserId and Reciever id in orderto create unique chat id
      // between two users
      chatId = '$id-$recieverId';
    } else {
      print("555555555555");
      chatId = '$recieverId-$id';
    }
    Firestore.instance
        .collection("chatAppUsers")
        .document(id)
        .updateData({'chattingWith': recieverId});
    setState(() {});
  }

  // onFocusChanged() {
  //   if (focusNode.hasFocus) {
  //     setState(() {
  //       // hide stickers whenever keypad appears
  //       isDisplaySticker = false;
  //     });
  //   } else {}
  // }

  ChatScreenState({Key key, this.recieverId, this.recieverAvatar});
  @override
  Widget build(BuildContext context) {
    print("method call jatoy");
    return GetX<ChatController>(builder: (controller) {
      return WillPopScope(
        child: Stack(
          children: [
            Column(
              children: [
                createMessagesList(),
                // showSticker
                (controller.isDisplaySticker.value)
                    ? createStickers()
                    : Container(),
                createInput()
              ],
            ),
            createLoading()
          ],
        ),
        onWillPop: () => chatController.onBackPress(context),
      );
    });
  }

  createLoading() {
    return Positioned(
      child: chatController.isLoading.value ? circularProgress() : Container(),
    );
  }

  // Future<bool> onBackPress() {
  //   print("on will pop *********************");
  //   if (isDisplaySticker) {
  //     setState(() {
  //       isDisplaySticker = false;
  //     });
  //   } else {
  //     Navigator.pop(context);
  //   }
  //   return Future.value(false);
  // }

  createStickers() {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FlatButton(
                child: Image.asset(
                  "images/mimi1.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
                onPressed: () => onSendMessages("mimi1", 2),
              ),
              FlatButton(
                child: Image.asset(
                  "images/mimi2.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
                onPressed: () => onSendMessages("mimi2", 2),
              ),
              FlatButton(
                child: Image.asset(
                  "images/mimi3.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
                onPressed: () => onSendMessages("mimi3", 2),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FlatButton(
                child: Image.asset(
                  "images/mimi4.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
                onPressed: () => onSendMessages("mimi4", 2),
              ),
              FlatButton(
                child: Image.asset(
                  "images/mimi5.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
                onPressed: () => onSendMessages("mimi5", 2),
              ),
              FlatButton(
                child: Image.asset(
                  "images/mimi6.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
                onPressed: () => onSendMessages("mimi6", 2),
              )
            ],
          )
        ],
      ),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180,
    );
  }

  createMessagesList() {
    print("list messages");
    return Flexible(
        child: chatId == ""
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                ),
              )
            : StreamBuilder(
                stream: Firestore.instance
                    .collection("ChatMessages")
                    .document(chatId)
                    .collection(chatId)
                    .orderBy("timeStamp", descending: true)
                    .limit(20)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.lightBlueAccent),
                      ),
                    );
                  } else {
                    listMessage = snapshot.data.documents;

                    return ListView.builder(
                      itemBuilder: (context, index) {
                        return createItem(
                            index, snapshot.data.documents[index]);
                      },
                      itemCount: snapshot.data.documents.length,
                      reverse: true,
                      //controller: scrollController,
                    );
                  }
                },
              ));
  }

  // Future<bool> saveFile(String url, String filename) async {
  //   Directory directory;
  //   try {
  //     if (Platform.isAndroid) {
  //       if (await requestPermission(Permission.storage)) {
  //         directory = await getExternalStorageDirectory();
  //         print("Path is --${directory.path}");
  //         String newPath = "";
  //         // /storage/emulated/0/Android/data/com.example.file_demo/files
  //         List<String> folders = directory.path.split("/");
  //         for (int x = 1; x < folders.length; x++) {
  //           String folder = folders[x];
  //           if (folder != "Android") {
  //             newPath += "/" + folder;
  //           } else {
  //             break;
  //           }
  //         }
  //         newPath = newPath + "/shubhDemo";
  //         directory = Directory(newPath);
  //         print("value of new Directory ${directory.path}");
  //       } else {
  //         return false;
  //       }
  //     } else {}
  //     if (!await directory.exists()) {
  //       await directory.create(recursive: true);
  //     }
  //     if (await directory.exists()) {
  //       File savedFile = File(directory.path + "/$filename");
  //       await dio.download(url, savedFile.path,
  //           onReceiveProgress: (downloaded, totalSize) {
  //         setState(() {
  //           print("hsbhfb");
  //           progress = ((downloaded / totalSize) * 100).toStringAsFixed(0);
  //         });
  //       });
  //       return true;
  //     }
  //   } catch (e) {
  //     print("errrrr -$e");
  //   }
  //   return false;
  // }

  // Future<bool> requestPermission(Permission permission) async {
  //   if (await permission.isGranted) {
  //     return true;
  //   } else {
  //     var result = await permission.request();
  //     if (result == PermissionStatus.granted) {
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   }
  // }

// 6
  // downloadingFile(String url) async {
  //   setState(() {
  //     loading = true;
  //   });
  //   print("url is " + url);
  //   bool downloaded = await saveFile(url, "im");
  //   if (downloaded) {
  //     print("fileDownloaded");
  //   } else {
  //     print("error in fileDownloaded");
  //   }

  //   setState(() {
  //     loading = false;
  //     isDownloaded = true;
  //   });
  // }

  Widget createItem(int index, DocumentSnapshot documentSnapshot) {
    print("create Item");
    // my message  - Right Side
    if (documentSnapshot["idFrom"] == id) {
      return Row(
        children: [
          // text
          documentSnapshot["type"] == 0
              ? Container(
                  child: Text(
                    documentSnapshot["content"],
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  margin: EdgeInsets.only(
                      bottom: isLastMsgRight(index) ? 20.0 : 10.0, right: 10.0),
                )
              // Image
              : documentSnapshot["type"] == 1
                  ? GetX<ChatController>(builder: (controller) {
                      return Container(
                        child: FlatButton(
                          child: Material(
                            child: Stack(
                              children: [
                                Card(
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.lightBlueAccent),
                                      ),
                                      width: 200.0,
                                      height: 200.0,
                                      padding: EdgeInsets.all(70),
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0)),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Material(
                                            child: Image.asset(
                                              "images/img_not_available.jpeg",
                                              width: 200,
                                              height: 200,
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(8.0),
                                            ),
                                            clipBehavior: Clip.hardEdge),
                                    imageUrl: documentSnapshot["content"],
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                controller.loading.value
                                    ? Positioned(
                                        bottom: 0,
                                        left: 70,
                                        top: 50,
                                        child: Container(
                                          child: Column(
                                            children: [
                                              CircularProgressIndicator(),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                "Downloading ${controller.progress.value}",
                                                style: TextStyle(
                                                    color: Colors.red),
                                              )
                                            ],
                                          ),
                                        ))
                                    : (!controller.isDownloaded.value)
                                        ? Positioned(
                                            bottom: 0,
                                            left: 70,
                                            top: 50,
                                            child: Container(
                                              child: Column(
                                                children: [
                                                  IconButton(
                                                    color: Colors.red,
                                                    icon: Icon(
                                                      Icons.download_rounded,
                                                      color: Colors.red,
                                                      size: 40,
                                                    ),
                                                    onPressed: () =>
                                                        // print("shubham")
                                                        chatController
                                                            .downloadingFile(
                                                      documentSnapshot[
                                                          'content'],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    "Download ",
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        : Container()
                              ],
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                            clipBehavior: Clip.hardEdge,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FullPhoto(url: documentSnapshot["content"]),
                              ),
                            );
                          },
                        ),
                        margin: EdgeInsets.only(
                            bottom: isLastMsgRight(index) ? 20.0 : 10.0,
                            right: 10.0),
                      );
                    })
                  // emoji
                  : Container(
                      child: Image.asset(
                        "images/${documentSnapshot["content"]}.gif",
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.cover,
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMsgRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    }
    // reciever - Left Side
    else {
      return Container(
        child: Column(
          children: [
            Row(
              children: [
                isLastMsgLeft(index)
                    ? Material(
                        // reciever profile image
                        child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.lightBlueAccent),
                                  ),
                                  width: 35.0,
                                  height: 35.0,
                                  padding: EdgeInsets.all(10),
                                ),
                            imageUrl: recieverAvatar,
                            width: 35,
                            height: 35,
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.all(
                          Radius.circular(18),
                        ),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(
                        width: 35,
                      ),

                // displayMessages
                documentSnapshot["type"] == 0
                    ? Container(
                        child: Text(
                          documentSnapshot["content"],
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w400),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin: EdgeInsets.only(left: 10.0),
                      )
                    // image msg
                    : documentSnapshot["type"] == 1
                        ? Container(
                            child: FlatButton(
                              child: Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Stack(
                                    children: [
                                      Container(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.lightBlueAccent),
                                        ),
                                        width: 200.0,
                                        height: 200.0,
                                        padding: EdgeInsets.all(70),
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8.0)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Material(
                                          child: Image.asset(
                                            "images/img_not_available.jpeg",
                                            width: 200,
                                            height: 200,
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8.0),
                                          ),
                                          clipBehavior: Clip.hardEdge),
                                  imageUrl: documentSnapshot["content"],
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                clipBehavior: Clip.hardEdge,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullPhoto(
                                        url: documentSnapshot["content"]),
                                  ),
                                );
                              },
                            ),
                            margin: EdgeInsets.only(left: 10.0),
                          )
                        // emoji
                        : Container(
                            child: Image.asset(
                              "images/${documentSnapshot["content"]}.gif",
                              width: 100.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                            ),
                            margin: EdgeInsets.only(
                                bottom: isLastMsgRight(index) ? 20.0 : 10.0,
                                right: 10.0),
                          ),
              ],
            ),
            isLastMsgLeft(index)
                ? Container(
                    child: Text(
                      DateFormat("dd MMMM,yyyy -  hh:mm:aa").format(
                        DateTime.fromMicrosecondsSinceEpoch(
                          int.parse(documentSnapshot["timeStamp"]),
                        ),
                      ),
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 50.0, top: 50.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool isLastMsgLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]["idFrom"] == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMsgRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]["idFrom"] != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  // getSticker() {
  //   focusNode.unfocus();
  //   setState(() {
  //     isDisplaySticker = !isDisplaySticker;
  //   });
  // }

  Future getImage() async {
    // imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    imageFile = await FilePicker.getFile(type: FileType.custom);
    // print("image path is --- ${imageFile.path}");
    // print("file type is ----- ${imageFile.path}");
    String extention = imageFile.path.toString().split('.').last;
    // print("fileExtension is ----" + extention);

    if (imageFile != null) {
      chatController.isLoading.value = true;
    }
    uploadImage();
  }

  Future uploadImage() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child('Chat Images').child(fileName);

    StorageUploadTask storageUploadTask = storageReference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot =
        await storageUploadTask.onComplete;

    // Url of that Image
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      // setState(() {
      //   isLoading = false;

      //   onSendMessages(imageUrl, 1);
      // });
      chatController.uploadImage();
      onSendMessages(imageUrl, 1);
    }, onError: (error) {
      // setState(() {
      //   isLoading = false;
      // });
      chatController.uploadImage();
      Fluttertoast.showToast(msg: "Error" + error);
    });
  }

  void onSendMessages(String contentMesg, int type) {
    chatController.isDownloaded.value = false;
    chatController.progress.value = "";
    print("method calles");
    //  if type 0 mesg only
    // type 1 images
    // type 2 emojis
    if (contentMesg != "") {
      messageController.clear();
      var docRef = Firestore.instance
          .collection("ChatMessages")
          .document(chatId)
          .collection(chatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString())
          .setData({
        "idFrom": id, //sender
        "idTo": recieverId, //reciever
        "timeStamp": DateTime.now().millisecondsSinceEpoch.toString(),
        "content": contentMesg,
        "type": type
      });
      // Firestore.instance.runTransaction((transaction) async {
      //   await transaction.set(
      //     docRef,
      //     {
      //       "idFrom": id, //sender
      //       "idTo": recieverId, //reciever
      //       "timeStamp": DateTime.now().millisecondsSinceEpoch.toString(),
      //       "content": contentMesg,
      //       "type": type
      //     },
      //   );
      // });
      scrollController.animateTo(0.0,
          duration: Duration(microseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: "EmptyMessage");
    }
  }

  createInput() {
    return Container(
      child: Row(
        children: [
          //image icon
          Material(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 1.0),
                child: IconButton(
                    icon: Icon(
                      Icons.image,
                      color: Colors.lightBlueAccent,
                    ),
                    onPressed: getImage),
              ),
              color: Colors.white),
          // emoji icon
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                  icon: Icon(Icons.face, color: Colors.lightBlueAccent),
                  onPressed: chatController.getSticker),
            ),
            color: Colors.white,
          ),
          // TextField
          Flexible(
              child: Container(
            child: TextField(
              style: TextStyle(color: Colors.black, fontSize: 20.0),
              controller: messageController,
              decoration: InputDecoration.collapsed(
                hintText: "write here",
                hintStyle: TextStyle(color: Colors.black),
              ),
              focusNode: chatController.focusNode,
            ),
          )),
          // send Message Button
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.lightBlueAccent,
                  ),
                  onPressed: () => onSendMessages(messageController.text, 0)),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white),
    );
  }
}
