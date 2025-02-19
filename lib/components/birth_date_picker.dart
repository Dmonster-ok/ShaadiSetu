import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'text_field.dart';

class BirthDatePicker extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final TextEditingController dateController;
  final DateTime initialDate;

  const BirthDatePicker({
    super.key,
    required this.onDateSelected,
    required this.dateController,
    required this.initialDate,
  });

  @override
  State<BirthDatePicker> createState() => _BirthDatePickerState();
}

class _BirthDatePickerState extends State<BirthDatePicker> {
  DateTime? _selectedDate;
  final DateTime _firstDate =
      DateTime.now().subtract(const Duration(days: 365 * 55));
  final DateTime _lastDate =
      DateTime.now().subtract(const Duration(days: 365 * 18));
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    widget.dateController.text = _dateFormat.format(_selectedDate!);
  }

  Future<void> _selectDate(BuildContext context) async {
    try {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        initialDate: _selectedDate!,
        firstDate: _firstDate,
        lastDate: _lastDate,
      );

      if (pickedDate != null) {
        setState(() {
          _selectedDate = pickedDate;
          widget.dateController.text = _dateFormat.format(_selectedDate!);
        });
        widget.onDateSelected(_selectedDate!);
      }
    } catch (e) {
      debugPrint("Error selecting date: $e");
    }
  }

  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a date';
    }
    try {
      final DateTime date = _dateFormat.parseStrict(value);
      if (date.isBefore(_firstDate) || date.isAfter(_lastDate)) {
        return 'Age must be between 18 and 55';
      }
    } catch (e) {
      return 'Invalid date format (dd-MM-yyyy)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: 'Birthdate',
      controller: widget.dateController,
      keyboardType: TextInputType.datetime,
      maxLines: 1,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9/-]')),
      ],
      suffixIcon: IconButton(
        icon: const Icon(Icons.calendar_today),
        onPressed: () => _selectDate(context),
      ),
      validator: _validateDate,
      onChanged: (value) {
        try {
          final DateTime parsedDate = _dateFormat.parseStrict(value);
          if (parsedDate.isAfter(_firstDate) && parsedDate.isBefore(_lastDate)) {
            setState(() {
              _selectedDate = parsedDate;
            });
            widget.onDateSelected(parsedDate);
          }
        } catch (e) {
        }
      },
    );
  }
}
