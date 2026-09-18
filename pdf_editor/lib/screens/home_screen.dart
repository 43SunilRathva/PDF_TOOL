import 'dart:io';

import 'package:flutter/material.dart';

import '../services/file_service.dart';
import '../services/pdf_service.dart';
import '../widgets/pdf_preview.dart';
import '../widgets/toolbar.dart';
import 'viewer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FileService _fileService = FileService();
  final PdfService _pdfService = PdfService();

  PdfFileInfo? _selectedFile;
  bool _isBusy = false;
  String _status = 'Ready';

  Future<void> _openPdf() async {
    setState(() => _isBusy = true);

    try {
      final file = await _fileService.pickPdfFile();
      if (!mounted) return;
      if (file == null) {
        setState(() {
          _status = 'No PDF selected';
          _isBusy = false;
        });
        return;
      }

      setState(() {
        _selectedFile = file;
        _status = 'Loaded ${file.name}';
        _isBusy = false;
      });

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ViewerScreen(
            filePath: file.path,
            title: file.name,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _status = 'Unable to load PDF: $error';
        _isBusy = false;
      });
    }
  }

  Future<void> _createSamplePdf() async {
    setState(() => _isBusy = true);

    try {
      final bytes = await _pdfService.generateSampleDocument();
      final exportDir = await _fileService.createExportDirectory();
      final file = File('$exportDir/sample_document.pdf');
      await file.writeAsBytes(bytes);

      if (!mounted) return;
      setState(() {
        _selectedFile = PdfFileInfo(
          name: 'sample_document.pdf',
          path: file.path,
          sizeLabel: _pdfService.labelForBytes(bytes.length),
        );
        _status = 'Sample PDF created';
        _isBusy = false;
      });

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ViewerScreen(
            filePath: file.path,
            title: 'Sample document',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _status = 'Could not create sample PDF: $error';
        _isBusy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Tool'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _isBusy ? null : _openPdf,
            tooltip: 'Open PDF',
            icon: const Icon(Icons.upload_file),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create and review PDFs',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Open a PDF, create a sample document or review the active file.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 22),
              PdfToolBar(
                children: [
                  ToolActionButton(
                    label: 'Open PDF',
                    icon: Icons.folder_open,
                    onPressed: _isBusy ? () {} : _openPdf,
                  ),
                  ToolActionButton(
                    label: 'Create sample',
                    icon: Icons.add_circle,
                    onPressed: _isBusy ? () {} : _createSamplePdf,
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Icon(Icons.info_outline, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _status,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_selectedFile != null)
                PdfPreviewCard(
                  fileName: _selectedFile!.name,
                  fileSize: _selectedFile!.sizeLabel,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ViewerScreen(
                          filePath: _selectedFile!.path,
                          title: _selectedFile!.name,
                        ),
                      ),
                    );
                  },
                )
              else
                Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.picture_as_pdf_outlined,
                            size: 56,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No active PDF',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Select a document to preview it here.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
