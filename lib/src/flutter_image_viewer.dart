import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FlutterImageViewer extends StatefulWidget {
  final String? imagePath;
  final double? height;
  final double? width;
  final Color? color;
  final BoxFit? fit;
  final Alignment? alignment;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? radius;
  final BoxBorder? border;
  final String placeHolder;

  const FlutterImageViewer({
    Key? key,
    this.imagePath,
    this.height,
    this.width,
    this.color,
    this.fit,
    this.alignment,
    this.onTap,
    this.margin,
    this.radius,
    this.border,
    this.placeHolder = 'assets/images/svg/logo.svg',
  }) : super(key: key);

  @override
  State<FlutterImageViewer> createState() => _FlutterImageViewerState();
}

class _FlutterImageViewerState extends State<FlutterImageViewer> {
  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    switch (widget.imagePath?.imageType) {
      case ImageType.svg:
        imageWidget = SvgPicture.asset(
          widget.imagePath!,
          height: widget.height,
          width: widget.width,
          fit: widget.fit ?? BoxFit.contain,
          // color: widget.color, // Deprecated
          // colorBlendMode: widget.color != null ? BlendMode.modulate! : null, // Replacement
        );
        break;
      case ImageType.file:
        imageWidget = Image.file(
          File(widget.imagePath!),
          height: widget.height,
          width: widget.width,
          fit: widget.fit ?? BoxFit.contain,
          color: widget.color, // Deprecated
          colorBlendMode: widget.color != null ? BlendMode.modulate : null, // Replacement
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorWidget(context);
          },
        );
        break;
      case ImageType.network:
        imageWidget = CachedNetworkImage(
          imageUrl: widget.imagePath!,
          height: widget.height,
          width: widget.width,
          fit: widget.fit ?? BoxFit.contain,
          color: widget.color, // Deprecated
          colorBlendMode: widget.color != null ? BlendMode.modulate : null, // Replacement
          placeholder: (context, url) => SizedBox(
            height: 30,
            width: 30,
            child: CircularProgressIndicator(
              color: Colors.grey.shade200,
              backgroundColor: Colors.grey.shade100,
            ),
          ),
          errorWidget: (context, url, error) {
            return _buildErrorWidget(context);
          },
        );
        break;
      case ImageType.png:
      default:
        imageWidget = Image.asset(
          widget.imagePath!,
          height: widget.height,
          width: widget.width,
          fit: widget.fit ?? BoxFit.contain,
          color: widget.color, // Deprecated
          colorBlendMode: widget.color != null ? BlendMode.modulate : null, // Replacement
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorWidget(context);
          },
        );
    }

    Widget paddedImage = Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: imageWidget,
    );

    return widget.alignment != null
        ? Align(
      alignment: widget.alignment!,
      child: _buildCircleImage(context, paddedImage),
    )
        : _buildCircleImage(context, paddedImage);
  }

  Widget _buildCircleImage(BuildContext context, Widget imageWidget) {
    return widget.radius != null
        ? ClipRRect(
      borderRadius: widget.radius!,
      child: _buildImageWithBorder(context, imageWidget),
    )
        : _buildImageWithBorder(context, imageWidget);
  }

  Widget _buildImageWithBorder(BuildContext context, Widget imageWidget) {
    if (widget.imagePath == null || widget.imagePath!.isEmpty) {
      return _buildErrorWidget(context);
    } else {
      return widget.border != null
          ? Container(
        decoration: BoxDecoration(
          border: widget.border,
          borderRadius: widget.radius,
        ),
        child: imageWidget,
      )
          : imageWidget;
    }
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: const Text(
        'Image not found',
        style: TextStyle(color: Colors.red),
      ),
    );
  }
}

extension ImageTypeExtension on String? {
  ImageType get imageType {
    if (this == null) return ImageType.unknown;
    if (this!.startsWith('http') || this!.startsWith('https')) {
      return ImageType.network;
    } else if (this!.endsWith('.svg')) {
      return ImageType.svg;
    } else if (this!.startsWith('file://')) {
      return ImageType.file;
    } else {
      return ImageType.png;
    }
  }
}

enum ImageType { svg, png, network, file, unknown }
