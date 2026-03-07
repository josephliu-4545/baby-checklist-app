import 'package:flutter/material.dart';

import '../../../../core/ui/app_spacing.dart';
import '../../../../core/ui/widgets/item_card.dart';
import '../../../../services/di/service_locator.dart';
import '../../domain/entities/item.dart';
import 'item_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Baby Checklist'),
            actions: [
              IconButton(
                onPressed: _showSearchDialog,
                icon: const Icon(Icons.search),
              ),
              IconButton(
                onPressed: _showFilterDialog,
                icon: const Icon(Icons.filter_list),
              ),
            ],
          ),
          body: Column(
            children: [
              if (itemController.searchQuery.trim().isNotEmpty ||
                  itemController.statusFilter != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
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
                ),
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (itemController.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final displayedItems = itemController.displayedItems;

    if (displayedItems.isEmpty) {
      return RefreshIndicator(
        onRefresh: itemController.loadItems,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64),
                  SizedBox(height: 12),
                  Text('No items added yet.'),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: itemController.loadItems,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: 8,
        ),
        itemCount: displayedItems.length,
        itemBuilder: (context, index) {
          final item = displayedItems[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ItemCard(
              item: item,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ItemDetailScreen(itemId: item.id),
                  ),
                );
                itemController.loadItems();
              },
            ),
          );
        },
      ),
    );
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
}