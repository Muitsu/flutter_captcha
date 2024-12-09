import 'dart:math';

import 'package:flutter/material.dart';

class CaptachaDialog extends StatefulWidget {
  final void Function()? onSuccess;
  final void Function()? onFailed;

  const CaptachaDialog({super.key, this.onSuccess, this.onFailed});

  @override
  State<CaptachaDialog> createState() => _CaptachaDialogState();

  static Future<void> show(BuildContext context,
      {void Function()? onSuccess, void Function()? onFailed}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => CaptachaDialog(
        onSuccess: onSuccess,
        onFailed: onFailed,
      ),
    );
  }
}

class _CaptachaDialogState extends State<CaptachaDialog>
    with SingleTickerProviderStateMixin {
  String randomString = "";
  bool isVerified = false;
  TextEditingController controller = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;

  void buildCaptcha() {
    const letters =
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
    const length = 6;
    final random = Random();
    randomString = String.fromCharCodes(List.generate(
        length, (index) => letters.codeUnitAt(random.nextInt(letters.length))));
    setState(() {});
    debugPrint("Generated Captcha: $randomString");
  }

  @override
  void initState() {
    super.initState();
    buildCaptcha();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticIn,
      ),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
        }
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: ModalRoute.of(context)!.animation!,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_shakeAnimation.value, 0),
                child: child,
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Enter Captcha Value",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.maxFinite,
                  height: MediaQuery.sizeOf(context).height * .13,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      randomString,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 40,
                  child: TextFormField(
                    onChanged: (_) => setState(() => isVerified = false),
                    controller: controller,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      hintStyle: TextStyle(color: Color(0xFFADACAC)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFADACAC)),
                        borderRadius: BorderRadius.all(
                            Radius.circular(30.0)), // Rounded corners
                      ),
                      hintText: "Enter Captcha Value",
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 5.0), // Adjust padding
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: buildCaptcha,
                      icon: const Icon(Icons.refresh),
                    ),
                    SizedBox(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white),
                        onPressed: () {
                          setState(() {
                            isVerified = controller.text == randomString;
                            if (isVerified) {
                              if (widget.onSuccess != null) widget.onSuccess!();
                            } else {
                              if (widget.onFailed != null) widget.onFailed!();
                              _animationController.forward();
                            }
                          });
                        },
                        child: const Text("Check"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
