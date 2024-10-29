import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SongsScreen extends StatefulWidget {
  final List<Object> setList;
  const SongsScreen({required this.setList, super.key});

  @override
  State<StatefulWidget> createState() => _SongsScreenState();

}

class _SongsScreenState extends State<SongsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text('songs'));
  }

}