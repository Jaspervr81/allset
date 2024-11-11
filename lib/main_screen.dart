import 'package:allset/models/song_model.dart';
import 'package:allset/performance_screen.dart';
import 'package:allset/settings.dart';
import 'package:allset/songs_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Realm realm;
  double fontSize = 30;
  bool darkMode = false;
  bool showEditBar = false;
  bool showTileParameters = false;
  Settings settings = Settings();
  List<ListTile> tiles = [];
  List<SongModel> songs = [];
  late PlaylistModel playlist;
  bool showArtist = true;
  bool showKey = true;
  bool showBpm = true;
  bool showNotes = true;
  bool showLength = true;

  bool isPurpleSelected = false;
  bool isRedSelected = false;
  bool isOrangeSelected = false;
  String selectedColor = '';

  @override
  void initState() {
    realm = Realm(Configuration.local([SongModel.schema, PlaylistModel.schema]));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var songs = realm.all<SongModel>();
    setBackground();
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
                        'Setlist',
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
                    onReorder: (int oldIndex, int newIndex) {
                      if (newIndex > oldIndex) newIndex -= 1;
                      // final SongModel s = songs.removeAt(oldIndex);
                      // tiles.insert(newIndex, item);
                    },

                    children: [
                      for (var song in songs)
                        ListTile(
                          onTap: (){
                            setState(() {
                              song.textColor = selectedColor;
                            });
                          },
                          key: ValueKey(song.id),
                          title: Text(
                            song.title,
                            style: TextStyle(
                                fontSize: fontSize,
                                color: returnTextColor(color: song.textColor),
                                fontWeight: FontWeight.bold),
                          ),
                          trailing: Text(
                            song.key ?? '',
                            style: TextStyle(
                                fontSize: fontSize,
                                color: returnTextColor(color: song.textColor),
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Row(
                            children: [
                              if (song.artist != null)
                                Text(
                                  song.artist ?? '',
                                  style: TextStyle(
                                      fontSize: fontSize,
                                      color: returnTextColor(
                                          color: song.textColor),
                                      fontWeight: FontWeight.w100),
                                ),
                              const SizedBox(width: 20),
                              if (song.bpm != null)
                                Text(
                                  '${song.bpm}' ?? '',
                                  style: TextStyle(
                                      fontSize: fontSize,
                                      color: returnTextColor(
                                          color: song.textColor),
                                      fontWeight: FontWeight.w100),
                                ),
                            ],
                          ),
                        ),
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
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      showArtist = !showArtist;
                                    });
                                  },
                                  child: Text('ARTIST')),
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      showKey = !showKey;
                                    });
                                  },
                                  child: Text('KEY')),
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      showBpm = !showBpm;
                                    });
                                  },
                                  child: Text('TEMPO')),
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      showNotes = !showNotes;
                                    });
                                  },
                                  child: Text('NOTES')),
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      showLength = !showLength;
                                    });
                                  },
                                  child: Text('LENGTH')),
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
                                ),
                                child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        isPurpleSelected = !isPurpleSelected;
                                        isRedSelected = isOrangeSelected = false;
                                        if (isPurpleSelected = true)  {selectedColor = 'purple';}
                                      });
                                    },
                                    child: null,
                                    style: OutlinedButton.styleFrom(
                                        backgroundColor: isPurpleSelected ? Colors.deepPurple[200] : Colors.deepPurpleAccent,
                                      side: const BorderSide(
                                        color: Colors.deepPurpleAccent,
                                        width: 4,
                                      ),)
                                ),
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        isRedSelected = !isRedSelected;
                                        isOrangeSelected = isPurpleSelected = false;
                                        if (isRedSelected = true)  {selectedColor = 'red';}
                                      });
                                    },
                                    child: null,
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: isRedSelected ? Colors.red[200] : Colors.redAccent,
                                      side: const BorderSide(
                                        color: Colors.redAccent,
                                        width: 4,
                                      ),)
                                ),
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        isOrangeSelected = !isOrangeSelected;
                                        isRedSelected = isPurpleSelected = false;
                                        if (isOrangeSelected = true)  {selectedColor = 'orange';}
                                      });
                                    },
                                    child: null,
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: isOrangeSelected ? Colors.deepOrange[200] : Colors.deepOrangeAccent,
                                      side: const BorderSide(
                                        color: Colors.deepOrangeAccent,
                                        width: 4,
                                      ),)
                                ),
                              ),
                              TextButton(
                                  onPressed: () {}, child: Text('BREAK'), style: TextButton.styleFrom(
                                backgroundColor: Colors.grey
                              ),),
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

  void setBackground() async {
    darkMode = await settings.checkNightMode();
  }
  void shareSetList() {}

  void goToSongLibrary() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const SongsScreen(
                  setList: [],
                )));
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
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const PerformanceScreen()));
  }

  List<SongModel> setModels({required RealmResults<SongModel> songs}){
    List<SongModel> rr = [];
    for (var song in songs){
      rr.add(song);
    }
    return rr;
  }

  List<ListTile> setSongs({required RealmResults<SongModel> songs}) {
    List<ListTile> localSongs = [];
    for (var item in songs) {
      print(songs[0].id);
      print('THIS SONG == ${item.artist}');
      localSongs.add(ListTile(
        key: ValueKey(item.id),
        title: Text(
          item.title,
          style: TextStyle(
              fontSize: fontSize,
              color: returnTextColor(color: item.textColor),
              fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          item.key ?? '',
          style: TextStyle(
              fontSize: fontSize,
              color: returnTextColor(color: item.textColor),
              fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            if (item.artist != null)
              Text(
                item.artist ?? '',
                style: TextStyle(
                    fontSize: fontSize,
                    color: returnTextColor(color: item.textColor),
                    fontWeight: FontWeight.w100),
              ),
            const SizedBox(width: 20),
            if (item.bpm != null)
              Text(
                '${item.bpm}' ?? '',
                style: TextStyle(
                    fontSize: fontSize,
                    color: returnTextColor(color: item.textColor),
                    fontWeight: FontWeight.w100),
              ),
          ],
        ),
      ));
    }
    return localSongs;
  }

  Color returnTextColor({required String? color}) {
    switch (color) {
      case 'orange':
        return Colors.orangeAccent;
      case 'red':
        return Colors.redAccent;
      case 'purple':
        return Colors.purpleAccent;
      case '':
        return darkMode ? Colors.white : Colors.black;
    }
    return darkMode ? Colors.white : Colors.black;
  }
}
