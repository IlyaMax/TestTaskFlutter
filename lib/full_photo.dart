import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FullPhotoScreen extends StatelessWidget {
  String _downloadUrl;

  FullPhotoScreen(this._downloadUrl);

  @override
  Widget build(BuildContext context) {
    Future<Uint8List> _photoFuture = http.get(_downloadUrl).then((response) => response.bodyBytes);
    return FutureBuilder(
      future: _photoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          return Image.memory(snapshot.data);
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
