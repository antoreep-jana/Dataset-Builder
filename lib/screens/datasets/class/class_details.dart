import 'package:flutter/material.dart';

class ClassDetails extends StatefulWidget {
  final String className;
  const ClassDetails({super.key, required this.className});

  @override
  State<ClassDetails> createState() => _ClassDetailsState();
}

class _ClassDetailsState extends State<ClassDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.className),),
    );
  }
}
