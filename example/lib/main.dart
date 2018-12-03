import 'package:flutter/material.dart';
import 'package:wave/wave.dart';

void main() => runApp(WaveDemoApp());

class WaveDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wave Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WaveDemoHomePage(title: 'Wave Demo'),
    );
  }
}

class WaveDemoHomePage extends StatefulWidget {
  WaveDemoHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _WaveDemoHomePageState createState() => _WaveDemoHomePageState();
}

class _WaveDemoHomePageState extends State<WaveDemoHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 10.0,
        backgroundColor: Colors.blueGrey[800],
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {},
          )
        ],
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Container(
              height: 192,
              width: double.infinity,
              child: Card(
                elevation: 1.0,
                margin: EdgeInsets.all(16.0),
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4.0))),
                child: WaveWidget(
                  colorMode: ColorMode.custom,
                  colors: [
                    Colors.blue,
                    Colors.orange,
                    Colors.green,
                    Colors.lightBlueAccent,
                  ],
                  durations: [
                    32000,
                    21000,
                    18000,
                    5000,
                  ],
                  heightPercentages: [0.25, 0.32, 0.45, 0.52],
                  backgroundColor: Colors.transparent,
                  size: Size(double.infinity, double.infinity),
                ),
              ),
            ),
            Container(
              height: 192,
              width: double.infinity,
              child: Card(
                elevation: 1.0,
                margin: EdgeInsets.all(16.0),
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4.0))),
                child: WaveWidget(
                  colorMode: ColorMode.custom,
                  colors: [
                    Colors.white70,
                    Colors.white54,
                    Colors.white30,
                    Colors.white24,
                  ],
                  durations: [
                    32000,
                    21000,
                    18000,
                    5000,
                  ],
                  waveAmplitude: 0,
                  heightPercentages: [0.25, 0.26, 0.28, 0.31],
                  backgroundColor: Colors.blue,
                  size: Size(double.infinity, double.infinity),
                ),
              ),
            ),
            Container(
              height: 256,
              width: double.infinity,
              child: Card(
                elevation: 1.0,
                margin: EdgeInsets.all(16.0),
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4.0))),
                child: WaveWidget(
                  colorMode: ColorMode.custom,
                  colors: [
                    Color(0x4410BB99),
                    Color(0x335588BB),
                    Color(0x2288BBEE),
                    Color(0x2288BBEE),
                  ],
                  durations: [
                    7000,
                    5000,
                    18000,
                    35000,
                  ],
                  heightPercentages: [0.1, 0.13, 0.15, 0.09],
                  backgroundColor: Colors.transparent,
                  size: Size(double.infinity, double.infinity),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
