import 'package:flutter/material.dart';
import 'package:the_void/core/utlis/assets_image.dart';
import 'package:the_void/features/second_stage/presentation/widgets/five_rooms_line_painter.dart';
import 'package:the_void/features/second_stage/presentation/widgets/room_button.dart';

class CameraSecurity extends StatefulWidget {
  final ValueChanged<int> onRoomTap;
  final bool isMonsterPresent;
  final bool isSoundLoading;
  final int soundSecondsRemaining;
  final VoidCallback onSoundTap;
  final int selectedRoom;

  const CameraSecurity({
    super.key,
    required this.onRoomTap,
    required this.isMonsterPresent,
    required this.isSoundLoading,
    required this.soundSecondsRemaining,
    required this.onSoundTap,
    required this.selectedRoom,
  });

  @override
  State<CameraSecurity> createState() => _CameraSecurityState();
}

class _CameraSecurityState extends State<CameraSecurity> {
  bool areImagesLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!areImagesLoaded) {
      areImagesLoaded = true;
      _preloadImages();
    }
  }

  Future<void> _preloadImages() async {
    final images = [
      AssetsImage.secondStageCam01Image,
      AssetsImage.secondStageCam02Image,
      AssetsImage.secondStageCam03Image,
      AssetsImage.secondStageCam04Image,
      AssetsImage.secondStageCam05Image,
      AssetsImage.secondStageCam01FImage,
      AssetsImage.secondStageCam02FImage,
      AssetsImage.secondStageCam03FImage,
      AssetsImage.secondStageCam04FImage,
      AssetsImage.secondStageCam05FImage,
    ];

    await Future.wait(
      images.map((image) => precacheImage(AssetImage(image), context)),
    );

    if (!mounted) return;

    setState(() {});
  }

  // اختيار صورة الغرفة حسب وجود الوحش فيها.
  String get cameraImage {
    switch (widget.selectedRoom) {
      case 1:
        return widget.isMonsterPresent
            ? AssetsImage.secondStageCam01FImage
            : AssetsImage.secondStageCam01Image;

      case 2:
        return widget.isMonsterPresent
            ? AssetsImage.secondStageCam02FImage
            : AssetsImage.secondStageCam02Image;

      case 3:
        return widget.isMonsterPresent
            ? AssetsImage.secondStageCam03FImage
            : AssetsImage.secondStageCam03Image;

      case 4:
        return widget.isMonsterPresent
            ? AssetsImage.secondStageCam04FImage
            : AssetsImage.secondStageCam04Image;

      case 5:
        return widget.isMonsterPresent
            ? AssetsImage.secondStageCam05FImage
            : AssetsImage.secondStageCam05Image;

      default:
        return AssetsImage.secondStageCam01Image;
    }
  }

  // إرسال رقم الغرفة المختارة إلى الـ Cubit.
  void selectRoom(int roomNumber) {
    if (roomNumber < 1 || roomNumber > 5) return;

    widget.onRoomTap(roomNumber);
  }

  Widget _buildSoundButton() {
    return GestureDetector(
      onTap: widget.isSoundLoading ? null : widget.onSoundTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.85),
          border: Border.all(
            color: widget.isSoundLoading ? Colors.orangeAccent : Colors.white70,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.isSoundLoading ? Icons.hourglass_top : Icons.volume_up,
              color: widget.isSoundLoading ? Colors.orangeAccent : Colors.white,
              size: 25,
            ),
            const SizedBox(width: 8),
            if (widget.isSoundLoading)
              Text(
                '${widget.soundSecondsRemaining}s',
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              const Text(
                'Sound',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Stack(
          fit: StackFit.expand,
          children: [
            // صورة الغرفة المختارة.
            Positioned.fill(
              child: Image.asset(
                cameraImage,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                filterQuality: FilterQuality.low,
              ),
            ),

            // خريطة الغرف.
            Positioned(
              bottom: height * 0.05,
              left: width * 0.5,
              child: RoomsMapWidget(
                onRoomTap: selectRoom,
                mapWidth: width * 0.22,
              ),
            ),

            // زر الصوت والعداد.
            Positioned(
              left: width * 0.1,
              bottom: height * 0.045,
              child: _buildSoundButton(),
            ),
          ],
        );
      },
    );
  }
}

// ================= خريطة الغرف =================

class RoomsMapWidget extends StatelessWidget {
  final ValueChanged<int> onRoomTap;
  final double mapWidth;

  const RoomsMapWidget({
    super.key,
    required this.onRoomTap,
    required this.mapWidth,
  });

