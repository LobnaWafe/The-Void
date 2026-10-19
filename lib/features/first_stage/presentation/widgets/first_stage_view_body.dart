import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart';
import 'package:the_void/core/utlis/assets_image.dart';
import 'package:the_void/features/first_stage/presentation/widgets/custom_icon_search_widget.dart';
import 'package:the_void/features/first_stage/presentation/widgets/first_stage_paper.dart';

class FirstStageViewBody extends StatefulWidget {
  const FirstStageViewBody({super.key});

  @override
  State<FirstStageViewBody> createState() => _FirstStageViewBodyState();
}

class _FirstStageViewBodyState extends State<FirstStageViewBody> {
  Widget? activeOverlay;

  void showOverlay(Widget overlay) {
    setState(() {
      activeOverlay = overlay;
    });
  }

  void hideOverlay() {
    setState(() {
      activeOverlay = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        PanoramaViewer(
          onTap: (longitude, latitude, tilt) {
            log('Longitude: $longitude, Latitude: $latitude');
          },
          sensorControl: SensorControl.none,
          minLatitude: -10,
          maxLatitude: 10,
          minLongitude: -90,
          maxLongitude: 90,
          longitude: 0,
          latitude: 0,
          hotspots: [
            // الورقة
            Hotspot(
              latitude: -25.026016464464853,
              longitude: -17.44826069519362,
              width: screenSize.width * 0.12,
              height: screenSize.width * 0.12,
              widget: GestureDetector(
                onTap: () {
                  showOverlay(
                    FirstStagePaper(
                      onClose: hideOverlay,
                    ),
                  );
                },
                child: CustomIconSearchWidget(),
              ),
            ),

            // الساعة
            Hotspot(
              latitude: 11.330750705677161,
              longitude: 104.90409633624411,
              width: screenSize.width * 0.12,
              height: screenSize.width * 0.12,
              widget: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم الضغط على الساعة!'),
                    ),
                  );
                },
                child: CustomIconSearchWidget(),
              ),
            ),

            // العلبة
            Hotspot(
              latitude: -8.528590694922183,
              longitude: -98.71171713831447,
              width: screenSize.width * 0.12,
              height: screenSize.width * 0.12,
              widget: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم الضغط على الصندوق!'),
                    ),
                  );
                },
                child: CustomIconSearchWidget(),
              ),
            ),
          ],
          child: Image.asset(AssetsImage.roomFirstStageImage),
        ),

        // مش هتتضاف أي Widget هنا إلا لو فيه Overlay فعلًا.
        if (activeOverlay != null) activeOverlay!,
      ],
    );
  }
}



// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:panorama_viewer/panorama_viewer.dart';
// import 'package:the_void/core/utlis/assets_image.dart';
// import 'package:the_void/features/first_stage/presentation/widgets/custom_icon_search_widget.dart';

// class FirstStageViewBody extends StatefulWidget {
//   const FirstStageViewBody({super.key});

//   @override
//   State<FirstStageViewBody> createState() => _FirstStageViewBodyState();
// }

// class _FirstStageViewBodyState extends State<FirstStageViewBody> {
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;

//     return PanoramaViewer(
//       onTap: (longitude, latitude, tilt) {
//         log("Longitude: $longitude, Latitude: $latitude");
//       },

//       sensorControl: SensorControl.none,

//       minLatitude: -10,
//       maxLatitude: 10,

//       minLongitude: -90,
//       maxLongitude: 90,

//       longitude: 0,
//       latitude: 0,

//       hotspots: [
      
//       Hotspot(
//           latitude: -25.026016464464853,
//           longitude: -17.44826069519362,
//           width: screenSize.width * 0.12, // حجم يتناسب مع عرض الشاشة
//           height: screenSize.width * 0.12, // الحفاظ على شكل دائري متناسق
//           widget: GestureDetector(
//             onTap: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('تم الضغط على الورقه!')),
//               );
//             },
//             child: CustomIconSearchWidget(),
//           ),
//         ),


//         Hotspot(
//           latitude: 11.330750705677161,
//           longitude: 104.90409633624411,
//           width: screenSize.width * 0.12, // حجم يتناسب مع عرض الشاشة
//           height: screenSize.width * 0.12, // الحفاظ على شكل دائري متناسق
//           widget: GestureDetector(
//             onTap: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('تم الضغط على الساعة!')),
//               );
//             },
//             child: CustomIconSearchWidget()
//           ),
//         ),

//          Hotspot(
//           latitude: -8.528590694922183,
//           longitude: -98.71171713831447,
//           width: screenSize.width * 0.12, // حجم يتناسب مع عرض الشاشة
//           height: screenSize.width * 0.12, // الحفاظ على شكل دائري متناسق
//           widget: GestureDetector(
//             onTap: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('تم الضغط على الصندوق!')),
//               );
//             },
//             child: CustomIconSearchWidget()
//           ),
//         ),
//       ],

//       child: Image.asset(AssetsImage.roomFirstStageImage),
//     );
//   }
// }
