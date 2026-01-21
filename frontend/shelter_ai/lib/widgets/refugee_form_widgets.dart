import 'package:flutter/material.dart';

/// Section header for refugee forms
class RefugeeSectionHeader extends StatelessWidget {
  final String title;

  const RefugeeSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}

/// Multi-select dropdown for refugee forms
class RefugeeMultiSelectDropdown extends StatefulWidget {
  final String title;
  final List<String> items;
  final List<String> selectedItems;
  final Function(List<String>) onChanged;

  const RefugeeMultiSelectDropdown({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
  });

  @override
  State<RefugeeMultiSelectDropdown> createState() =>
      _RefugeeMultiSelectDropdownState();
}

class _RefugeeMultiSelectDropdownState
    extends State<RefugeeMultiSelectDropdown> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: PopupMenuButton<String>(
            itemBuilder: (context) {
              return widget.items.map((item) {
                final isSelected = widget.selectedItems.contains(item);
                return PopupMenuItem(
                  value: item,
                  child: Row(
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (v) {
                          final newList = List<String>.from(widget.selectedItems);
                          if (isSelected) {
                            newList.remove(item);
                          } else {
                            newList.add(item);
                          }
                          widget.onChanged(newList);
                          Navigator.pop(context);
                        },
                      ),
                      Expanded(child: Text(item)),
                    ],
                  ),
                );
              }).toList();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.selectedItems.isEmpty
                          ? 'Select items...'
                          : '${widget.selectedItems.length} selected',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ),
        if (widget.selectedItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Wrap(
              spacing: 4,
              children: widget.selectedItems
                  .map(
                    (item) => Chip(
                      label: Text(item, style: const TextStyle(fontSize: 12)),
                      onDeleted: () {
                        setState(() {
                          widget.selectedItems.remove(item);
                          widget.onChanged(widget.selectedItems);
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}

/// Info bullet point for dialogs
class RefugeeInfoBullet extends StatelessWidget {
  final String number;
  final String text;

  const RefugeeInfoBullet({
    super.key,
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
        ),
      ],
    );
  }
}

/// Reusable Family ID info modal
class FamilyIdInfoModal {
  static void show(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.family_restroom, size: 28, color: color.primary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'What is Family ID?',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'A Family ID is a unique identifier that connects family members in the shelter system. If you arrive with family members, you should use the same Family ID to ensure you stay together.',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'How to get a Family ID:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const RefugeeInfoBullet(
                number: '1',
                text:
                    'If this is your first time registering: Leave this field empty.',
              ),
              const SizedBox(height: 8),
              const RefugeeInfoBullet(
                number: '2',
                text:
                    'If a family member already registered: Ask them for their Family ID (they can see it in their QR code).',
              ),
              const SizedBox(height: 8),
              const RefugeeInfoBullet(
                number: '3',
                text: 'Enter their Family ID in this field to link yourselves.',
              ),
              const SizedBox(height: 8),
              const RefugeeInfoBullet(
                number: '4',
                text:
                    'If you register together for the first time, you can leave it empty and request family linking at arrival.',
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade600, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber,
                        size: 20, color: Colors.amber.shade700),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Using the correct Family ID ensures your family stays together and receives appropriate accommodation.',
                        style:
                            TextStyle(fontSize: 13, color: Color(0xFF664D00)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Got it'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
