import 'package:flutter/material.dart';

class DialogUtils {
  static Future<void> showLoadingDialog(BuildContext context, String message,
      IconData icon, bool isError, Function fct) async {
    await showDialog(
        context: context,
        builder: (BuildContext) {
          return AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            icon: Icon(
              icon,
              size: 50,
            ),
            title: Column(
              children: [
                Text(
                  message,
                ),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Visibility(
                        visible: !isError,
                        child: const Text(
                          "Cancel",
                          style: TextStyle(fontSize: 20, color: Colors.red),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: !isError,
                      child: const SizedBox(
                        width: 50,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        fct();
                      },
                      child: const Text(
                        "Ok",
                        style: TextStyle(fontSize: 20, color: Colors.green),
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        });
  }

  static Future<void> imagePickerDialog({
    required BuildContext context,
    required Function cameraFCT,
    required Function galleryFCT,
    required Function removeFCT,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext) {
        return AlertDialog(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Choose"),
              const SizedBox(
                height: 10,
              ),
              TextButton(
                onPressed: () {
                  cameraFCT();
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: const Row(
                  children: [
                    Icon(Icons.camera),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Camera",
                      style: TextStyle(fontSize: 22),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextButton(
                onPressed: () {
                  galleryFCT();
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: const Row(
                  children: [
                    Icon(Icons.photo_library_outlined),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Gallery",
                      style: TextStyle(fontSize: 22),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextButton(
                onPressed: () {
                  removeFCT();
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: const Row(
                  children: [
                    Icon(Icons.clear),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Remove",
                      style: TextStyle(fontSize: 22),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
