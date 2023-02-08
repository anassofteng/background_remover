import 'dart:io';

import 'package:before_after/before_after.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

import 'Api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var loaded = false;
  var isloading = false;
  var removedbg = false;

  Uint8List? image;
  String imagePath = '';

  ScreenshotController screenshotController = ScreenshotController();

  pickImage() async {
    final img = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (img != null) {
      imagePath = img.path;

      loaded = true;
      setState(() {});
    } else {}
  }

  downloadImage() async {
    var perm = await Permission.storage.request();
    var foldername = "BGRemover";
    var filename = "${DateTime.now().millisecondsSinceEpoch}.png";
    if (perm.isGranted) {
      final directory = Directory("storage/emulator/0/");
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      await screenshotController.captureAndSave(directory.path,
          delay: Duration(microseconds: 100),
          fileName: filename,
          pixelRatio: 1.0);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download to ${directory.path}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                downloadImage();
              },
              icon: Icon(Icons.download))
        ],
        leading: const Icon(Icons.sort_rounded),
        elevation: 0.0,
        centerTitle: true,
        title: const Text(
          "AI Background Remover",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Center(
              child: removedbg
                  ? BeforeAfter(
                      beforeImage: Image.file(File(imagePath)),
                      afterImage: Screenshot(
                          controller: screenshotController,
                          child: Image.memory(image!)))
                  : loaded
                      ? GestureDetector(
                          onTap: () {
                            pickImage();
                          },
                          child: Image.file(
                            File(imagePath),
                          ),
                        )
                      : null
              // : Container(
              //     padding: const EdgeInsets.all(40),
              //     decoration: BoxDecoration(
              //       border: Border.all(style: BorderStyle.solid),
              //       color: Colors.black,
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     child: SizedBox(
              //       width: 200,
              //       child: ElevatedButton(
              //         onPressed: () {
              //           pickImage();
              //         },
              //         child: const Text("Select An Image"),
              //       ),
              //     ),
              //   )
              ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(style: BorderStyle.solid),
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  pickImage();
                },
                child: const Text("Select An Image"),
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: loaded
              ? () async {
                  setState(() {
                    isloading = true;
                  });
                  image = await Api.removebg(imagePath);
                  if (image != null) {
                    removedbg = true;
                    isloading = false;
                    setState(() {});
                  }
                }
              : null,
          child: isloading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                )
              : const Text("Remove background"),
        ),
      ),
    );
  }
}
