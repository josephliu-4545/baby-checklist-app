import 'package:flutter/material.dart';

import '../../../features/items/domain/entities/item.dart';

class StatusBadge extends StatelessWidget {
  final ItemStatus status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, IconData icon) = switch (status) {
      ItemStatus.purchased => (
          const Color(0xFFCFE8D5),
          const Color(0xFF1F3B2A),
          Icons.check_circle,
        ),
      ItemStatus.delegated => (
          const Color(0xFFF9E7A8),
          const Color(0xFF3A2F12),
          Icons.assignment_ind,
        ),
      ItemStatus.pending => (
          const Color(0xFFEED6D3),
          const Color(0xFF3A1E26),
          Icons.hourglass_bottom,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            status.name.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
          ),
        ],
      ),
    );
  }
}
