import 'package:autoversa/constant/image_const.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageWidget extends StatelessWidget {
  final String? img;

  const ImageWidget({this.img, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width / 3 - 12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200.0,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
            ),
            child: Column(
              children: [
                CachedNetworkImage(
                  placeholder: (context, url) => Transform.scale(
                    scale: 0.2,
                    child: CircularProgressIndicator(),
                  ),
                  imageUrl: img!,
                  height: 170.0,
                  width: width,
                  fit: BoxFit.fill,
                ),
                // Image.asset(
                //   img!,
                //   height: 160,
                //   fit: BoxFit.cover,
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
