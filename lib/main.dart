import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testtaskflutter/full_photo.dart';

import 'models/photo_data.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Test Task',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PhotoListPage('Photos from Unsplash'),
    );
  }
}

class PhotoListPage extends StatelessWidget {
  PhotoListPage(this.title);

  final String title;
  Future<List<PhotoData>> _futurePhotosList;
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    initFuture();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder(
        future: _futurePhotosList,
        builder: (context, AsyncSnapshot<List<PhotoData>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.all(8),
                child: InkWell(
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => FullPhotoScreen(snapshot.data[index].fullPhotoUrl))),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            snapshot.data[index].smallPhotoBytes,
                            height: 64,
                            width: 64,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                (snapshot.data[index].name == null || snapshot.data[index].name == "")
                                    ? "Without description"
                                    : snapshot.data[index].name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                snapshot.data[index].author,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 14, color: Colors.black38),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }

  void initFuture() {
    final baseUrl = "https://api.unsplash.com";
    final clientId = "cf49c08b444ff4cb9e4d126b7e9f7513ba1ee58de7906e4360afc1a33d1bf4c0";
    _futurePhotosList = http.get("$baseUrl/photos?client_id=$clientId").catchError((e) {
      print(e.message);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 1),
        backgroundColor: Colors.red,
        content: Text("Ошибка получения фото"),
      ));
    }).then((response) async {
      List<PhotoData> resultList = [];
      if (response.statusCode == 200) {
        print(response.body);
        await Future.forEach(json.decode(response.body), (photoMap) async {
          final response = await http.get(photoMap["urls"]["small"]);
          print(response.bodyBytes);
          resultList.add(PhotoData(response.bodyBytes, photoMap["urls"]["full"], photoMap["user"]["name"],
              photoMap["description"] ?? photoMap["alt_description"] ?? ""));
        });
      } else {
        print(response.statusCode);
      }
      return resultList;
    });
    ;
  }
}
