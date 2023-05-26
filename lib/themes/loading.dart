import 'package:flutter/material.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _currentIndex++;
          if (_currentIndex == 3) {
            _currentIndex = 0;
          }
          _animationController!.reset();
          _animationController!.forward();
        }
      });
    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController!,
      builder: (context, child) {
        return Container(
          height: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Opacity(
                opacity: index == _currentIndex ? 1.0 : 0.2,
                child: const Text(
                  '°',
                  textScaleFactor: 3,
                ),
              );
            }),
          ),
        );
      },
    );

    // return Container(
    //   margin: const EdgeInsets.only(bottom: 10,right: 100),
    //   child: Padding(
    //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       mainAxisAlignment: MainAxisAlignment.start,
    //       children: [
    //         Container(
    //           padding: EdgeInsets.all(15),
    //           constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
    //           decoration: BoxDecoration(
    //               color: Colors.grey.shade800,
    //               borderRadius: const BorderRadius.only(
    //                 topLeft: Radius.circular(15),
    //                 topRight: Radius.circular(15),
    //                 bottomLeft: Radius.circular(0),
    //                 bottomRight: Radius.circular(15),
    //               )
    //           ),
    //           child: Column(
    //             children: [
    //               const Text(
    //                 textAlign: TextAlign.left,
    //                 'GPT',
    //                 style: TextStyle(fontWeight: FontWeight.bold),
    //               ),
    //               const SizedBox(height: 7),
    //               AnimatedBuilder(
    //                animation: _animationController!,
    //                builder: (context, child) {
    //               return Row(
    //                   mainAxisAlignment: MainAxisAlignment.center,
    //                   children: List.generate(3, (index) {
    //                 return Opacity(
    //                   opacity: index == _currentIndex ? 1.0 : 0.2,
    //                   child: const Text(
    //                     '.',
    //                     textScaleFactor: 4,
    //                   ),
    //                 );
    //               }),
    //               );
    //               },
    //              ),
    //             ],
    //           ),
    //         ),
    //       ],
    //     ),
    // ),
    // );
  }
}

