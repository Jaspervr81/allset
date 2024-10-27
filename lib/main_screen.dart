
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen ({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>{
  double fontSize = 30;
  bool darkMode = false;
  @override
  Widget build(BuildContext context) {
    Color fontcolor = darkMode ? Colors.black : Colors.white;
    return Scaffold(
        body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: (){

                  }
                  , icon: const Icon(Icons.menu)),
                  Text('Name of the Song'),
                  IconButton(onPressed: (){

                  }
                      , icon: const Icon(Icons.add)),
                ]
              )
            ),
            Expanded(
                child: ReorderableListView(
                    children: [
                      ListTile(
                        key:ValueKey(1),
                        title:Text('title')
                      ),
                      ListTile(
                          key:ValueKey(2),
                          title:Text('next title', style: TextStyle(fontSize: fontSize),)
                      )
                    ],
                    onReorder: (x,y){})),
            Container(
                height: 50,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(onPressed: (){

                      }
                          , icon: const Icon(Icons.exit_to_app)),
                      IconButton(onPressed: (){

                      }
                          , icon: const Icon(Icons.brightness_5)),
                      IconButton(onPressed: (){

                      }
                          , icon: const Icon(Icons.remove_red_eye_rounded)),
                      Slider(min:20, max:40, value: fontSize,  onChanged: (value){
                        setState(() {
                          fontSize = value;
                        });
                      }),
                      ElevatedButton(onPressed: (){}, child: Text('edit')),
                      ElevatedButton(onPressed: (){}, child: Text('Go')),
                    ]
                )
            ),
          ]
        )
        )
    );
  }
}