import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:panorama_viewer/panorama_viewer.dart';
import 'package:the_void/core/utlis/assets_image.dart';
import 'package:the_void/core/utlis/game_flow_manager.dart';
import 'package:the_void/features/first_stage/presentation/widgets/custom_icon_search_widget.dart';
import 'package:the_void/features/first_stage/presentation/widgets/first_stage_box.dart';
import 'package:the_void/features/first_stage/presentation/widgets/first_stage_clock.dart';
import 'package:the_void/features/first_stage/presentation/widgets/first_stage_paper.dart';

class FirstStageViewBody extends StatefulWidget {
  const FirstStageViewBody({super.key});

  @override
  State<FirstStageViewBody> createState() => _FirstStageViewBodyState();
}

class _FirstStageViewBodyState extends State<FirstStageViewBody> {
  Widget? activeOverlay;
  String roomFirstStageImage =AssetsImage.roomFirstStageImage;
  bool hasKey = false;

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

  void _openPaper() {
    showOverlay(
      FirstStagePaper(
        onClose: hideOverlay,
      ),
    );
  }

  void _openClock() {
    showOverlay(
      FirstStageClock(
        onClose: hideOverlay,
        onSolved: _onClockSolved,
      ),
    );
  }

  void _openBox() {
  if (!hasKey) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You need a key to open this box!'),
      ),
    );
    return;
  }
  showOverlay(
    FirstStageBox(
      onClose: hideOverlay,
      onStageCompleted: _onStageCompleted,
      scaryImage:roomFirstStageImage==AssetsImage.roomFirstStageImage?
       AssetsImage.horrorRoomImage:AssetsImage.horrorRoomDarkImage,
    ),
  );
 }

Future<void> _onStageCompleted() async {
  await GameFlowManager.completeStage(
    context,
    stage: 1,
  );
}

  void _onClockSolved() {
    setState(() {
      hasKey = true;
      activeOverlay = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        // مشهد الأوضة.
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
            // الورقة.
            Hotspot(
              latitude: -25.026016464464853,
              longitude: -17.44826069519362,
              width: screenSize.width * 0.12,
              height: screenSize.width * 0.12,
              widget: GestureDetector(
                onTap: _openPaper,
                child: CustomIconSearchWidget(),
              ),
            ),

            // الساعة.
            Hotspot(
              latitude: 11.330750705677161,
              longitude: 104.90409633624411,
              width: screenSize.width * 0.12,
              height: screenSize.width * 0.12,
              widget: GestureDetector(
                onTap: _openClock,
                child: CustomIconSearchWidget(),
              ),
            ),

            // العلبة.
            Hotspot(
              latitude: -8.528590694922183,
              longitude: -98.71171713831447,
              width: screenSize.width * 0.12,
              height: screenSize.width * 0.12,
              widget: GestureDetector(
                onTap: _openBox,
                child: CustomIconSearchWidget(),
              ),
            ),

             Hotspot(
              latitude: 2.2737767013966736,
              longitude: 3.339147044518862,
              width: screenSize.width * 0.12,
              height: screenSize.width * 0.12,
              widget: GestureDetector(
                onTap: (){
                 // String roomFirstStageImage =AssetsImage.roomFirstStageImage;
                 if(roomFirstStageImage==AssetsImage.roomFirstStageImage){
                  setState(() {
                    roomFirstStageImage=AssetsImage.roomFirstStageDarkImage;
                  });
                  
                 }else{
                  setState(() {
                     roomFirstStageImage=AssetsImage.roomFirstStageImage;
                  });
                 
                 }
                },
                child:roomFirstStageImage==AssetsImage.roomFirstStageImage?
                 CustomLottieWidget():
                 Container(
                  
                  decoration: BoxDecoration(
                    color: Colors.transparent
                  ),
                  child: SizedBox())
                 ,
              ),
            ),
          ],
          child: Image.asset(roomFirstStageImage),
        ),

        // واجهة العنصر المفتوح، إن وُجدت.
        if (activeOverlay != null) activeOverlay!,

        // المفتاح يظل ظاهرًا فوق المشهد والـ Overlay.
        if (hasKey)
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white24,
                  ),
                ),
                child: const Icon(
                  Icons.key,
                  color: Colors.amber,
                  size: 32,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class CustomLottieWidget extends StatelessWidget {
  const CustomLottieWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
     return Opacity(
      opacity: 0.5,
       child: Lottie.asset('assets/animation/Indicator.json',
       ),
     );
    // Container(
    //   decoration: BoxDecoration(
    //     //color: Colors.red.withAlpha(120),
    //     shape: BoxShape.circle,
    //     //  border: Border.all(color: Colors.white, width: 0),
    //   ),
    //   child:  Lottie.asset('assets/animation/Indicator.json'),
    // );
  }
}
