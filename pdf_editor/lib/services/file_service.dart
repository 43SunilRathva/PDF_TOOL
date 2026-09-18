import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class PdfFileInfo {
  const PdfFileInfo(
      {required this.name, required this.path, required this.sizeLabel});

  final String name;
  final String path;
  final String sizeLabel;
}

class FileService {
  Future<PlatformFile?> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    return result.files.first;
  }

  Future<PdfFileInfo?> pickPdfFile() async {
    final file = await pickPdf();
    if (file == null || file.path == null) {
      return null;
    }

    final filePath = file.path!;
    final pdfFile = File(filePath);
    final sizeInBytes = await pdfFile.length();

    return PdfFileInfo(
      name: file.name,
      path: filePath,
      sizeLabel: _formatSize(sizeInBytes),
    );
  }

  Future<String> createExportDirectory() async {
    final directory = Platform.isAndroid || Platform.isIOS
        ? await getTemporaryDirectory()
        : await getApplicationDocumentsDirectory();

    final exportDir = Directory('${directory.path}/pdf_tool_exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir.path;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
