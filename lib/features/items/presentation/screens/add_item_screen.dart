import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/platform/file_exists.dart';
import '../../../../core/platform/app_image_provider.dart';
import '../../../../services/di/service_locator.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/item_image.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _shopLocationController = TextEditingController();
  final TextEditingController _delegatedToController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();
  String? _selectedImagePath;
  Uint8List? _selectedImageBytes;

  final itemController = ServiceLocator.I.itemController;

  String? _errorMessage;

  bool _enableShopLocation = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _shopLocationController.dispose();
    _delegatedToController.dispose();
    super.dispose();
  }

  Future<void> _handleAdd() async {
    setState(() {
      _errorMessage = null;
    });

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Name is required';
      });
      return;
    }

    final price = double.tryParse(_priceController.text);
    if (price == null) {
      setState(() {
        _errorMessage = 'Price must be a valid number';
      });
      return;
    }

    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      setState(() {
        _errorMessage = 'Quantity must be a positive integer';
      });
      return;
    }

    final item = Item(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: _descriptionController.text.trim(),
      price: price,
      quantity: quantity,
      image: ItemImage(
        path: kIsWeb ? '' : (_selectedImagePath ?? ''),
        base64: kIsWeb && _selectedImageBytes != null
            ? base64Encode(_selectedImageBytes!)
            : null,
      ),
      status: ItemStatus.pending,
      createdAt: DateTime.now(),
      shopLocation: _shopLocationController.text.trim().isEmpty
          ? null
          : _shopLocationController.text.trim(),
    );

    await itemController.addItem(item);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (kIsWeb) {
        if (source == ImageSource.camera) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Camera is not supported on web.')),
            );
          }
          return;
        }

        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
          withData: true,
        );

        final bytes = result?.files.single.bytes;
        if (bytes == null || bytes.isEmpty) {
          return;
        }

        setState(() {
          _selectedImageBytes = bytes;
          _selectedImagePath = null;
        });

        return;
      }

      final isDesktop = defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS;

      if (isDesktop) {
        if (source == ImageSource.camera) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Camera is not supported on desktop.')),
            );
          }
          return;
        }

        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        final path = result?.files.single.path?.trim();
        if (path == null || path.isEmpty) {
          return;
        }

        final exists = await fileExists(path);
        if (!exists) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Selected image file not found.')),
            );
          }
          return;
        }

        setState(() {
          _selectedImagePath = path;
          _selectedImageBytes = null;
        });

        return;
      }

      final picked = await _imagePicker.pickImage(source: source);
      if (picked == null) {
        return;
      }

      final path = picked.path.trim();
      if (path.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to read selected image.')),
          );
        }
        return;
      }

      final exists = await fileExists(path);
      if (!exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selected image file not found.')),
          );
        }
        return;
      }

      setState(() {
        _selectedImagePath = path;
        _selectedImageBytes = null;
      });
    } catch (e, s) {
      debugPrint('Pick image failed: $e\n$s');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    _LabeledField(
                      label: 'ITEM NAME',
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Baby bottle',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _LabeledField(
                      label: 'DESCRIPTION',
                      child: TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          hintText: 'Optional notes',
                        ),
                        minLines: 3,
                        maxLines: null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _LabeledField(
                            label: 'PRICE',
                            child: TextField(
                              controller: _priceController,
                              decoration: const InputDecoration(
                                hintText: '0.00',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _LabeledField(
                            label: 'QUANTITY',
                            child: TextField(
                              controller: _quantityController,
                              decoration: const InputDecoration(
                                hintText: '1',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_selectedImagePath != null || _selectedImageBytes != null) ...[
                      Container(
                        height: 140,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: kIsWeb
                            ? Image.memory(
                                _selectedImageBytes!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(Icons.broken_image),
                                  );
                                },
                              )
                            : Image(
                                image: appImageProvider(
                                  path: _selectedImagePath!,
                                ),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(Icons.broken_image),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.image),
                            label: const Text('Upload Image'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Take Photo'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Enable Shop Location',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Switch(
                          value: _enableShopLocation,
                          onChanged: (value) {
                            setState(() {
                              _enableShopLocation = value;
                              if (!value) {
                                _shopLocationController.clear();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    if (_enableShopLocation) ...[
                      const SizedBox(height: 8),
                      _LabeledField(
                        label: 'SHOP LOCATION',
                        child: TextField(
                          controller: _shopLocationController,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Baby store, online link',
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleAdd,
                        child: const Text('SAVE ITEM'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('CANCEL'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
