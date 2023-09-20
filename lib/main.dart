////11111111

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
// import 'package:kplayer/kplayer.dart';
import 'package:learn_alphabet/constants.dart';
import 'package:learn_alphabet/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );
  runApp(const LearnAlphabetApp());
}

class LearnAlphabetApp extends StatelessWidget {
  const LearnAlphabetApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: SplashScreen());
  }
}

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  // String currentAlphabet = "A";
  AudioPlayer _audioPlayer;

  AnimationController controller;
  Animation<double> imageScale;
  Animation<double> wordScale;
  Animation<double> imageRotation;
  Animation<double> wordRotation;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1300));

    imageScale = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: const Interval(0.0, 0.5)));

    imageRotation = Tween<double>(begin: 5, end: 0).animate(
        CurvedAnimation(parent: controller, curve: const Interval(0.0, 0.5)));

    wordScale = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: const Interval(0.5, 1.0)));

    wordRotation = Tween<double>(begin: 5, end: 0).animate(
        CurvedAnimation(parent: controller, curve: const Interval(0.5, 1.0)));

    controller.forward();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    controller.dispose();
    // _audioPlayer.dispose();
    super.dispose();
  }

  void _playAudio(String assetPath) async {
    // _audioPlayer.pause();
    assetPath = ("assets/audio/$currentAlphabet.mp3");
    try {
      await _audioPlayer.setAsset(assetPath);
      _audioPlayer.play();
    } catch (e) {
      debugPrint("Error loading audio source: $e");
    }
  }

  String currentAlphabet = "A";
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SafeArea(
        top: true,
        child: Scaffold(
          backgroundColor: Colors.amber[200],
          body: LayoutBuilder(builder: (context, constraints) {
            var height = constraints.maxHeight;
            var width = constraints.maxWidth;
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                sentenceHolder(height, width),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    imageHolder(height, width),
                    wordHolder(height, width),
                  ],
                ),
                Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(15)),
                  child: Wrap(
                    children: changePos(),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  List<Widget> changePos() {
    List<Widget> children = [
      ...alphabets
          .map(
            (e) => textHolder(e),
          )
          .toList()
    ];
    // children.shuffle();

    return children;
  }

  // Widget wordHolder(double height, double width) {
  //   animationController.reset();
  //   animationController.forward();
  //   return Container(
  //     height: height * 0.2,
  //     width: width * 0.35,
  //     decoration: BoxDecoration(
  //         color: Colors.blue[200], borderRadius: BorderRadius.circular(15)),
  //     child: Center(child: Text(collection[currentAlphabet]["word"])),
  //   );
  // }

  Widget wordHolder(double height, double width) {
    return AnimatedBuilder(
      animation: Listenable.merge([wordRotation, wordScale]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          height: height * 0.2,
          width: width * 0.35,
          decoration: BoxDecoration(
            border: Border.all(width: 6, color: Colors.green),
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
              child: Text(
            collection[currentAlphabet]["word"],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          )),
        ),
      ),
      builder: (context, child) {
        return ScaleTransition(
          scale: wordScale,
          child: Transform.rotate(angle: wordRotation.value, child: child),
        );
      },
    );
  }

  Widget imageHolder(double height, double width) {
    return AnimatedBuilder(
        animation: Listenable.merge([imageRotation, imageScale]),
        child: ImageDisplayer(
          height,
          width,
          currentAlphabet: currentAlphabet,
        ),
        builder: (context, child) {
          return ScaleTransition(
              scale: imageScale,
              child:
                  Transform.rotate(angle: imageRotation.value, child: child));
        });
  }

  Widget sentenceHolder(double height, double width) {
    return Container(
      height: height * 0.1,
      width: width * 0.7,
      decoration: BoxDecoration(
          color: Colors.blue[200], borderRadius: BorderRadius.circular(15)),
      child: Center(child: Text(collection[currentAlphabet]["sentence"])),
    );
  }

  Widget textHolder(String alphabet) {
    return Padding(
      padding: const EdgeInsets.all(7),
      child: ElevatedButton(
        onPressed: () {
          currentAlphabet = alphabet;
          // playAudio("assets/audio/$alphabet.wav");

          controller.status == AnimationStatus.dismissed
              ? controller.forward()
              : {controller.reset(), controller.forward()};
          _playAudio(currentAlphabet);
          setState(() {});
        },
        child: Text(alphabet),
      ),
    );
  }
}

class ImageDisplayer extends StatefulWidget {
  const ImageDisplayer(
    this.height,
    this.width, {
    Key key,
    this.currentAlphabet,
  }) : super(key: key);
  final double height;
  final double width;
  final String currentAlphabet;

  @override
  State<ImageDisplayer> createState() => _ImageDisplayerState();
}

