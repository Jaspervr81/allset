import 'package:allset/performance_screen.dart';
import 'package:allset/settings.dart';
import 'package:allset/songs_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  double fontSize = 30;
  bool darkMode = false;
  bool showEditBar = false;
  bool showTileParameters = false;
  Settings settings = Settings();
  List<ListTile> tiles = [];

  @override
  Widget build(BuildContext context) {
    Color fontColor = darkMode ? Colors.white : Colors.black;
    return Scaffold(
        body: Container(
      color: darkMode ? Colors.black : Colors.white,
      child: SafeArea(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            Container(
                height: 50,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.menu)),
                      Text(
                        'Name of the Song',
                        style: TextStyle(fontSize: 20, color: fontColor),
                      ),
                      IconButton(
                          onPressed: () {
                            goToSongLibrary();
                          },
                          icon: const Icon(Icons.add)),
                    ])),
            Expanded(
              child: Stack(
                children: [
                  ReorderableListView(
                    onReorder: (int oldIndex, int newIndex) {},
                    children: [
                      ListTile(
                          key: ValueKey(1),
                          title: Text(
                            'next title',
                            style: TextStyle(
                                fontSize: fontSize,
                                color: fontColor,
                                fontWeight: FontWeight.bold),
                          ),
                          trailing: Text(
                            'G#',
                            style: TextStyle(
                                fontSize: fontSize,
                                color: fontColor,
                                fontWeight: FontWeight.bold),
                          )),
                    ],
                  ),
                  if (showTileParameters == true)
                    Positioned(
                    bottom: 0,
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        color: Colors.grey,
                        child: Row(
                          children: [
                            TextButton(onPressed: () {}, child: Text('ARTIST')),
                            TextButton(onPressed: () {}, child: Text('KEY')),
                            TextButton(onPressed: () {}, child: Text('TEMPO')),
                            TextButton(onPressed: () {}, child: Text('NOTES')),
                            TextButton(onPressed: () {}, child: Text('LENGTH')),
                          ],
                        )),
                  ),
                  if (showEditBar == true)
                    Positioned(
                      bottom: 0,
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          color: Colors.grey,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.teal,
                                  ),
                                  child: ElevatedButton(onPressed: (){}, child: null, style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent)),
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.teal,
                                ),
                                child: ElevatedButton(onPressed: (){}, child: null, style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent)),
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.teal,
                                ),
                                child: ElevatedButton(onPressed: (){}, child: null, style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent)),
                              ),
                              TextButton(onPressed: () {}, child: Text('BREAK')),
                              SizedBox(
                                width: 40,
                                child: IconButton(
                                    onPressed: () {
                                      shareSetList();
                                    },
                                    icon: const Icon(Icons.undo)),
                              ),
                              SizedBox(
                                width: 40,
                                child: IconButton(
                                    onPressed: () {
                                      shareSetList();
                                    },
                                    icon: const Icon(Icons.redo)),
                              ),
                              SizedBox(
                                width: 40,
                                child: IconButton(
                                    onPressed: () {
                                      shareSetList();
                                    },
                                    icon: const Icon(Icons.delete)),
                              ),
                            ],
                          )),
                    )
                ],
              ),
            ),
            Container(
                height: 50,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 40,
                        child: IconButton(
                            onPressed: () {
                              shareSetList();
                            },
                            icon: const Icon(Icons.exit_to_app)),
                      ),
                      SizedBox(
                        width: 40,
                        child: IconButton(
                            onPressed: () {
                              setDarkMode();
                            },
                            icon: const Icon(Icons.brightness_5)),
                      ),
                      SizedBox(
                        width: 40,
                        child: IconButton(
                            onPressed: () {
                              showSongDetailsBar();
                            },
                            icon: const Icon(Icons.remove_red_eye_rounded)),
                      ),
                      SizedBox(
                        width: 150,
                        child: Slider(
                            min: 20,
                            max: 40,
                            value: fontSize,
                            onChanged: (value) {
                              setState(() {
                                fontSize = value;
                              });
                            }),
                      ),
                      SizedBox(
                          width: 60,
                          child: TextButton(
                              onPressed: () {
                                showEditListBar();
                              },
                              child: Text('Edit'))),
                      Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.teal,
                          ),
                          child: TextButton(
                              onPressed: () {
                                goToPerformanceMode();
                              },
                              child: Text('Go',
                                  style: TextStyle(
                                      color: fontColor, fontSize: 11)))),
                    ])),
          ])),
    ));
  }

  Future<void> setDarkMode() async {
    final flippedDarkMode = await settings.setNightMode(darkMode);
    setState(() {
      darkMode = flippedDarkMode;
    });
  }

  void shareSetList() {}

  void goToSongLibrary() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const PerformanceScreen()));
  }

  void showEditListBar() {
    setState(() {
      showTileParameters = false;
      showEditBar = !showEditBar;
    });
  }

  void showSongDetailsBar() {
    setState(() {
      showEditBar = false;
      showTileParameters = !showTileParameters;
    });
  }

  void goToPerformanceMode() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const SongsScreen(
                  setList: [],
                )));
  }
}
