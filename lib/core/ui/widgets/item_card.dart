import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

import '../../../features/items/domain/entities/item.dart';
import '../../platform/app_image_provider.dart';
import '../app_spacing.dart';
import 'status_badge.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback? onTap;

  const ItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.radiusMd,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _ItemThumbnail(item: item),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        StatusBadge(status: item.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${item.price.toStringAsFixed(2)} · Qty ${item.quantity}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemThumbnail extends StatelessWidget {
  final Item item;

  const _ItemThumbnail({required this.item});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final bytes = item.image.hasBase64
        ? base64Decode(item.image.base64!)
        : null;

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: AppSpacing.radiusSm,
      ),
      clipBehavior: Clip.antiAlias,
      child: item.image.isPlaceholder
          ? Icon(Icons.image_outlined, color: scheme.onSurfaceVariant)
          : kIsWeb
              ? (bytes == null
                  ? Icon(Icons.image_outlined, color: scheme.onSurfaceVariant)
                  : Image.memory(
                      bytes,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.broken_image_outlined,
                          color: scheme.onSurfaceVariant,
                        );
                      },
                    ))
              : Image(
                  image: appImageProvider(path: item.image.path),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.broken_image_outlined,
                      color: scheme.onSurfaceVariant,
                    );
                  },
                ),
    );
  }
}
