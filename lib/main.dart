import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ui.Image image;
  Uint8List imageOk;
  Uint8List imageFail;

  DrawingPainter painter;

  Future<ui.Image> load(String asset) async { 
    var data = await rootBundle.load(asset);
    var codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    var fi = await codec.getNextFrame();
    return fi.image;
  }

  void _create() async {
    var img = await load("images/image.jpeg");
    setState(() {
     image = img; 
    });
  }

  void _draw() async {
    var imgRes = await painter.rendered;
    var fileData = await imgRes.toByteData(format: ui.ImageByteFormat.png);
    print('Length: ${fileData.lengthInBytes}');
    if(fileData.lengthInBytes < 10000) {
      setState(() {
        imageFail = fileData.buffer.asUint8List(); 
      });
    } else {
      setState(() {
        imageOk = fileData.buffer.asUint8List(); 
      });
    }
  }

  void initState() {
    super.initState();
    _create();
  }

  @override
  Widget build(BuildContext context) {
    painter = DrawingPainter(
      image: image,
      canvasSize: Size(300, 300)
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: image != null ? CustomPaint(
                size: Size(300, 300),
                painter: painter,
              ) : Container(),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              child: imageOk != null ? Image.memory(imageOk) : Container(),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: imageFail != null ? Image.memory(imageFail) : Container(),
            )
          ]
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _draw,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}


class DrawingPainter extends CustomPainter {
  ui.Image image;
  Size canvasSize;
  double sizeFactor;
  DrawingPainter({this.image, this.canvasSize});
  Paint brush = Paint()..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(image, Rect.fromLTRB(0, 0, 300, 300), Rect.fromLTRB(0,0, 300, 300), brush);
    canvas.drawLine(Offset(0,0), Offset(300,300), brush);
  }

  Future<ui.Image> get rendered async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    DrawingPainter painter = DrawingPainter(
      canvasSize: canvasSize,
      image: image
    );
    painter.paint(canvas, canvasSize);
    var picture = recorder.endRecording();
    return await picture.toImage(canvasSize.width.toInt(), canvasSize.height.toInt());
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}