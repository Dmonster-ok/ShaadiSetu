import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/cities.dart';
import '../services/user_model.dart';
import 'gender_selector.dart';
import 'show_image_picker.dart';
import 'text_field.dart';

class AddUser extends StatefulWidget {
  final String title;
  final VoidCallback onUserAdded;
  final UserModel? user;
  const AddUser(
      {super.key, this.title = 'Add', required this.onUserAdded, this.user});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  String _pfpPath = 'assets/images/default_pfp.png';
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _hobbiesController = TextEditingController();
  int _selectedGender = 0;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static const double _padding = 10.0;

  void _resetForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();
    _cityController.clear();
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.95,
      maxChildSize: 0.95,
      shouldCloseOnMinExtent: true,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(_padding + 5),
          child: Column(
            children: [
              _title(),
              Divider(height: _padding),
              Flexible(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _personalInfo(),
                    _contactInfo(),
                    SizedBox(height: _padding),
                    _genderSelector(),
                    SizedBox(height: _padding),
                    _hobbies(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _title() {
    return Padding(
      padding: const EdgeInsets.all(_padding),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(widget.title,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              _resetForm();
            },
            child: const Text('Reset'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                widget.onUserAdded();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }


  // **Personal Information Section**
  Widget _personalInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ShowImagePicker(onImagePicked: (String path) {
          _pfpPath = path;
        },),
        const SizedBox(width: _padding),
        Expanded(
          child: Column(
            children: [
              CustomTextField(
                label: 'First Name',
                maxLength: 25,
                maxLines: 1,
                controller: _firstNameController,
                validator: (value) =>
                    value!.isEmpty ? 'First Name is required' : null,
              ),
              const SizedBox(height: _padding),
              CustomTextField(
                label: 'Last Name',
                maxLength: 25,
                maxLines: 1,
                controller: _lastNameController,
                validator: (value) =>
                    value!.isEmpty ? 'Last Name is required' : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // **Hobbies Section**
  Widget _hobbies() {
    hobbyChip(String label) {
      return Chip(
        label: Text(label),
        
      );
    }
    return Column(
      mainAxisAlignment :MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Hobbies', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 5),
        Wrap(
          spacing: 5,
          children: [
            hobbyChip('Reading'),
            hobbyChip('Writing'),
            hobbyChip('Coding'),
            hobbyChip('Singing'),
            hobbyChip('Dancing'),
            hobbyChip('Cooking'),
            hobbyChip('Gaming'),
            hobbyChip('Travelling'),
          ],
        ),
      ],
    );
  }
  // **Contact Information Section**
  Widget _contactInfo() {
    return Column(
      children: [
        CustomTextField(
          label: 'Email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value!.isEmpty) return 'Email is required';
            if (!RegExp(r"^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$")
                .hasMatch(value)) {
              return 'Enter a valid email address';
            }
            return null;
          },
        ),
        CustomTextField(
          label: 'Phone',
          controller: _phoneController,
          maxLength: 10,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) =>
              (value!.length != 10) ? 'Phone number should be 10 digits' : null,
        ),
        CustomTextField(
          label: 'Address',
          controller: _addressController,
          minLines: 4,
          maxLines: 5,
          validator: (value) => value!.isEmpty ? 'Address is required' : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: DropdownMenu(
            width: double.maxFinite,
            label: Text('City'),
            controller: _cityController,
            requestFocusOnTap: true,
            menuHeight: 250,
            dropdownMenuEntries: gujaratCities.map((city) => DropdownMenuEntry(value: city, label: city)).toList()),
        )
      ],
    );
  }

  // **Gender Selector**
  Widget _genderSelector() {
    return GenderSelector(
      groupValue: _selectedGender,
      onChanged: (value) {
        if (value != null) setState(() => _selectedGender = value);
      },
    );
  }

}
