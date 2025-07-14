import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class PdfViewScreen extends StatefulWidget {
  final String pdfAssetPath;

  const PdfViewScreen({super.key, required this.pdfAssetPath});

  @override
  State<PdfViewScreen> createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  late PdfControllerPinch pdfController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      pdfController = PdfControllerPinch(
        document: PdfDocument.openAsset(widget.pdfAssetPath),
      );
      setState(() => _isLoading = false);
    } catch (e) {
      print('Error al cargar PDF: $e');
      // Manejar error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial Médico'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        backgroundColor: const Color(0xFF4CAF50),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : PdfViewPinch(
        controller: pdfController,
        scrollDirection: Axis.vertical,
        onPageChanged: (page) {
          print('Página cambiada: $page');
        },
      ),
    );
  }
}