class _ImageDisplayerState extends State<ImageDisplayer>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: widget.height * 0.2,
        width: widget.width * 0.35,
        // decoration: BoxDecoration(
        //     // color: Colors.blue[200],

        //     // borderRadius: BorderRadius.circular(15),
        //     ),
        child: Image.asset(
          collection[widget.currentAlphabet]["image"],
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}

enum AnmState {
  Option1Complete,
  Option2Complete,
}
//2222222222222  other way
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:just_audio/just_audio.dart';
// // import 'package:kplayer/kplayer.dart';
// import 'package:learn_alphabet/constants.dart';
// import 'package:learn_alphabet/splash_screen.dart';
// import 'dart:math';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   SystemChrome.setPreferredOrientations(
//     [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
//   );
//   runApp(const LearnAlphabetApp());
// }

// class LearnAlphabetApp extends StatelessWidget {
//   const LearnAlphabetApp({Key key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//         debugShowCheckedModeBanner: false, home: SplashScreen());
//   }
// }

// class Home extends StatefulWidget {
//   const Home({Key key}) : super(key: key);

//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
//   AnimationController animationController;
//   Animation<double> rotation;
//   Animation<double> scale;
//   AnmState get anmState => _anmState;
//   AnmState _anmState;

//   set setAnmState(AnmState e) {
//     _anmState = e;

//     setState(() {});
//   }

//   String currentAlphabet = "A";
//   AudioPlayer _audioPlayer;
//   @override
//   void initState() {
//     animationController = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 1000));
//     rotation = Tween(begin: -pi * 2, end: 0.0).animate(animationController);
//     scale = CurveTween(
//       curve: Curves.easeInOutCubic,
//     ).animate(animationController);

//     _audioPlayer = AudioPlayer();
//     // TODO: implement initState
//     super.initState();
//   }

//   @override
//   void dispose() {
//     animationController.stop();
//     animationController.reset();

//     // _audioPlayer.dispose();
//     super.dispose();
//   }

//   void _playAudio(String assetPath) async {
//     _audioPlayer.pause();
//     assetPath = ("assets/audio/$currentAlphabet.mp3");
//     try {
//       await _audioPlayer.setAsset(assetPath);
//       _audioPlayer.play();
//     } catch (e) {
//       debugPrint("Error loading audio source: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: SafeArea(
//         top: true,
//         child: Scaffold(
//           backgroundColor: Colors.amber[200],
//           body: LayoutBuilder(builder: (context, constraints) {
//             var height = constraints.maxHeight;
//             var width = constraints.maxWidth;
//             return Column(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 sentenceHolder(height, width),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     imageHolder(height, width),
//                     wordHolder(height, width),
//                   ],
//                 ),
//                 Container(
//                   decoration:
//                       BoxDecoration(borderRadius: BorderRadius.circular(15)),
//                   child: Wrap(
//                     children: changePos(),
//                   ),
//                 ),
//               ],
//             );
//           }),
//         ),
//       ),
//     );
//   }

//   List<Widget> changePos() {
//     List<Widget> children = [
//       ...alphabets
//           .map(
//             (e) => textHolder(e),
//           )
//           .toList()
//     ];
//     // children.shuffle();

//     return children;
//   }

//   // Widget wordHolder(double height, double width) {
//   //   animationController.reset();
//   //   animationController.forward();
//   //   return Container(
//   //     height: height * 0.2,
//   //     width: width * 0.35,
//   //     decoration: BoxDecoration(
//   //         color: Colors.blue[200], borderRadius: BorderRadius.circular(15)),
//   //     child: Center(child: Text(collection[currentAlphabet]["word"])),
//   //   );
//   // }

//   Widget wordHolder(double height, double width) {
//     animationController.reset();
//     animationController.forward();
//     return AnimatedBuilder(
//         animation: Listenable.merge([rotation, scale]),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(15),
//           child: Container(
//             height: height * 0.2,
//             width: width * 0.35,
//             decoration: BoxDecoration(
//               border: Border.all(width: 6, color: Colors.green),
//               color: Colors.orange.shade100,
//               borderRadius: BorderRadius.circular(25),
//             ),
//             child: Center(
//                 child: Text(
//               collection[currentAlphabet]["word"],
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             )),
//           ),
//         ),
//         builder: (context, child) {
//           return ScaleTransition(
//               scale: scale,
//               child: Transform.rotate(angle: rotation.value, child: child));
//         });
//   }

//   Widget imageHolder(double height, double width) {
//     animationController.reset();
//     animationController.forward();

