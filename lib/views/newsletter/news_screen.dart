import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_member_link/models/news.dart';
import 'package:my_member_link/myconfig.dart';
import 'package:my_member_link/views/newsletter/edit_news.dart';
import 'package:my_member_link/views/shared/mydrawer.dart';
import 'package:my_member_link/views/newsletter/new_news.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<News> newsList = [];
  final df = DateFormat('dd/MM/yyyy hh:mm a');
  int numofpage = 1;
  int curpage = 1;
  int numofresult = 0;
  late double screenWidth, screenHeight;
  var color;
  
  // New variables for search and filter
  TextEditingController searchController = TextEditingController();
  String selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    loadNewsData();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Newsletter"),
          actions: [
            IconButton(
                onPressed: () {
                  loadNewsData();
                },
                icon: const Icon(Icons.refresh))
          ],
        ),
        body: Column(
          children: [
            // Search and Filter Widgets
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: "Search News",
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            loadNewsData();
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: selectedFilter,
                    items: <String>["All", "Last 7 days", "This Month"]
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedFilter = value!;
                      });
                      loadNewsData(); // Reload data with selected filter
                    },
                  ),
                ],
              ),
            ),
            newsList.isEmpty
                ? const Center(
                    child: Text("Loading..."),
                  )
                : Expanded(
                    child: ListView.builder(
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
                                        newsList[index].newsTitle.toString(),
                                        30),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
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
                                    newsList[index].newsDetails.toString(),
                                    100),
                                textAlign: TextAlign.justify,
                              ),
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
                  ),
            SizedBox(
              height: screenHeight * 0.05,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: numofpage,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  if ((curpage - 1) == index) {
                    color = Colors.red;
                  } else {
                    color = Colors.black;
                  }
                  return TextButton(
                      onPressed: () {
                        curpage = index + 1;
                        loadNewsData();
                      },
                      child: Text(
                        (index + 1).toString(),
                        style: TextStyle(color: color, fontSize: 18),
                      ));
                },
              ),
            ),
          ],
        ),
        drawer: const MyDrawer(),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
                context, MaterialPageRoute(builder: (content) => const NewNewsScreen()));
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
    // Add search and filter parameters to the request URL
    String searchQuery = searchController.text.isNotEmpty
        ? "&search=${searchController.text}"
        : "";
    String filterQuery = selectedFilter != "All" ? "&filter=$selectedFilter" : "";

    http
        .get(Uri.parse(
            "${MyConfig.servername}/MyMemberLink/load_news.php?pageno=$curpage$searchQuery$filterQuery"))
        .then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          var result = data['data']['news'];
          newsList.clear();
          for (var item in result) {
            News news = News.fromJson(item);
            newsList.add(news);
          }
          numofpage = int.parse(data['numofpage'].toString());
          numofresult = int.parse(data['numberofresult'].toString());
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
                onPressed: () async {
                  Navigator.pop(context);
                  News news = newsList[index];

                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (content) => EditNewsScreen(news: news)));
                  loadNewsData();
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
        Uri.parse("${MyConfig.servername}/MyMemberLink/delete_news.php"),
        body: {"newsid": newsList[index].newsId.toString()}).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        log(data.toString());
        if (data['status'] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Success"),
            backgroundColor: Colors.green,
          ));
          loadNewsData();
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


