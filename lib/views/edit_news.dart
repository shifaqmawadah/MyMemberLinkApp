import 'package:flutter/material.dart';
import 'package:my_member_link/models/news.dart';

class EditNewsScreen extends StatefulWidget {
  final News news;
  const EditNewsScreen({super.key, required this.news});

  @override
  State<EditNewsScreen> createState() => _EditNewsState();
}

class _EditNewsState extends State<EditNewsScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController detailsController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    titleController.text = widget.news.newsTitle.toString();
    detailsController.text = widget.news.newsDetails.toString();
  }

  late double screenWidth, screenHeight;
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Newsletter"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      hintText: "News Title")),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: screenHeight * 0.7,
                child: TextField(
                  controller: detailsController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      hintText: "News Details"),
                  maxLines: screenHeight ~/ 35,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              MaterialButton(
                  elevation: 10,
                  onPressed: onUpdateNewsDialog,
                  minWidth: screenWidth,
                  height: 50,
                  // color: Colors.blueAccent,
                  child: const Text("Update News",
                      style: TextStyle(color: Colors.white))),
            ],
          ),
        ),
      ),
    );
  }

  void onUpdateNewsDialog() {}
}