  @override
  Widget build(BuildContext context) {
    final mapHeight = mapWidth * 0.9;

    return Container(
      width: mapWidth,
      height: mapHeight,
      padding: EdgeInsets.all(mapWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        border: Border.all(color: Colors.white60, width: mapWidth * 0.007),
        borderRadius: BorderRadius.circular(mapWidth * 0.04),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: FiveRoomsLinesPainter()),
              ),

              Positioned(
                top: height * 0.04,
                left: width * 0.36,
                child: buildRoomButton(
                  1,
                  width: width * 0.30,
                  height: height * 0.16,
                ),
              ),

              Positioned(
                top: height * 0.40,
                left: 0,
                child: buildRoomButton(
                  2,
                  width: width * 0.30,
                  height: height * 0.16,
                ),
              ),

              Positioned(
                top: height * 0.37,
                left: width * 0.36,
                child: buildRoomButton(
                  3,
                  width: width * 0.32,
                  height: height * 0.22,
                ),
              ),

              Positioned(
                top: height * 0.40,
                right: 0,
                child: buildRoomButton(
                  4,
                  width: width * 0.30,
                  height: height * 0.16,
                ),
              ),

              Positioned(
                bottom: height * 0.04,
                left: width * 0.36,
                child: buildRoomButton(
                  5,
                  width: width * 0.30,
                  height: height * 0.16,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildRoomButton(
    int roomNumber, {
    required double width,
    required double height,
  }) {
    return GestureDetector(
      onTap: () => onRoomTap(roomNumber),
      child: RoomButton(
        mapWidth: mapWidth,
        width: width,
        height: height,
        name: 'Room $roomNumber',
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:the_void/core/utlis/assets_image.dart';
// import 'package:the_void/features/second_stage/presentation/widgets/five_rooms_line_painter.dart';
// import 'package:the_void/features/second_stage/presentation/widgets/room_button.dart';

// class CameraSecurity extends StatelessWidget {
//   final Function(String) onRoomTap;

//   const CameraSecurity({super.key, required this.onRoomTap});

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final width = constraints.maxWidth;
//         final height = constraints.maxHeight;

//         return Stack(
//           fit: StackFit.expand,
//           children: [
//             // صورة الكاميرا
//             Image.asset(AssetsImage.secondStageCam01Image, fit: BoxFit.contain),

//             // خريطة الغرف
//             Positioned(
//               top: height * 0.05,
//               right: width * 0.025,
//               child: RoomsMapWidget(
//                 onRoomTap: onRoomTap,
//                 mapWidth: width * 0.22,
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// // ================= Widget خريطة الممرات المصغرة =================

// class RoomsMapWidget extends StatelessWidget {
//   final Function(String) onRoomTap;
//   final double mapWidth;

//   const RoomsMapWidget({
//     super.key,
//     required this.onRoomTap,
//     required this.mapWidth,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final mapHeight = mapWidth * 0.9;

//     return Container(
//       width: mapWidth,
//       height: mapHeight,
//       padding: EdgeInsets.all(mapWidth * 0.04),
//       decoration: BoxDecoration(
//         color: Colors.black.withValues(alpha: 0.5),
//         border: Border.all(color: Colors.white60, width: mapWidth * 0.007),
//         borderRadius: BorderRadius.circular(mapWidth * 0.04),
//       ),
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           final width = constraints.maxWidth;
//           final height = constraints.maxHeight;

//           return Stack(
//             children: [
//               // خطوط التوصيل بين الغرف
//               Positioned.fill(
//                 child: CustomPaint(painter: FiveRoomsLinesPainter()),
//               ),

//               // الغرفة الأولى
//               Positioned(
//                 top: height * 0.04,
//                 left: width * 0.36,
//                 child: buildRoomButton(
//                   'Room 1',
//                   width: width * 0.30,
//                   height: height * 0.16,
//                 ),
//               ),

//               // الغرفة الثانية
//               Positioned(
//                 top: height * 0.40,
//                 left: 0,
//                 child: buildRoomButton(
//                   'Room 2',
//                   width: width * 0.30,
//                   height: height * 0.16,
//                 ),
//               ),

//               // الغرفة الثالثة
//               Positioned(
//                 top: height * 0.37,
//                 left: width * 0.36,
//                 child: buildRoomButton(
//                   'Room 3',
//                   width: width * 0.32,
//                   height: height * 0.22,
//                 ),
//               ),

//               // الغرفة الرابعة
//               Positioned(
//                 top: height * 0.40,
//                 right: 0,
//                 child: buildRoomButton(
//                   'Room 4',
//                   width: width * 0.30,
//                   height: height * 0.16,
//                 ),
//               ),

//               // الغرفة الخامسة
//               Positioned(
//                 bottom: height * 0.04,
//                 left: width * 0.36,
//                 child: buildRoomButton(
//                   'Room 5',
//                   width: width * 0.30,
//                   height: height * 0.16,
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget buildRoomButton(
//     String name, {
//     required double width,
//     required double height,
//   }) {
//     return GestureDetector(
//       onTap: () => onRoomTap(name),
//       child: RoomButton(mapWidth: mapWidth,width: width,height: height,
//       name: name,),
//     );
//   }
// }
