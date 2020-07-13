import 'dart:typed_data';

class PhotoData {
  Uint8List smallPhotoBytes;
  String fullPhotoUrl;
  String author;
  String name;

  PhotoData(this.smallPhotoBytes, this.fullPhotoUrl, this.author, this.name);
}
