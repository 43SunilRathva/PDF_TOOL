import 'dart:io';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class ViewerScreen extends StatelessWidget {
  const ViewerScreen({
    super.key,
    required this.filePath,
    required this.title,
  });

  final String filePath;
  final String title;

  @override
  Widget build(BuildContext context) {
    final file = File(filePath);
    final exists = file.existsSync();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: exists
          ? PdfPreview(
              build: (format) async => file.readAsBytes(),
              allowPrinting: true,
              allowSharing: true,
              canChangePageFormat: true,
              canChangeOrientation: true,
              loadingWidget: const Center(child: CircularProgressIndicator()),
            )
          : const Center(
              child: Text('Selected PDF could not be opened.'),
            ),
    );
  }
}
