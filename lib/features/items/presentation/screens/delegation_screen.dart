import 'package:flutter/material.dart';

import '../../../../core/platform/sms_launcher.dart';
import '../../../../services/di/service_locator.dart';

class DelegationScreen extends StatefulWidget {
  final String itemId;

  const DelegationScreen({
    super.key,
    required this.itemId,
  });

  @override
  State<DelegationScreen> createState() => _DelegationScreenState();
}

class _DelegationScreenState extends State<DelegationScreen> {
  final TextEditingController _delegatedToController = TextEditingController();
  final itemController = ServiceLocator.I.itemController;

  String? _errorMessage;

  @override
  void dispose() {
    _delegatedToController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelegation() async {
    final delegatedTo = _delegatedToController.text.trim();
    if (delegatedTo.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a name or phone number';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    final shouldDelegate = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delegate item?'),
          content: Text('Delegate to: $delegatedTo'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (shouldDelegate != true) {
      return;
    }

    await itemController.delegateItem(
      itemId: widget.itemId,
      delegatedTo: delegatedTo,
    );

    final itemName = itemController.items
        .where((i) => i.id == widget.itemId)
        .map((i) => i.name)
        .cast<String?>()
        .firstWhere(
          (name) => name != null && name.trim().isNotEmpty,
          orElse: () => null,
        );

    final message = itemName == null
        ? 'You have been delegated to purchase an item.'
        : 'You have been delegated to purchase: $itemName';

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delegated to $delegatedTo')),
      );

      if (SmsLauncher.looksLikePhoneNumber(delegatedTo)) {
        final opened = await SmsLauncher.openComposer(
          phoneNumber: delegatedTo,
          message: message,
        );
        if (!opened && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to open the SMS app on this device.'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enter a phone number to open the SMS app.'),
          ),
        );
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delegate Item'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.assignment_ind,
                        size: 34,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Delegate this item',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter a family member name or phone number. If you enter a phone number, the SMS app will open after delegation.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'DELEGATE TO',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _delegatedToController,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _confirmDelegation(),
                            decoration: const InputDecoration(
                              hintText: 'e.g. Mom / +60123456789',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _confirmDelegation,
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Confirm delegation'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
