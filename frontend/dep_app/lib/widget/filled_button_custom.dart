import 'package:flutter/material.dart';

class FilledButtonCustom extends StatelessWidget {
  final void Function()? onPressed;
  final String label;
  final Icon icon;
  const FilledButtonCustom(
      {super.key, this.onPressed, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
        icon: icon, onPressed: onPressed, label: Text(label));
  }
}
