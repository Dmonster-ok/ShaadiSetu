import 'package:flutter/material.dart';

class GenderSelector extends StatelessWidget {
  final int groupValue;
  final ValueChanged<int?> onChanged;

  const GenderSelector({super.key, 
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Gender: ', style: TextStyle(fontSize: 20)),
        Expanded(child: SizedBox()),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<int>(
              value: 0,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
            Text('Male'),
            Radio<int>(
              value: 1,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
            Text('Female'),
          ],
        ),
      ],
    );
  }
}
