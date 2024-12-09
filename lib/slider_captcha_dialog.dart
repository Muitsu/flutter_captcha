import 'package:captcha/slider_captcha/slider_captcha.dart';
import 'package:flutter/material.dart';

class SliderCaptchaDialog extends StatefulWidget {
  final Widget image;
  final void Function()? onSuccess;
  final void Function()? onFailed;

  const SliderCaptchaDialog(
      {super.key, required this.image, this.onSuccess, this.onFailed});

  @override
  State<SliderCaptchaDialog> createState() => _SliderCaptchaDialogState();

  static Future<void> show(BuildContext context,
      {required Widget image,
      void Function()? onSuccess,
      void Function()? onFailed}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => SliderCaptchaDialog(
        image: image,
        onSuccess: onSuccess,
        onFailed: onFailed,
      ),
    );
  }
}

class _SliderCaptchaDialogState extends State<SliderCaptchaDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
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
        backgroundColor: Colors.white,
        child: AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            width: double.infinity,
            height: 275,
            child: SliderCaptcha(
              image: widget.image,
              title: "Slide to Captcha",
              onConfirm: (value) async {
                if (value) {
                  if (widget.onSuccess != null) widget.onSuccess!();
                } else {
                  if (widget.onFailed != null) widget.onFailed!();
                  _animationController.forward(); // Trigger the shake animation
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
