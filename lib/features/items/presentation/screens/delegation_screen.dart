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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _delegatedToController,
              decoration: const InputDecoration(
                labelText: 'Family member name or phone',
              ),
            ),
            if (_errorMessage != null) Text(_errorMessage!),
            ElevatedButton(
              onPressed: _confirmDelegation,
              child: const Text('Confirm Delegate'),
            ),
          ],
        ),
      ),
    );
  }
}
