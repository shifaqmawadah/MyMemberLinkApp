import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_member_link/models/news.dart';
import 'package:my_member_link/myconfig.dart';
import 'package:my_member_link/views/edit_news.dart';
import 'package:my_member_link/views/mydrawer.dart';
import 'package:my_member_link/views/new_news.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<News> newsList = [];
  final df = DateFormat('dd/MM/yyyy hh:mm a');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadNewsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Newsletter"),
        ),
        body: newsList.isEmpty
            ? const Center(
                child: Text("Loading..."),
              )
            : ListView.builder(
                itemCount: newsList.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      onLongPress: () {
                        deleteDialog(index);
                      },
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            truncateString(
                                newsList[index].newsTitle.toString(), 30),
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            df.format(DateTime.parse(
                                newsList[index].newsDate.toString())),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        truncateString(
                            newsList[index].newsDetails.toString(), 100),
                        textAlign: TextAlign.justify,
                      ),

                      // leading: const Icon(Icons.article),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.arrow_forward,
                        ),
                        onPressed: () {
                          showNewsDetailsDialog(index);
                        },
                      ),
                    ),
                  );
                }),
        drawer: const MyDrawer(),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // loadNewsData();
            await Navigator.push(context,
                MaterialPageRoute(builder: (content) => const NewNewsScreen()));
            loadNewsData();
          },
          child: const Icon(Icons.add),
        ));
  }

  String truncateString(String str, int length) {
    if (str.length > length) {
      str = str.substring(0, length);
      return "$str...";
    } else {
      return str;
    }
  }

  void loadNewsData() {
    http
        .get(Uri.parse("${MyConfig.servername}/memberlink/api/load_news.php"))
        .then((response) {
      //  log(response.body.toString());
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          var result = data['data']['news'];
          newsList.clear();
          for (var item in result) {
            News news = News.fromJson(item);
            newsList.add(news);
          }
          setState(() {});
        }
      } else {
        print("Error");
      }
    });
  }

  void showNewsDetailsDialog(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(newsList[index].newsTitle.toString()),
            content: Text(newsList[index].newsDetails.toString(),
                textAlign: TextAlign.justify),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  News news = newsList[index];

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (content) => EditNewsScreen(news: news)));
                },
                child: const Text("Edit?"),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Close"))
            ],
          );
        });
  }

  void deleteDialog(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Delete \"${truncateString(newsList[index].newsTitle.toString(), 20)}\"",
              style: const TextStyle(fontSize: 18),
            ),
            content: const Text("Are you sure you want to delete this news?"),
            actions: [
              TextButton(
                  onPressed: () {
                    deleteNews(index);
                    Navigator.pop(context);
                  },
                  child: const Text("Yes")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("No"))
            ],
          );
        });
  }

  void deleteNews(int index) {
    http.post(
        Uri.parse("${MyConfig.servername}/memberlink/api/delete_news.php"),
        body: {"newsid": newsList[index].newsId.toString()}).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        log(data.toString());
        if (data['status'] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Success"),
            backgroundColor: Colors.green,
          ));
          loadNewsData(); //reload data
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Failed"),
            backgroundColor: Colors.red,
          ));
        }
      }
    });
  }
}