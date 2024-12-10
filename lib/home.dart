import 'package:captcha/captcha_dialog.dart';
import 'package:captcha/slider_captcha_dialog.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Re-Captcha Apps")),
      body: Column(
        children: <Widget>[
          ElevatedButton(
              onPressed: () {
                CaptachaDialog.show(
                  context,
                  onSuccess: () {
                    _showSuccessSnackBar(context);
                    Navigator.pop(context);
                  },
                  onFailed: () {},
                );
              },
              child: const Text("Open Dialog")),
          ElevatedButton(
              onPressed: () {
                SliderCaptchaDialog.show(
                  context,
                  image: const FlutterLogo(size: 300),
                  onSuccess: () {
                    _showSuccessSnackBar(context);
                    Navigator.pop(context);
                  },
                  onFailed: () {},
                );
              },
              child: const Text("Open Puzzle")),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Success!"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
