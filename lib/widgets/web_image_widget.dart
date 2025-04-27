import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'dart:html' as html;
import 'dart:ui' as ui; // <-- This is required!
import 'package:flutter/material.dart';

class WebImageWidget extends StatelessWidget {
  final String imageUrl;
  final VoidCallback? onTap;

  const WebImageWidget(this.imageUrl, {Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Register the image element for the web
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      imageUrl,
      (int viewId) {
        final img = html.ImageElement();
        img.src = imageUrl;
        img.draggable = false;
        img.style.width = '100%';
        img.style.height = '100%';
        img.onError.listen((event) {
          print("Failed to load image: $imageUrl");
          img.src = 'assets/noimage.jpg';
        });
        return img;
      },
    );

    return Stack(
      children: [
        HtmlElementView(viewType: imageUrl),
        Positioned.fill(
          child: GestureDetector(
            onTap: onTap,
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }
}
