import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class Json_Render extends StatefulWidget {
  const Json_Render({Key? key}) : super(key: key);

  @override
  State<Json_Render> createState() => _Json_RenderState();
}

class _Json_RenderState extends State<Json_Render> {
  List givendata=[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("json"),
      ),
      body: ListView.builder(
        itemCount: givendata.length,
        itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.all(15),
          child: Text(givendata[index]["body"]),
        );
      },),
    );
  }
  Future<String> loadData() async {
    print("aravind");
    var data = await rootBundle.loadString("json/givenfile.json");
    print("aravind");
    setState(() {
      givendata = json.decode(data);
      print(givendata);
      print("givendata");
    });
    return "success";
  }
}
