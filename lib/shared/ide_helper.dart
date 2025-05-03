import 'package:flutter/material.dart';
import 'jdoodle_ide_widget.dart'; // Use relative import instead of absolute path

class IdeHelper {
  static void showJDoodleIDE(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('COMPILER'),
        content: Container(
          width: double.maxFinite,
          height: 500,
          child: JDoodleIdeWidget(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
