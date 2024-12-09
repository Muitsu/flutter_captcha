import 'dart:math';

import 'package:captcha/slider_captcha/puzzle_piece_painter.dart';
import 'package:captcha/slider_captcha/slider_captcha.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef SliderCreate = Offset? Function();

class SliderCaptCha extends SingleChildRenderObjectWidget {
  final Widget image;
  final double offsetX;
  final double offsetY;
  final Color colorCaptChar;
  final double sizeCaptChar;
  final SliderController sliderController;

  const SliderCaptCha({
    required this.image,
    required this.offsetX,
    required this.offsetY,
    this.sizeCaptChar = 40,
    this.colorCaptChar = Colors.blue,
    required this.sliderController,
    super.key,
  }) : super(child: image);

  @override
  RenderObject createRenderObject(BuildContext context) {
    final renderObject = RenderTestSliderCaptChar();
    sliderController.create = renderObject.create;
    renderObject.offsetX = offsetX;
    renderObject.offsetY = offsetY;
    renderObject.colorCaptChar = colorCaptChar;
    renderObject.sizeCaptChar = sizeCaptChar;
    renderObject.colorCaptChar = colorCaptChar;
    return renderObject;
  }

  @override
  void updateRenderObject(context, RenderTestSliderCaptChar renderObject) {
    renderObject.offsetX = offsetX;
    renderObject.offsetY = offsetY;
    renderObject.colorCaptChar = colorCaptChar;
    renderObject.sizeCaptChar = sizeCaptChar;
    renderObject.colorCaptChar = colorCaptChar;
    super.updateRenderObject(context, renderObject);
  }
}

class RenderTestSliderCaptChar extends RenderProxyBox {
  double sizeCaptChar = 40;
  double strokeWidth = 3;
  double offsetX = 0;
  double offsetY = 0;
  double createX = 0;
  double createY = 0;
  Color colorCaptChar = Colors.black;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) {
      return;
    }
    context.paintChild(child!, offset);
    if (!(child!.size.width > 0 && child!.size.height > 0)) {
      return;
    }

    Paint paint = Paint()
      ..color = colorCaptChar
      ..strokeWidth = strokeWidth;

    if (createX == 0 && createY == 0) {
      return;
    }

    context.canvas.drawPath(
      getPiecePathCustom(
        size,
        strokeWidth + offset.dx + createX.toDouble(),
        offset.dy + createY.toDouble(),
        sizeCaptChar,
      ),
      paint..style = PaintingStyle.fill,
    );

    context.canvas.drawPath(
      getPiecePathCustom(
        Size(size.width - strokeWidth, size.height - strokeWidth),
        strokeWidth + offset.dx + offsetX,
        offset.dy + createY,
        sizeCaptChar,
      ),
      paint..style = PaintingStyle.stroke,
    );

    layer = context.pushClipPath(
      needsCompositing,
      Offset(-createX + offsetX + offset.dx + strokeWidth, offset.dy),
      Offset.zero & size,
      getPiecePathCustom(
        size,
        createX,
        createY.toDouble(),
        sizeCaptChar,
      ),
      (context, offset) {
        context.paintChild(child!, offset);
      },
      oldLayer: layer as ClipPathLayer?,
    );
  }

  @override
  void performLayout() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      /// tam fix
      if (createX != 0 && createY != 0) {
        return;
      }
      create();
      markNeedsPaint();
    });

    super.performLayout();
  }

  Offset? create() {
    if (size == Size.zero) {
      return null;
    }
    createX = sizeCaptChar +
        Random().nextInt((size.width - 2.5 * sizeCaptChar).toInt());
    answerX = createX;
    createY = 0.0 + Random().nextInt((size.height - sizeCaptChar).toInt());
    markNeedsPaint();
    return Offset(createX, createY);
  }
}
