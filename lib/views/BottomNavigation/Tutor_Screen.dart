import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mytutor2/model/tutor.dart';
import 'package:http/http.dart' as http;

import '../../constant.dart';

class TutorScreen extends StatefulWidget {
  const TutorScreen({Key? key}) : super(key: key);

  @override
  State<TutorScreen> createState() => TutorScreenState();
}

class TutorScreenState extends State<TutorScreen> {
  List<Tutor> tutorlist = <Tutor>[];
  String titlecenter = "Loading...";
  var numofpage, curpage = 1;
  late double screenHeight, screenWidth, resWidth;
  String search = "";
  var color;

  @override
  void initState() {
    super.initState();
    _loadTutors(1);
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 600) {
      resWidth = screenWidth;
      //rowcount = 2;
    } else {
      resWidth = screenWidth * 0.75;
      //rowcount = 3;
    }
    return Scaffold(
      body: tutorlist.isEmpty
          ? Center(
              child: Text(titlecenter,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)))
          : Column(children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text("Tutor Available",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                  child: GridView.count(
                      crossAxisCount: 2,
                      children: List.generate(tutorlist.length, (index) {
                        return Card(
                          child: Column(children: [
                            Flexible(
                              flex: 6,
                              child: CachedNetworkImage(
                                imageUrl: CONSTANTS.server +
                                    "/Mobile/assets/tutors/" +
                                    tutorlist[index].tutorId.toString() +
                                    '.jpg',
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error_outline),
                              ),
                            ),
                            Flexible(
                                flex: 4,
                                child: Column(
                                  children: [
                                    Text(tutorlist[index].tutorName.toString())
                                  ],
                                ))
                          ]),
                        );
                      }))),
              SizedBox(
                height: 30,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: numofpage,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    if ((curpage - 1) == index) {
                      color = Colors.blueGrey;
                    } else {
                      color = Colors.black;
                    }
                    return SizedBox(
                      width: 40,
                      child: TextButton(
                          onPressed: () => {_loadTutors(index)},
                          child: Text(
                            (index + 1).toString(),
                            style: TextStyle(color: color),
                          )),
                    );
                  },
                ),
              ),
            ]),
    );
  }

  void _loadTutors(int pageno) {
    curpage = pageno;
    numofpage ?? 1;
    http.post(Uri.parse(CONSTANTS.server + "/Mobile/php/load_tutor.php/"),
        body: {
          'pageno': pageno.toString()
        }).timeout(const Duration(seconds: 5), onTimeout: () {
      return http.Response('Error', 408);
    }).then((response) {
      var jsondata = jsonDecode(response.body);

      print(jsondata);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        var extractdata = jsondata['data'];
        numofpage = int.parse(jsondata['numofpage']);

        if (extractdata['tutor'] != null) {
          tutorlist = <Tutor>[];
          extractdata['tutor'].forEach((v) {
            tutorlist.add(Tutor.fromJson(v));
          });
          titlecenter = tutorlist.length.toString() + " Tutor Available";
        } else {
          titlecenter = "No Tutor Available";
          tutorlist.clear();
        }
        setState(() {});
      }
    });
  }
}
