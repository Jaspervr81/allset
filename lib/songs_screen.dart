import 'package:allset/models/song_model.dart';
import 'package:allset/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

class SongsScreen extends StatefulWidget {
  final List<Object> setList;

  const SongsScreen({required this.setList, super.key});

  @override
  State<StatefulWidget> createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  late Realm realm;
  double fontSize = 20;
  bool darkMode = false;
  bool showEditBar = false;
  bool showTileParameters = false;
  Settings settings = Settings();
  Color fontColor = Colors.black;
  List<ListTile> tiles = [];
  int? _bpm;
  int? _length;
  late SongModel currentSong;
  List<SongModel> allSongs = [];

  final TextEditingController songController = TextEditingController();
  final TextEditingController keyController = TextEditingController();
  final TextEditingController artistController = TextEditingController();
  final TextEditingController bpmController = TextEditingController();
  final TextEditingController timeCodeController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  bool showArtist = true;
  bool showKey = true;
  bool showBpm = true;
  bool showNotes = true;
  bool showLength = true;
  Settings setting = Settings();

  @override
  void initState() {
    realm = Realm(Configuration.local([SongModel.schema, PlaylistModel.schema]));
    super.initState();
  }

  @override
  void dispose() {
    songController.dispose();
    keyController.dispose();
    artistController.dispose();
    bpmController.dispose();
    timeCodeController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setBackground();
    var allSongs = realm.all<SongModel>();
    var allPlaylists = realm.all<PlaylistModel>();
    return Scaffold(
        body: Container(
          color: darkMode ? Colors.black : Colors.white,
          child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                              height: 50,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        icon: const Icon(Icons.close)),
                                    Text(
                                      'Song Library',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: returnTextColor(color: ''),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextButton(
                                        onPressed: () {
                                          addToSet();
                                        },
                                        child: const Text('Add to Set')),
                                  ])),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: songController,
                                  decoration: const InputDecoration(
                                    labelText: 'New Song',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Spacing between fields
                              Expanded(
                                child: TextField(
                                  controller: keyController,
                                  decoration: const InputDecoration(
                                    labelText: 'Key',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16), // Spacing between rows
                          // Second Row with three TextFields: Artist, BPM, and Time Code
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: artistController,
                                  decoration: const InputDecoration(
                                    labelText: 'Artist',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: bpmController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'BPM',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: timeCodeController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: '0:00',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16), // Spacing between rows
                          // Second Row with three TextFields: Artist, BPM, and Time Code
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: notesController,
                                  decoration: const InputDecoration(
                                    labelText: 'Notes',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              TextButton(
                                  onPressed: () {}, child: const Text('Add Lyrics')),
                              const SizedBox(width: 16),
                              TextButton(
                                  onPressed: () {
                                    saveSongToSetList();
                                  },
                                  child: const Text('Save'))
                            ],
                          ),
                        ],
                      ),
                      Expanded(
                          child: Stack(children: [
                            ListView(
                                children: [
                                  for (final song in allSongs)
                                    ListTile(
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
                                    )
                                ]),
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
                          ])),
                      Container(
                          height: 50,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
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
                                        //  showSongDetailsBar();
                                      },
                                      icon: const Icon(Icons.remove_red_eye_rounded)),
                                ),
                                SizedBox(
                                    width: 60,
                                    child: TextButton(
                                        onPressed: () {}, child: Text('Edit'))),
                                Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.teal,
                                    ),
                                    child: TextButton(
                                        onPressed: () {},
                                        child: const Text(
                                          'Go',
                                        ))),
                              ])),
                    ]),
              )),
        ));
  }

  void addToSet() {}

  void setBackground() async {
    darkMode = await settings.checkNightMode();
  }

  Future<void> setDarkMode() async {
    final flippedDarkMode = await settings.setNightMode(darkMode);
    setState(() {
      darkMode = flippedDarkMode;
    });
  }

  void saveSongToSetList() {
    if (bpmController.text.isNotEmpty) {
      _bpm = int.parse(bpmController.text);
    }
    if (timeCodeController.text.isNotEmpty) {
      _length = int.parse(timeCodeController.text);
    }

    var realm = Realm(Configuration.local([SongModel.schema]));
    SongModel saveModel = SongModel(Uuid.v4(), songController.text,
        textColor: '',
        key: keyController.text,
        artist: artistController.text,
        bpm: _bpm,
        length: _length,
        notes: notesController.text);
    realm.write(() {
      realm.add(saveModel);
    });
    setState(() {
      allSongs.add(saveModel);
      songController.clear();
      keyController.clear();
      artistController.clear();
      bpmController.clear();
      timeCodeController.clear();
      notesController.clear();
    });
  }

  List<ListTile> setSongs({required RealmResults<SongModel> songs}) {
    List<ListTile> localSongs = [];
    for (var item in songs) {
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
            Text(
              item.artist ?? '',
              style: TextStyle(
                  fontSize: fontSize,
                  color: returnTextColor(color: item.textColor),
                  fontWeight: FontWeight.w100),
            ),
            const SizedBox(width: 20),
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
