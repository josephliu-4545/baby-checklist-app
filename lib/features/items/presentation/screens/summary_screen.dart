import 'package:flutter/material.dart';

import '../../../../core/ui/app_spacing.dart';
import '../../../../core/ui/widgets/section_header.dart';
import '../../../../core/ui/widgets/statistic_card.dart';
import '../../../../services/di/service_locator.dart';
import '../../domain/entities/item.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: itemController,
      builder: (context, child) {
        final error = itemController.errorMessage;
        if (error != null && error.trim().isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error)),
            );
          });
        }

        final items = itemController.items;
        final filteredItems = itemController.displayedItems;
        final isFiltered = itemController.searchQuery.trim().isNotEmpty ||
            itemController.statusFilter != null;

        final totalItems = items.length;
        final purchasedCount =
            items.where((e) => e.status == ItemStatus.purchased).length;
        final pendingCount =
            items.where((e) => e.status == ItemStatus.pending).length;
        final delegatedCount =
            items.where((e) => e.status == ItemStatus.delegated).length;

        double totalCost = 0;
        for (final item in items) {
          totalCost += item.totalCost;
        }

        final filteredTotalItems = filteredItems.length;
        final filteredPurchasedCount =
            filteredItems.where((e) => e.status == ItemStatus.purchased).length;
        final filteredPendingCount =
            filteredItems.where((e) => e.status == ItemStatus.pending).length;
        final filteredDelegatedCount =
            filteredItems.where((e) => e.status == ItemStatus.delegated).length;

        double filteredTotalCost = 0;
        for (final item in filteredItems) {
          filteredTotalCost += item.totalCost;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Summary'),
            actions: [
              IconButton(
                onPressed: _showSearchDialog,
                icon: const Icon(Icons.search),
              ),
              IconButton(
                onPressed: _showFilterDialog,
                icon: const Icon(Icons.filter_list),
              ),
              IconButton(
                onPressed: itemController.searchQuery.isEmpty &&
                        itemController.statusFilter == null
                    ? null
                    : itemController.clearFilters,
                icon: const Icon(Icons.clear),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: itemController.loadItems,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.screenVertical,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isFiltered) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _activeFilterText(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: itemController.clearFilters,
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SectionHeader(title: 'Checklist Summary'),
                    const SizedBox(height: 16),
                    StatisticCard(
                      icon: Icons.list_alt,
                      label: 'Total items',
                      value: '$totalItems',
                    ),
                    const SizedBox(height: 12),
                    StatisticCard(
                      icon: Icons.check_circle,
                      label: 'Purchased',
                      value: '$purchasedCount',
                    ),
                    const SizedBox(height: 12),
                    StatisticCard(
                      icon: Icons.hourglass_bottom,
                      label: 'Pending',
                      value: '$pendingCount',
                    ),
                    const SizedBox(height: 12),
                    StatisticCard(
                      icon: Icons.assignment_ind,
                      label: 'Delegated',
                      value: '$delegatedCount',
                    ),
                    const SizedBox(height: 12),
                    StatisticCard(
                      icon: Icons.attach_money,
                      label: 'Total estimated cost',
                      value: totalCost.toStringAsFixed(2),
                    ),
                    if (isFiltered) ...[
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      const SectionHeader(title: 'Filtered Summary'),
                      const SizedBox(height: 16),
                      StatisticCard(
                        icon: Icons.list_alt,
                        label: 'Total items',
                        value: '$filteredTotalItems',
                      ),
                      const SizedBox(height: 12),
                      StatisticCard(
                        icon: Icons.check_circle,
                        label: 'Purchased',
                        value: '$filteredPurchasedCount',
                      ),
                      const SizedBox(height: 12),
                      StatisticCard(
                        icon: Icons.hourglass_bottom,
                        label: 'Pending',
                        value: '$filteredPendingCount',
                      ),
                      const SizedBox(height: 12),
                      StatisticCard(
                        icon: Icons.assignment_ind,
                        label: 'Delegated',
                        value: '$filteredDelegatedCount',
                      ),
                      const SizedBox(height: 12),
                      StatisticCard(
                        icon: Icons.attach_money,
                        label: 'Total estimated cost',
                        value: filteredTotalCost.toStringAsFixed(2),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSearchDialog() async {
    final controller = TextEditingController(text: itemController.searchQuery);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'ITEM NAME',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Search by item name',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, ''),
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      itemController.setSearchQuery(result);
    }
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<ItemStatus?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter by status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.all_inclusive),
                title: const Text('All'),
                onTap: () => Navigator.pop(context, null),
              ),
              ListTile(
                leading: const Icon(Icons.hourglass_bottom),
                title: const Text('Pending'),
                onTap: () => Navigator.pop(context, ItemStatus.pending),
              ),
              ListTile(
                leading: const Icon(Icons.check_circle),
                title: const Text('Purchased'),
                onTap: () => Navigator.pop(context, ItemStatus.purchased),
              ),
              ListTile(
                leading: const Icon(Icons.assignment_ind),
                title: const Text('Delegated'),
                onTap: () => Navigator.pop(context, ItemStatus.delegated),
              ),
            ],
          ),
        );
      },
    );

    itemController.setStatusFilter(result);
  }

  String _activeFilterText() {
    final query = itemController.searchQuery.trim();
    final status = itemController.statusFilter;

    final parts = <String>[];
    if (query.isNotEmpty) {
      parts.add('Search: $query');
    }
    if (status != null) {
      parts.add('Status: ${status.name}');
    }

    return parts.join(' | ');
  }
}
