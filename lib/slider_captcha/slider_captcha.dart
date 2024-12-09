import 'package:captcha/slider_captcha/slider_util.dart';
import 'package:flutter/material.dart';

class SliderController {
  late Offset? Function() create;
}

double answerX = 0;

class SliderCaptcha extends StatefulWidget {
  const SliderCaptcha({
    required this.image,
    required this.onConfirm,
    this.title = 'Slide to authenticate',
    this.errorText = "Positiion the piece in it slot",
    this.titleStyle,
    this.captchaSize = 30,
    this.colorBar = const Color(0xFFDFDFDF),
    this.colorBarStroke = const Color(0xFFADACAC),
    this.colorCaptChar = Colors.blue,
    this.controller,
    this.borderImager = 0,
    this.imageToBarPadding = 3,
    this.slideContainerDecoration,
    this.icon,
    super.key,
  }) : assert(0 <= borderImager && borderImager <= 5);
  final Widget image;
  final Future<void> Function(bool value)? onConfirm;
  final String title;
  final String errorText;

  final TextStyle? titleStyle;
  final Color colorBar;
  final Color colorBarStroke;
  final Color colorCaptChar;
  final double captchaSize;
  final Widget? icon;
  final Decoration? slideContainerDecoration;
  final SliderController? controller;
  final double imageToBarPadding;
  final double borderImager;

  @override
  State<SliderCaptcha> createState() => _SliderCaptchaState();
}

class _SliderCaptchaState extends State<SliderCaptcha>
    with SingleTickerProviderStateMixin {
  double heightSliderBar = 50;
  double _offsetMove = 0;
  double answerY = 0;
  bool isLock = false;
  SliderController controller = SliderController();
  SliderController unController = SliderController();
  late Animation<double> animation;
  late AnimationController animationController;

  double statusHeight = 0;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderImager),
              child: Stack(
                children: [
                  SliderCaptCha(
                    image: widget.image,
                    offsetX: _offsetMove,
                    offsetY: answerX,
                    colorCaptChar: widget.colorCaptChar,
                    sliderController: unController,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedContainer(
                      padding: const EdgeInsets.fromLTRB(8, 2, 2, 2),
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: statusHeight,
                      color: const Color(0xFFE06F5D),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            widget.errorText,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: widget.imageToBarPadding),
          Container(
            height: heightSliderBar,
            width: double.infinity,
            decoration: BoxDecoration(
                color: widget.colorBar,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: widget.colorBarStroke)),
            child: Stack(
              children: <Widget>[
                Center(
                  child: Text(
                    widget.title,
                    style: widget.titleStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                Positioned(
                  left: _offsetMove,
                  top: 0,
                  height: 50,
                  width: 50,
                  child: GestureDetector(
                    onHorizontalDragStart: (detail) =>
                        _onDragStart(context, detail),
                    onHorizontalDragUpdate: (DragUpdateDetails detail) {
                      _onDragUpdate(context, detail);
                    },
                    onHorizontalDragEnd: (DragEndDetails detail) {
                      checkAnswer();
                    },
                    child: Container(
                      height: heightSliderBar,
                      width: heightSliderBar,
                      margin: const EdgeInsets.all(4),
                      decoration: widget.slideContainerDecoration ??
                          const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 0),
                                blurRadius: 2,
                                color: Colors.grey,
                              )
                            ],
                          ),
                      child: widget.icon ??
                          const Icon(Icons.horizontal_distribute_rounded),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _onDragStart(BuildContext context, DragStartDetails start) {
    if (isLock) {
      return;
    }
    setState(() {
      RenderBox getBox = context.findRenderObject() as RenderBox;
      var local = getBox.globalToLocal(start.globalPosition);
      _offsetMove = local.dx - heightSliderBar / 2;
    });
  }

  _onDragUpdate(BuildContext context, DragUpdateDetails update) {
    if (isLock) {
      return;
    }
    RenderBox getBox = context.findRenderObject() as RenderBox;
    var local = getBox.globalToLocal(update.globalPosition);

    if (local.dx < 0) {
      setState(() {
        _offsetMove = 0;
      });
      return;
    }

    if (local.dx > getBox.size.width) {
      setState(() {
        _offsetMove = getBox.size.width - heightSliderBar;
      });
      return;
    }

    setState(() {
      _offsetMove = local.dx - heightSliderBar / 2;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      controller = SliderController();
    } else {
      controller = widget.controller!;
    }

    controller.create = create;

    animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    animation = Tween<double>(begin: 1, end: 0).animate(animationController)
      ..addListener(() {
        setState(() {
          _offsetMove = _offsetMove * animation.value;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animationController.reset();
        }
      });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        controller.create.call();
      });
    });
    super.didChangeDependencies();
  }

  void onUpdate(double d) {
    setState(() {
      _offsetMove = d;
    });
  }

  Future<void> checkAnswer() async {
    if (isLock) {
      return;
    }
    isLock = true;

    if (_offsetMove < answerX + 10 && _offsetMove > answerX - 10) {
      await widget.onConfirm?.call(true);
    } else {
      setState(() => statusHeight = 25);

      // Revert the height back to 0 after 1.5 seconds
      await Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          statusHeight = 0;
        });
      });
      await widget.onConfirm?.call(false);
    }
    isLock = false;
  }

  Offset? create() {
    animationController.forward().then((value) {
      setState(() {
        Offset? offset = unController.create.call();
        answerX = offset?.dx ?? 0;
        answerY = offset?.dy ?? 0;
      });
    });
    return null;
  }
}
