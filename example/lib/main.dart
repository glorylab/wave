import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

void main() => runApp(WaveDemoApp());

final String appName = 'Demo WAVE';
final String repoURL = 'https://github.com/glorylab/wave';

class WaveDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: WaveDemoHomePage(title: appName),
    );
  }
}

class WaveDemoHomePage extends StatefulWidget {
  WaveDemoHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _WaveDemoHomePageState createState() => _WaveDemoHomePageState();
}

class _WaveDemoHomePageState extends State<WaveDemoHomePage> {
  
  var wave = WaveWidget(
                      config: CustomConfig(
                        gradients: [
                          [Colors.red, Color(0xEEF44336)],
                          [Colors.red[800]!, Color(0x77E57373)],
                          [Colors.orange, Color(0x66FF9800)],
                          [Colors.yellow, Color(0x55FFEB3B)]
                        ],
                        durations: [35000, 19440, 10800, 6000],
                        heightPercentages: [0.20, 0.23, 0.25, 0.30],
                        gradientBegin: Alignment.bottomLeft,
                        gradientEnd: Alignment.topRight,
                      ),
                      backgroundColor: Colors.purpleAccent,
                      size: Size(double.infinity, double.infinity),
                      waveAmplitude: 0,
                    );

  double marginHorizontal = 16.0;

  void _launchUrl(url) async {
    if (!await launchUrl(Uri.parse(url))) throw 'Could not launch $url';
  }

  @override
  Widget build(BuildContext context) {
    marginHorizontal =
        16.0 + (MediaQuery.of(context).size.width > 512 ? (MediaQuery.of(context).size.width - 512) / 2 : 0);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
        elevation: 2.0,
        actions: [
          IconButton(
            onPressed: () {
              _launchUrl(repoURL);
            },
            icon: Image.asset(
              'icons/ic_github.png',
              package: 'web3_icons',
              width: 32.0,
              height: 32.0,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: <Widget>[
                SizedBox(height: 16.0),
                Container(
                  height: 152,
                  width: double.infinity,
                  child: Card(
                    elevation: 12.0,
                    margin: EdgeInsets.only(right: marginHorizontal, left: marginHorizontal, bottom: 16.0),
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
                    child: wave,
                    // WaveWidget(
                    //   config: CustomConfig(
                    //     gradients: [
                    //       [Colors.red, Color(0xEEF44336)],
                    //       [Colors.red[800]!, Color(0x77E57373)],
                    //       [Colors.orange, Color(0x66FF9800)],
                    //       [Colors.yellow, Color(0x55FFEB3B)]
                    //     ],
                    //     durations: [35000, 19440, 10800, 6000],
                    //     heightPercentages: [0.20, 0.23, 0.25, 0.30],
                    //     gradientBegin: Alignment.bottomLeft,
                    //     gradientEnd: Alignment.topRight,
                    //   ),
                    //   backgroundColor: Colors.purpleAccent,
                    //   size: Size(double.infinity, double.infinity),
                    //   waveAmplitude: 0,
                    // ),
                  ),
                ),
                // Align(
                //   child: Container(
                //     height: 128,
                //     width: 128,
                //     decoration:
                //         BoxDecoration(shape: BoxShape.circle, boxShadow: [
                //       BoxShadow(
                //         color: Color(0xFF9B5DE5),
                //         blurRadius: 2.0,
                //         spreadRadius: -5.0,
                //         offset: Offset(0.0, 8.0),
                //       ),
                //     ]),
                //     child: ClipOval(
                //       child: WaveWidget(
                //         config: CustomConfig(
                //           colors: [
                //             Color(0xFFFEE440),
                //             Color(0xFF00BBF9),
                //           ],
                //           durations: [
                //             5000,
                //             4000,
                //           ],
                //           heightPercentages: [
                //             0.65,
                //             0.66,
                //           ],
                //         ),
                //         backgroundColor: Color(0xFFF15BB5),
                //         size: Size(double.infinity, double.infinity),
                //         waveAmplitude: 0,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { wave.animating ? wave.pause() : wave.start(); },
      ),
    );
  }
}