//     return AnimatedBuilder(
//         animation: Listenable.merge([rotation, scale]),
//         child: ImageDisplayer(
//           height,
//           width,
//           currentAlphabet: currentAlphabet,
//         ),
//         builder: (context, child) {
//           return ScaleTransition(
//               scale: scale,
//               child: Transform.rotate(angle: rotation.value, child: child));
//         });
//   }

//   Widget sentenceHolder(double height, double width) {
//     return Container(
//       height: height * 0.1,
//       width: width * 0.7,
//       decoration: BoxDecoration(
//           color: Colors.blue[200], borderRadius: BorderRadius.circular(15)),
//       child: Center(child: Text(collection[currentAlphabet]["sentence"])),
//     );
//   }

//   Widget textHolder(String alphabet) {
//     return Padding(
//       padding: const EdgeInsets.all(7),
//       child: ElevatedButton(
//         onPressed: () {
//           currentAlphabet = alphabet;
//           // playAudio("assets/audio/$alphabet.wav");
//           _playAudio(currentAlphabet);
//           setState(() {});
//         },
//         child: Text(alphabet),
//       ),
//     );
//   }
// }

// class ImageDisplayer extends StatefulWidget {
//   const ImageDisplayer(
//     this.height,
//     this.width, {
//     Key key,
//     this.currentAlphabet,
//   }) : super(key: key);
//   final double height;
//   final double width;
//   final String currentAlphabet;

//   @override
//   State<ImageDisplayer> createState() => _ImageDisplayerState();
// }

// class _ImageDisplayerState extends State<ImageDisplayer>
//     with SingleTickerProviderStateMixin {
//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(15),
//       child: Container(
//         height: widget.height * 0.2,
//         width: widget.width * 0.35,
//         // decoration: BoxDecoration(
//         //     // color: Colors.blue[200],

//         //     // borderRadius: BorderRadius.circular(15),
//         //     ),
//         child: Image.asset(
//           collection[widget.currentAlphabet]["image"],
//           fit: BoxFit.fill,
//         ),
//       ),
//     );
//   }
// }

// enum AnmState {
//   Option1Complete,
//   Option2Complete,
// }

// ///////333333               other way
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';

// import 'package:learn_alphabet/constants.dart';

// void main() {
//   // Player.boot();
//   runApp(const LearnAlphabetApp());
// }

// String currentAlphabet = "A";
// AudioPlayer _audioPlayer;

// class LearnAlphabetApp extends StatelessWidget {
//   const LearnAlphabetApp({Key key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(debugShowCheckedModeBanner: false, home: Home());
//   }
// }

// class Home extends StatefulWidget {
//   const Home({Key key}) : super(key: key);

//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   @override
//   void initState() {
//     // _audioPlayer.pause();
//     _audioPlayer = AudioPlayer();
//     // TODO: implement initState
//     super.initState();
//   }

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//   }

//   void _playAudio(String assetPath) async {
//     _audioPlayer.pause();
//     assetPath = ("assets/audio/$currentAlphabet.mp3");
//     try {
//       await _audioPlayer.setAsset(assetPath);
//       _audioPlayer.play();
//     } catch (e) {
//       debugPrint("Error loading audio source: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: SafeArea(
//         child: Scaffold(
//           backgroundColor: Colors.amber.shade100,
//           body: LayoutBuilder(builder: (context, constraints) {
//             var height = constraints.maxHeight;
//             var width = constraints.maxWidth;
//             return Column(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 // sentenceHolder(height, width),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     imageHolder(height, width),
//                     // wordHolder(height, width),
//                   ],
//                 ),
//                 // Container(
//                 //   decoration:
//                 //       BoxDecoration(borderRadius: BorderRadius.circular(15)),
//                 //   child: Wrap(
//                 //     crossAxisAlignment: WrapCrossAlignment.center,
//                 //     children: changePos(),
//                 //   ),
//                 // ),

//                 GridView(
//                   shrinkWrap: true,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 6),
//                   children: [
//                     ...List.generate(alphabets.length, (index) {
//                       return textHolder(alphabets[index]);
//                     }),
//                   ],
//                 ),
//               ],
//             );
//           }),
//         ),
//       ),
//     );
//   }

