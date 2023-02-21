import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class Tryout extends StatefulWidget {
  const Tryout({super.key});

  @override
  State<Tryout> createState() => TryoutState();
}

class TryoutState extends State<Tryout> {
  late List<CameraDescription> cameras;
  late CameraController cameraController;
  int direction = 0;

  @override
  void initState() {
    super.initState();
    startCamera(0);
    Future.delayed(Duration.zero, () {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void startCamera(int direction) async {
    cameras = await availableCameras();

    cameraController = CameraController(
        cameras[direction], ResolutionPreset.high,
        enableAudio: false);
    await cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((e) {
      print(e);
    });
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController.value.isInitialized) {
      return Scaffold(
        body: Stack(
          children: [
            CameraPreview(cameraController),
            GestureDetector(
              onTap: () => {
                setState(() {
                  direction = direction == 0 ? 1 : 0;
                  startCamera(direction);
                })
              },
              child: button(Icons.flip, Alignment.bottomLeft),
            ),
            GestureDetector(
              onTap: () => {
                cameraController.takePicture().then((XFile? file) {
                  if (mounted) {
                    if (file != null) {
                      print("Saved Picture Path ${file.path}");
                    }
                  }
                })
              },
              child: button(Icons.camera, Alignment.bottomCenter),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}

Widget button(IconData icon, Alignment alignment) {
  return Align(
    alignment: alignment,
    child: Container(
      margin: EdgeInsets.only(left: 20, bottom: 20),
      height: 50,
      width: 50,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 10)
          ]),
      child: Center(
        child: Icon(
          Icons.flip,
          color: Colors.black54,
        ),
      ),
    ),
  );
}
