import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:sanovault/session/session_scope.dart';
import 'package:sanovault/theme/sv_colors.dart';

class DocumentViewPage extends StatefulWidget {
  const DocumentViewPage({
    super.key,
    required this.documentId,
    required this.title,
    this.embedded = false,
  });
  final String documentId;
  final String title;
  final bool embedded;

  @override
  State<DocumentViewPage> createState() => _DocumentViewPageState();
}

class _DocumentViewPageState extends State<DocumentViewPage> {
  Uint8List? _imageBytes;
  Uint8List? _pdfBytes;
  String? _networkUrl;
  String? _fileName;
  String? _error;
  bool _pinned = false;
  bool _hasBytes = false;
  int _pageNumber = 1;
  int _pageCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final api = SessionScope.of(context).api;
    final offline = SessionScope.of(context).offline;
    final cachedInfo = await offline.documentInfo(widget.documentId);
    final cachedBytes = await offline.readDocument(widget.documentId);
    if (cachedBytes != null && mounted) {
      setState(() {
        _pinned = cachedInfo?['pinned'] == true;
        _hasBytes = true;
        if (cachedInfo?['isPdf'] == true) {
          _pdfBytes = Uint8List.fromList(cachedBytes);
          _fileName = cachedInfo?['fileName'] as String?;
        } else {
          _imageBytes = Uint8List.fromList(cachedBytes);
          _fileName = cachedInfo?['fileName'] as String?;
        }
      });
    }
    try {
      final view = await api.documentView(widget.documentId);
      final type = (view.fileType ?? '').toLowerCase();
      final name = (view.fileName ?? '').toLowerCase();
      final isImage =
          type.contains('jpeg') ||
          type.contains('jpg') ||
          type.contains('png') ||
          type.contains('webp') ||
          type.contains('gif') ||
          type.contains('bmp');
      final isPdf = type.contains('pdf') || name.endsWith('.pdf');

      if (!isPdf && view.url.startsWith('/api/')) {
        final bytes = await api.documentPreview(widget.documentId);
        if (!mounted) return;
        setState(() {
          _imageBytes = Uint8List.fromList(bytes);
          _pdfBytes = null;
          _networkUrl = null;
          _fileName = view.fileName;
          _hasBytes = true;
        });
        await offline.writeDocument(
          widget.documentId,
          bytes,
          fileName: view.fileName,
          isPdf: false,
        );
        return;
      }

      if (isImage) {
        if (!mounted) return;
        setState(() {
          _networkUrl = view.url;
          _imageBytes = null;
          _pdfBytes = null;
          _fileName = view.fileName;
        });
        return;
      }

      if (isPdf) {
        final bytes = await api.documentFile(widget.documentId);
        if (!mounted) return;
        setState(() {
          _pdfBytes = Uint8List.fromList(bytes);
          _imageBytes = null;
          _networkUrl = null;
          _fileName = view.fileName;
          _hasBytes = true;
        });
        await offline.writeDocument(
          widget.documentId,
          bytes,
          fileName: view.fileName,
          isPdf: true,
        );
        return;
      }

      // Unknown type: still try authenticated file bytes as PDF when possible.
      final bytes = await api.documentFile(widget.documentId);
      if (!mounted) return;
      if (bytes.length >= 5 && String.fromCharCodes(bytes.take(5)) == '%PDF-') {
        setState(() {
          _pdfBytes = Uint8List.fromList(bytes);
          _imageBytes = null;
          _networkUrl = null;
          _fileName = view.fileName;
          _hasBytes = true;
        });
        await offline.writeDocument(
          widget.documentId,
          bytes,
          fileName: view.fileName,
          isPdf: true,
        );
        return;
      }
      setState(
        () => _error = 'This file type cannot be previewed in the app yet.',
      );
    } catch (caught) {
      if (!mounted) return;
      setState(() => _error = caught.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_error != null &&
        _pdfBytes == null &&
        _imageBytes == null &&
        _networkUrl == null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: SvColors.danger),
          ),
        ),
      );
    } else if (_pdfBytes != null) {
      body = Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              _pageCount == 0
                  ? 'Loading pages…'
                  : 'Page $_pageNumber of $_pageCount · Scroll to view all pages',
            ),
          ),
          Expanded(
            child: PdfViewer.data(
              _pdfBytes!,
              sourceName: _fileName ?? widget.documentId,
              params: PdfViewerParams(
                onViewerReady: (document, controller) {
                  if (mounted) {
                    setState(() => _pageCount = document.pages.length);
                  }
                },
                onPageChanged: (page) {
                  if (mounted) setState(() => _pageNumber = page ?? 1);
                },
              ),
            ),
          ),
        ],
      );
    } else if (_imageBytes != null) {
      body = InteractiveViewer(child: Image.memory(_imageBytes!));
    } else if (_networkUrl != null) {
      body = InteractiveViewer(child: Image.network(_networkUrl!));
    } else {
      body = const Center(child: CupertinoActivityIndicator());
    }
    if (widget.embedded) return body;
    return CupertinoPageScaffold(
      backgroundColor: SvColors.groupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: !_hasBytes
              ? null
              : () async {
                  final next = !_pinned;
                  await SessionScope.of(context).offline
                      .setDocumentPinned(widget.documentId, next);
                  if (mounted) setState(() => _pinned = next);
                },
          child: Text(_pinned ? 'Pinned' : 'Keep offline'),
        ),
      ),
      child: SafeArea(child: body),
    );
  }
}
