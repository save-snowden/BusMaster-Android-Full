import 'package:bus_master/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
// Import the QRDataProvider
import 'qr_code_scanner_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BusNumberProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class Firebase {
  static initializeApp() {}
}

class AnimatedGif extends StatefulWidget {
  @override
  _AnimatedGifState createState() => _AnimatedGifState();
}

class _AnimatedGifState extends State<AnimatedGif> {
  bool gifLoaded = false;

  @override
  void initState() {
    super.initState();
    // Delay the home screen navigation by a few seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          gifLoaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return gifLoaded
        ? const MyHomePage()
        : Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/day_bus.gif', // Make sure the path is correct
                    gaplessPlayback: true, // Prevent flickering
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Loading',
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontSize: 24,
                      color: Colors.black, // Set text color to black
                    ),
                  ),
                  const SizedBox(height: 15), // Add spacing here
                  const CircularProgressIndicator(),
                ],
              ),
            ),
          );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);

    return MaterialApp(
      title: 'Bus Master',
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        fontFamily: 'Ubuntu',
      ),
      home: AnimatedGif(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isButtonScaling = false;
  double _fadeOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _startButtonAnimation();
  }

  void _startButtonAnimation() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isButtonScaling = true;
        });
      }
      // Start fading after a delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _fadeOpacity = 1.0;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bus Master',
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
        toolbarHeight: 0,
      ),
      body: Opacity(
        opacity: _fadeOpacity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 10),
              Image.asset('images/bus.gif'), // Your logo image
              const SizedBox(height: 30),
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(fontSize: 18),
                    children: <TextSpan>[
                      TextSpan(
                        text:
                            'Scan the QR code of your traveling bus after the journy starts to get more details.\n',
                        style: TextStyle(
                          fontFamily: 'Ubuntu',
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 500),
                tween: Tween<double>(begin: 1, end: 1.5),
                onEnd: () {
                  if (mounted) {
                    _startButtonAnimation();
                  }
                },
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: _isButtonScaling ? scale : 1.1,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to the QR code scanning page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRCodeScannerPage(),
                          ),
                        );
                      },
                      child: const Text('Click to scan the QR code'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
