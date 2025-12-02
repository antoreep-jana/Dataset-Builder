import 'package:flutter/material.dart';

@immutable
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({super.key, this.initialOpen, required this.distance, required this.children});

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab> {

  bool _open = false;

  @override
  void initState(){
  super.initState();
  _open = widget.initialOpen ?? false;
  }

  void _toggle(){
    setState(() {
      _open = !_open;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}
