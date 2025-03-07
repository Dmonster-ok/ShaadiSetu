import 'package:flutter/material.dart';

class MoreOptionsButton extends StatelessWidget {
  final Function(String) onSelected;
  final IconData? icon;
  final List<MoreOptionItem> options;

  const MoreOptionsButton({
    super.key,
    required this.onSelected,
    required this.options,
    this.icon = Icons.more_vert,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      icon: Icon(icon),
      itemBuilder: (context) => options
          .map(
            (option) => PopupMenuItem<String>(
              value: option.value,
              child: ListTile(
                leading: Icon(option.icon),
                title: Text(option.label),
              ),
            ),
          )
          .toList(),
    );
  }
}

class MoreOptionItem {
  final String value;
  final IconData icon;
  final String label;

  const MoreOptionItem({
    required this.value,
    required this.icon,
    required this.label,
  });
}
