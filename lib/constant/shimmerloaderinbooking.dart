import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoaderInBooking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20),
      children: [
        SizedBox(
          height: 50,
        ),
        Center(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[400]!,
            highlightColor: Colors.grey[300]!,
            period: Duration(seconds: 2),
            child: Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[400]!,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          itemCount: 8,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 26,
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[400]!,
                      highlightColor: Colors.grey[300]!,
                      period: Duration(seconds: 2),
                      child: Container(
                        height: 90,
                        decoration: ShapeDecoration(
                            color: Colors.grey[400]!, shape: CircleBorder()),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(""),
                  ),
                  Expanded(
                    flex: 70,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.grey[400]!,
                          highlightColor: Colors.grey[300]!,
                          period: Duration(seconds: 2),
                          child: Container(
                            height: 16,
                            width: 220,
                            decoration: ShapeDecoration(
                                color: Colors.grey[400]!,
                                shape: RoundedRectangleBorder()),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Shimmer.fromColors(
                          baseColor: Colors.grey[400]!,
                          highlightColor: Colors.grey[300]!,
                          period: Duration(seconds: 2),
                          child: Container(
                            height: 16,
                            width: 150,
                            decoration: ShapeDecoration(
                                color: Colors.grey[400]!,
                                shape: RoundedRectangleBorder()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        )
      ],
    );
  }
}
