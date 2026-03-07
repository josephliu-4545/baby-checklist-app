import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/platform/app_image_provider.dart';
import '../../../../core/platform/file_exists.dart';
import '../../../../services/di/service_locator.dart';
import '../../domain/entities/item.dart';
import 'delegation_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  final String itemId;

  const ItemDetailScreen({
    super.key,
    required this.itemId,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final itemController = ServiceLocator.I.itemController;

  @override
  void initState() {
    super.initState();
    itemController.loadItems();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Item? _findItem() {
    final items = itemController.items;
    for (final item in items) {
      if (item.id == widget.itemId) {
        return item;
      }
    }
    return null;
  }

  Future<void> _markAsPurchased() async {
    await itemController.markPurchased(widget.itemId);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _navigateToDelegate() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DelegationScreen(itemId: widget.itemId),
      ),
    );

    itemController.loadItems();
  }

  Future<void> _deleteItem() async {
    await itemController.deleteItem(widget.itemId);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete item?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteItem();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: itemController,
      builder: (context, child) {
        final item = _findItem();
        final scheme = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Item Details'),
            actions: [
              IconButton(
                onPressed: _navigateToDelegate,
                icon: const Icon(Icons.share),
              ),
            ],
          ),
          body: item == null
              ? const Center(child: Text('Item not found'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ItemImageHeader(item: item),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            _StatusBadge(status: item.status),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _PriceQuantitySection(item: item),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          'DESCRIPTION',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        Text(item.description),
                        if (item.shopLocation != null) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(
                            'SHOP LOCATION',
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.store),
                                const SizedBox(width: 12),
                                Expanded(child: Text(item.shopLocation!)),
                              ],
                            ),
                          ),
                        ],
                        if (item.delegatedTo != null) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(
                            'DELEGATED TO',
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.person_outline),
                                const SizedBox(width: 12),
                                Expanded(child: Text(item.delegatedTo!)),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _markAsPurchased,
                            child: const Text('MARK AS PURCHASED'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  await showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (_) => EditItemBottomSheet(
                                      item: item,
                                    ),
                                  );

                                  itemController.loadItems();
                                },
                                child: const Text('EDIT ITEM'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _navigateToDelegate,
                                child: const Text('DELEGATE'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _confirmDelete,
                            child: Text(
                              'DELETE',
                              style: TextStyle(color: scheme.error),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _ItemImageHeader extends StatelessWidget {
  final Item item;

  const _ItemImageHeader({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final bytes = item.image.hasBase64 ? base64Decode(item.image.base64!) : null;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: item.image.isPlaceholder
          ? const Center(child: Icon(Icons.image, size: 60))
          : kIsWeb
              ? (bytes == null
                  ? const Center(child: Icon(Icons.image, size: 60))
                  : Image.memory(
                      bytes,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.broken_image_outlined, size: 60),
                        );
                      },
                    ))
              : Image(
                  image: appImageProvider(path: item.image.path),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image_outlined, size: 60),
                    );
                  },
                ),
    );
  }
}

class _PriceQuantitySection extends StatelessWidget {
  final Item item;

  const _PriceQuantitySection({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PRICE',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${item.price}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'QUANTITY',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.quantity} Unit',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${item.totalCost}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ItemStatus status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (status) {
      ItemStatus.purchased => (const Color(0xFFCFE8D5), const Color(0xFF1F3B2A)),
      ItemStatus.delegated => (const Color(0xFFF9E7A8), const Color(0xFF3A2F12)),
      ItemStatus.pending => (const Color(0xFFEED6D3), const Color(0xFF3A1E26)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: fg,
            ),
      ),
    );
  }
}

class EditItemBottomSheet extends StatefulWidget {
  final Item item;

  const EditItemBottomSheet({
    super.key,
    required this.item,
  });

  @override
  State<EditItemBottomSheet> createState() => _EditItemBottomSheetState();
}

class _EditItemBottomSheetState extends State<EditItemBottomSheet> {
  final itemController = ServiceLocator.I.itemController;

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;

  final ImagePicker _imagePicker = ImagePicker();
  String? _selectedImagePath;
  Uint8List? _selectedImageBytes;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _descriptionController =
        TextEditingController(text: widget.item.description);
    _priceController = TextEditingController(text: '${widget.item.price}');
    _quantityController =
        TextEditingController(text: '${widget.item.quantity}');
    _selectedImagePath = widget.item.image.isPlaceholder
        ? null
        : widget.item.image.path;

    if (kIsWeb && widget.item.image.hasBase64) {
      _selectedImageBytes = base64Decode(widget.item.image.base64!);
      _selectedImagePath = 'web-memory';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
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

    final updatedItem = widget.item.copyWith(
      name: name,
      description: _descriptionController.text.trim(),
      price: price,
      quantity: quantity,
      image: widget.item.image.copyWith(
        path: kIsWeb ? '' : (_selectedImagePath ?? ''),
        base64: kIsWeb && _selectedImageBytes != null
            ? base64Encode(_selectedImageBytes!)
            : widget.item.image.base64,
      ),
    );

    await itemController.updateItem(updatedItem);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Text(
                  'EDIT ITEM',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
            if ((kIsWeb && _selectedImageBytes != null) ||
                (!kIsWeb && _selectedImagePath != null)) ...[
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
                          return const Center(child: Icon(Icons.broken_image));
                        },
                      )
                    : Image(
                        image: appImageProvider(path: _selectedImagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Icon(Icons.broken_image));
                        },
                      ),
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.image),
              label: const Text('Change Photo'),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSave,
                child: const Text('SAVE CHANGES'),
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
    );
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
          _selectedImagePath = 'web-memory';
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
