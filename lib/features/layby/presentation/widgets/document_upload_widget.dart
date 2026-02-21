import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/domain/entities/layby_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/presentation/providers/layby_provider.dart';

/// Document upload widget with file picker and chunked upload progress
class DocumentUploadWidget extends ConsumerStatefulWidget {
  final List<LaybyDocument> existingDocuments;
  final ValueChanged<LaybyAttachment?> onAttachmentReady;
  final ValueChanged<LaybyDocument?> onExistingDocumentSelected;

  const DocumentUploadWidget({
    super.key,
    this.existingDocuments = const [],
    required this.onAttachmentReady,
    required this.onExistingDocumentSelected,
  });

  @override
  ConsumerState<DocumentUploadWidget> createState() =>
      _DocumentUploadWidgetState();
}

class _DocumentUploadWidgetState extends ConsumerState<DocumentUploadWidget> {
  String? _selectedFileName;
  bool _useExisting = false;
  int? _selectedExistingDocId;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final laybyState = ref.watch(laybyNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ID Document',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 8),

        // Option: use existing document
        if (widget.existingDocuments.isNotEmpty) ...[
          InkWell(
            onTap: () {
              setState(() {
                _useExisting = true;
                _selectedFileName = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    _useExisting
                        ? colors.primary.withOpacity(0.1)
                        : colors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _useExisting ? colors.primary : colors.outlineVariant,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _useExisting
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: _useExisting ? colors.primary : colors.outline,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Use previously uploaded document',
                    style: TextStyle(fontSize: 14, color: colors.onSurface),
                  ),
                ],
              ),
            ),
          ),
          if (_useExisting) ...[
            const SizedBox(height: 8),
            ...widget.existingDocuments.map(
              (doc) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedExistingDocId = doc.id;
                    });
                    widget.onExistingDocumentSelected(doc);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          _selectedExistingDocId == doc.id
                              ? colors.primary.withOpacity(0.08)
                              : colors.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color:
                            _selectedExistingDocId == doc.id
                                ? colors.primary
                                : colors.outlineVariant.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 18,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${doc.type} - ${doc.number}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: colors.onSurface,
                                ),
                              ),
                              Text(
                                'Uploaded ${doc.uploadedAt}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colors.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_selectedExistingDocId == doc.id)
                          Icon(
                            Icons.check_circle,
                            color: colors.primary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],

        // Option: Upload new document
        InkWell(
          onTap: () {
            setState(() {
              _useExisting = false;
              _selectedExistingDocId = null;
            });
            widget.onExistingDocumentSelected(null);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  !_useExisting
                      ? colors.primary.withOpacity(0.1)
                      : colors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: !_useExisting ? colors.primary : colors.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  !_useExisting
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: !_useExisting ? colors.primary : colors.outline,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Upload new document',
                  style: TextStyle(fontSize: 14, color: colors.onSurface),
                ),
              ],
            ),
          ),
        ),

        if (!_useExisting) ...[
          const SizedBox(height: 12),

          // File picker / camera buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      laybyState.isLoading ? null : () => _pickAndUploadFile(),
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: Text(
                    _selectedFileName ?? 'Choose File',
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed:
                    laybyState.isLoading ? null : () => _captureWithCamera(),
                icon: const Icon(Icons.camera_alt, size: 18),
                label: const Text('Camera'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          // Upload progress
          if (laybyState.isLoading && laybyState.uploadProgress > 0) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: laybyState.uploadProgress,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(laybyState.uploadProgress * 100).toStringAsFixed(0)}% uploaded',
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurface.withOpacity(0.6),
              ),
            ),
          ],

          if (laybyState.error != null) ...[
            const SizedBox(height: 8),
            Text(
              laybyState.error!,
              style: TextStyle(fontSize: 12, color: colors.error),
            ),
          ],
        ],
      ],
    );
  }

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes ?? await File(file.path!).readAsBytes();

    setState(() {
      _selectedFileName = file.name;
    });

    final attachment = await ref
        .read(laybyNotifierProvider.notifier)
        .uploadDocument(fileBytes: bytes, fileName: file.name);

    widget.onAttachmentReady(attachment);
  }

  Future<void> _captureWithCamera() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo == null) return;

    final bytes = await File(photo.path).readAsBytes();
    final fileName = photo.name;

    setState(() {
      _selectedFileName = fileName;
    });

    final attachment = await ref
        .read(laybyNotifierProvider.notifier)
        .uploadDocument(fileBytes: bytes, fileName: fileName);

    widget.onAttachmentReady(attachment);
  }
}