//   void _showLetterDialog(BuildContext context, String letter) {
//     // final _statesController = MaterialStatesController();
//     // _statesController.update(
//     //   MaterialState.disabled,
//     //   false, // or false depending on your logic
//     // );
//     showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (BuildContext context) {
//         return SizedBox(
//           height: 60,
//           width: 60,
//           child: Padding(
//             padding: EdgeInsets.all(20),
//             child: AlertDialog(
//               // actionsAlignment: MainAxisAlignment.end,
//               backgroundColor: Colors.transparent,
//               alignment: Alignment.bottomRight * 1.06,
//               contentPadding: EdgeInsets.zero,
//               shape: Border.all(width: 4, color: Colors.transparent),
//               actions: [
//                 Center(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       ElevatedButton(
//                         style: ButtonStyle(
//                           backgroundColor:
//                               MaterialStateProperty.all<Color>(Colors.green),
//                         ),
//                         onPressed: () {
//                           _playAudio(currentAlphabet);
//                           setState(() {});
//                         },
//                         child: Text("Play Sound"),
//                       ),
//                       SizedBox(
//                         width: 30,
//                       ),
//                       ElevatedButton(
//                         style: ButtonStyle(
//                           backgroundColor:
//                               MaterialStateProperty.all<Color>(Colors.red),
//                         ),
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                           setState(() {});
//                         },
//                         child: Text("Close"),
//                       ),

//                       // TextButton(
//                       //   child: Text('Play Sound'),
//                       //   onPressed: () {
//                       //     playAudio(letter);
//                       //     setState(() {});
//                       //   },
//                       // ),

//                       // TextButton(
//                       //   child: Text('Close'),
//                       //   onPressed: () {
//                       //     Navigator.of(context).pop();
//                       //   },
//                       // ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   List<Widget> changePos() {
//     List<Widget> children = [
//       ...alphabets
//           .map(
//             (e) => textHolder(e),
//           )
//           .toList()
//     ];
//     // children.shuffle();

//     return children;
//   }

//   Widget wordHolder(double height, double width) {
//     return Container(
//       height: height * 0.1,
//       width: width * 0.30,
//       decoration: BoxDecoration(
//           color: Colors.blue[200], borderRadius: BorderRadius.circular(15)),
//       child: Center(child: Text(collection[currentAlphabet]["word"])),
//     );
//   }

//   Widget imageHolder(double height, double width) {
//     return ImageDisplayer(
//       height,
//       width,
//       currentAlphabet: currentAlphabet,
//     );
//   }

//   Widget sentenceHolder(double height, double width) {
//     return Container(
//       height: height * 0.1,
//       width: width * 0.7,
//       decoration: BoxDecoration(
//           color: Colors.blue[200], borderRadius: BorderRadius.circular(15)),
//       child: Center(child: Text(collection[currentAlphabet]["sentence"])),
//     );
//   }

//   Widget textHolder(String alphabet) {
//     return Padding(
//       padding: const EdgeInsets.all(5.0),
//       child: ElevatedButton(
//         onPressed: () {
//           currentAlphabet = alphabet;
//           // _showLetterDialog(context, alphabet);
//           _playAudio(currentAlphabet);
//           setState(() {});
//         },
//         child: Text(alphabet),
//       ),
//     );
//   }
// }

// class ImageDisplayer extends StatefulWidget {
//   const ImageDisplayer(
//     this.height,
//     this.width, {
//     Key key,
//     this.currentAlphabet,
//   }) : super(key: key);
//   final double height;
//   final double width;
//   final String currentAlphabet;

//   @override
//   State<ImageDisplayer> createState() => _ImageDisplayerState();
// }

// class _ImageDisplayerState extends State<ImageDisplayer>
//     with SingleTickerProviderStateMixin {
//   AudioPlayer _audioPlayer;
//   Animation<double> animation;
//   AnimationController animationController;
//   @override
//   void initState() {
//     animationController = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 1),
//     );
//     animation = Tween(begin: 0.0, end: 1.0).animate(animationController);
//     animationController.forward();
//     super.initState();
//     _audioPlayer = AudioPlayer();
//   }

//   @override
//   void dispose() {
//     animationController.stop();
//     animationController.reset();
//     super.dispose();
//   }

//   void _playAudio(String assetPath) async {
//     _audioPlayer.pause();
//     assetPath = ("assets/audio/$currentAlphabet.mp3");
//     try {
//       await _audioPlayer.setAsset(assetPath);
//       _audioPlayer.play();
//     } catch (e) {
//       debugPrint("Error loading audio source: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     animationController.reset();
//     animationController.forward();
//     return Center(
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           FadeTransition(
//             opacity: animation,
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(15),
//               child: Container(
//                 height: widget.height * 0.2,
//                 width: widget.width * 0.35,
//                 decoration: BoxDecoration(
//                     color: Colors.blue[200],
//                     borderRadius: BorderRadius.circular(15)),
//                 child: Image.asset(
//                   collection[widget.currentAlphabet]["image"],
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(
//             width: 20,
//           ),
//           // IconButton(
//           //     onPressed: () {
//           //       _playAudio(currentAlphabet);
//           //     },
//           //     icon: Icon(
//           //       Icons.mic_outlined,
//           //       color: Colors.purple,
//           //       size: 60,
//           //     )),
//         ],
//       ),
//     );
//   }
// }
