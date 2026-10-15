import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class FirestoreTestScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final FirestoreService? firestoreService;

  const FirestoreTestScreen({super.key, this.onBack, this.firestoreService});

  @override
  State<FirestoreTestScreen> createState() => _FirestoreTestScreenState();
}

class _FirestoreTestScreenState extends State<FirestoreTestScreen> {
  late final FirestoreService _firestoreService;

  @override
  void initState() {
    super.initState();
    _firestoreService = widget.firestoreService ?? FirestoreService();
  }

  // Test Run State
  bool _isTesting = false;
  Map<String, dynamic>? _lastTestResult;
  String? _testErrorMessage;

  // Custom Record Form State
  final _collectionController =
      TextEditingController(text: 'test_records');
  final _titleController =
      TextEditingController(text: 'Campus ERP Telemetry Check');
  final _contentController = TextEditingController(
      text: 'Faculty biometric terminal connection established.');
  bool _isWriting = false;

  // Read By ID State
  final _readDocIdController = TextEditingController();
  bool _isReading = false;
  Map<String, dynamic>? _fetchedDocument;
  String? _readErrorMessage;

  @override
  void dispose() {
    _collectionController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _readDocIdController.dispose();
    super.dispose();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isTesting = true;
      _testErrorMessage = null;
      _lastTestResult = null;
    });

    try {
      final result = await _firestoreService.testReadWriteCycle(
        collection: 'test_records',
      );
      if (mounted) {
        setState(() {
          _lastTestResult = result;
          _isTesting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Firestore Read/Write diagnostic passed successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _testErrorMessage = e.toString();
          _isTesting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Diagnostic error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _writeCustomRecord() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a record title')),
      );
      return;
    }

    setState(() {
      _isWriting = true;
    });

    try {
      final docId = await _firestoreService.addRecord(
        collectionPath: _collectionController.text.trim(),
        data: {
          'title': _titleController.text.trim(),
          'content': _contentController.text.trim(),
          'clientTimestamp': DateTime.now().toIso8601String(),
          'source': 'FirestoreTestScreen',
        },
      );

      if (mounted) {
        _readDocIdController.text = docId;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Record added with ID: $docId'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Write failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isWriting = false;
        });
      }
    }
  }

  Future<void> _fetchDocumentById() async {
    final docId = _readDocIdController.text.trim();
    if (docId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Document ID')),
      );
      return;
    }

    setState(() {
      _isReading = true;
      _fetchedDocument = null;
      _readErrorMessage = null;
    });

    try {
      final doc = await _firestoreService.getRecord(
        collectionPath: _collectionController.text.trim(),
        documentId: docId,
      );

      if (mounted) {
        setState(() {
          _fetchedDocument = doc;
          if (doc == null) {
            _readErrorMessage = 'No document found with ID "$docId"';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _readErrorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isReading = false;
        });
      }
    }
  }

  Future<void> _deleteRecord(String docId) async {
    try {
      await _firestoreService.deleteRecord(
        collectionPath: _collectionController.text.trim(),
        documentId: docId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted document $docId'),
            backgroundColor: AppColors.onSurfaceVariant,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                onPressed: widget.onBack,
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Firestore Service & Database Test',
              style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'Project: college-5efe7',
              style: AppTypography.labelSm.copyWith(color: AppColors.success),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_done, color: AppColors.success, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Connected',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Diagnostic Test Card
            _buildDiagnosticsCard(),
            const SizedBox(height: 16),

            // Write Record Section
            _buildWriteSection(),
            const SizedBox(height: 16),

            // Read Record Section
            _buildReadSection(),
            const SizedBox(height: 16),

            // Live Stream Section
            _buildStreamSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticsCard() {
    return Card(
      elevation: 0,
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.speed_outlined,
                    color: AppColors.primaryContainer,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'End-to-End Diagnostic Test',
                        style: AppTypography.headlineSm
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Tests automated Write -> Read -> Update cycle with latency metrics',
                        style: AppTypography.bodySm
                            .copyWith(color: AppColors.secondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: _isTesting ? null : _runDiagnostics,
                icon: _isTesting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.play_arrow_rounded),
                label: Text(
                  _isTesting
                      ? 'Executing Diagnostic Cycle...'
                      : 'Run Read & Write Diagnostic Test',
                  style: AppTypography.labelMd
                      .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            if (_testErrorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _testErrorMessage!,
                        style: AppTypography.bodySm
                            .copyWith(color: AppColors.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_lastTestResult != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: AppColors.success, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Test Passed (${_lastTestResult!['totalDurationMs']} ms total)',
                          style: AppTypography.labelMd.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _metricTile(
                          'Write',
                          '${_lastTestResult!['writeLatencyMs']} ms',
                          Icons.arrow_upward,
                        ),
                        _metricTile(
                          'Read',
                          '${_lastTestResult!['readLatencyMs']} ms',
                          Icons.arrow_downward,
                        ),
                        _metricTile(
                          'Update',
                          '${_lastTestResult!['updateLatencyMs']} ms',
                          Icons.sync,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Target Document: ${_lastTestResult!['testId']}',
                      style: AppTypography.codeSm
                          .copyWith(color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _metricTile(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.secondary),
            const SizedBox(width: 4),
            Text(label, style: AppTypography.labelSm),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildWriteSection() {
    return Card(
      elevation: 0,
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.edit_note, color: AppColors.primaryContainer),
                const SizedBox(width: 8),
                Text(
                  'Write Record to Firestore',
                  style: AppTypography.headlineSm
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _collectionController,
              decoration: const InputDecoration(
                labelText: 'Collection Name',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Record Title / Label',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Record Content / Payload',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isWriting ? null : _writeCustomRecord,
                icon: _isWriting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload_outlined),
                label: Text(_isWriting ? 'Saving...' : 'Add Record to Collection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadSection() {
    return Card(
      elevation: 0,
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.search, color: AppColors.primaryContainer),
                const SizedBox(width: 8),
                Text(
                  'Read Single Record by ID',
                  style: AppTypography.headlineSm
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _readDocIdController,
                    decoration: const InputDecoration(
                      labelText: 'Document ID',
                      hintText: 'Paste or enter Document ID',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isReading ? null : _fetchDocumentById,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerHigh,
                    foregroundColor: AppColors.onSurface,
                  ),
                  child: _isReading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Fetch'),
                ),
              ],
            ),
            if (_readErrorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _readErrorMessage!,
                style:
                    AppTypography.bodySm.copyWith(color: AppColors.error),
              ),
            ],
            if (_fetchedDocument != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  const JsonEncoder.withIndent('  ').convert(_fetchedDocument),
                  style: AppTypography.codeSm,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStreamSection() {
    return Card(
      elevation: 0,
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.stream, color: AppColors.primaryContainer),
                    const SizedBox(width: 8),
                    Text(
                      'Live Collection Stream',
                      style: AppTypography.headlineSm
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  _collectionController.text,
                  style: AppTypography.labelSm
                      .copyWith(color: AppColors.secondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestoreService.streamCollection(
                collectionPath: _collectionController.text.trim(),
                limit: 10,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Stream Error: ${snapshot.error}',
                      style: AppTypography.bodySm
                          .copyWith(color: AppColors.onErrorContainer),
                    ),
                  );
                }

                final docs = snapshot.data ?? [];
                if (docs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    child: Text(
                      'No records found in this collection yet.\nUse "Write Record" or "Run Diagnostic Test" above to insert data.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySm
                          .copyWith(color: AppColors.secondary),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = docs[index];
                    final docId = item['id'] as String? ?? 'unknown';
                    final title = item['title'] ?? item['testId'] ?? 'Record';
                    final subtitle = item['content'] ??
                        item['status'] ??
                        item['purpose'] ??
                        '';

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        child: Text(
                          '${index + 1}',
                          style: AppTypography.labelSm
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        title.toString(),
                        style: AppTypography.labelMd
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (subtitle.toString().isNotEmpty)
                            Text(
                              subtitle.toString(),
                              style: AppTypography.bodySm,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          Text(
                            'ID: $docId',
                            style: AppTypography.codeSm
                                .copyWith(color: AppColors.secondary),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            size: 20, color: AppColors.error),
                        tooltip: 'Delete document',
                        onPressed: () => _deleteRecord(docId),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
