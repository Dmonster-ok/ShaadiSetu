import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../components/birth_date_picker.dart';
import '../components/gender_selector.dart';
import '../components/show_image_picker.dart';
import '../components/text_field.dart';
import '../services/cities.dart';
import '../services/database_services.dart';
import '../services/user_model.dart';

class UserForm extends StatefulWidget {
  final String title;
  final VoidCallback onUserAdded;
  final UserModel? user;
  const UserForm(
      {super.key, this.title = 'Add', required this.onUserAdded, this.user});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  String _pfpPath = '';
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _hobbiesController = TextEditingController();
  final TextEditingController _castController = TextEditingController();
  final TextEditingController _religionController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  final Color _errorColor = Color(0xFFB3261E);
  bool _cityError = false;
  String? _selectedCity;
  Set<String> _selectedHobbies = {};
  DateTime _selectedDate =
      DateTime.now().subtract(const Duration(days: 365 * 25));
  int _selectedGender = 0;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static const double _padding = 10.0;

  void _resetForm() {
    setState(() {
      _formKey.currentState?.reset();
      _firstNameController.clear();
      _lastNameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _addressController.clear();
      _cityController.clear();
      _hobbiesController.clear();
      _castController.clear();
      _religionController.clear();
      _professionController.clear();
      _pfpPath = '';
      _selectedDate = DateTime.now().subtract(const Duration(days: 365 * 25));
      _birthDateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate);
      _selectedGender = 0;
      _selectedHobbies.clear();
      _selectedCity = null;
      _cityError = false;
    });
  }

  @override
  void initState() {
    super.initState();

    if (widget.user != null) {
      _firstNameController.text = widget.user!.firstName.trim();
      _lastNameController.text = widget.user!.lastName.trim();
      _emailController.text = widget.user!.email.toLowerCase().trim();
      _phoneController.text = widget.user!.phone.trim();
      _addressController.text = widget.user!.address.trim();
      _cityController.text = widget.user!.city.trim();
      _hobbiesController.text = widget.user!.hobbies.trim();
      _castController.text = widget.user!.cast.trim();
      _religionController.text = widget.user!.religion.trim();
      _professionController.text = widget.user!.profession.trim();
      _selectedDate = DateTime.parse(widget.user!.birthDate);
      _birthDateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate);
      _selectedGender = widget.user!.gender;
      _pfpPath = widget.user!.profileImage!;
      _selectedHobbies = widget.user!.hobbies.split(',').toSet();
      _selectedCity = widget.user!.city.trim();
    } else {
      _resetForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.85,
      maxChildSize: 0.85,
      shouldCloseOnMinExtent: true,
      snap: true,
      snapAnimationDuration: const Duration(milliseconds: 150),
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(_padding + 5),
          child: Column(
            children: [
              _title(),
              Divider(height: _padding),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    children: [
                      _personalInfo(),
                      SizedBox(height: _padding),
                      _birthDateAndGender(),
                      _contactInfo(),
                      _otherInfo(),
                      const SizedBox(height: 50),
                    ],
                  ),
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
        children: [
          Text(
            '${widget.title} User',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _resetForm,
            child: const Text('Reset'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _cityError = _selectedCity == null || _selectedCity!.isEmpty;
              });

              if (_formKey.currentState?.validate() ?? false) {
                UserModel newUser = UserModel(
                  id: widget.user?.id ?? 0, // Use existing ID for updates
                  firstName: _firstNameController.text.trim(),
                  lastName: _lastNameController.text.trim(),
                  email: _emailController.text.trim(),
                  phone: _phoneController.text.trim(),
                  address: _addressController.text.trim(),
                  city: _cityController.text.trim(),
                  hobbies: _selectedHobbies.join(','),
                  cast: _castController.text.trim(),
                  religion: _religionController.text.trim(),
                  profession: _professionController.text.trim(),
                  gender: _selectedGender,
                  profileImage: _pfpPath,
                  birthDate: _selectedDate.toIso8601String(),
                  createdAt: widget.user?.createdAt ??
                      DateTime.now().toIso8601String(),
                );

                bool success = widget.user != null
                    ? await DatabaseServices().updateUser(user: newUser)
                    : await DatabaseServices().addUser(user: newUser);

                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Potential error occurred. or User already exists')),
                  );
                }

                widget.onUserAdded();
                _resetForm();
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
        ShowImagePicker(
          initialImagePath: _pfpPath,
          onImagePicked: (String? path) {
            setState(() {
              if (path != null) {
                _pfpPath = path;
              }
            });
          },
        ),
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

  Widget _birthDateAndGender() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BirthDatePicker(
          onDateSelected: (date) {
            setState(() {
              _selectedDate = date;
              _birthDateController.text =
                  DateFormat('dd-MM-yyyy').format(date);
            });
          },
          dateController: _birthDateController,
          initialDate: _selectedDate,
        ),
        GenderSelector(
          groupValue: _selectedGender,
          onChanged: (value) {
            if (value != null) setState(() => _selectedGender = value);
          },
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
        _cityDropdown(),
        CustomTextField(
          label: 'Address',
          controller: _addressController,
          keyboardType: TextInputType.multiline,
          minLines: 4,
          maxLines: 4,
          maxLength: 120,
          inputFormatters: [
            LengthLimitingTextInputFormatter(120),
          ],
          hintText: 'Address',
          floatingLabelBehavior: FloatingLabelBehavior.always,
          validator: (value) => value!.isEmpty ? 'Address is required' : null,
        ),
      ],
    );
  }

  // **City Dropdown**
  Widget _cityDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownMenu(
            width: double.maxFinite,
            label: Text(
              'City',
              style: TextStyle(
                color: _cityError
                    ? _errorColor
                    : Colors.grey[800], // Label color change
              ),
            ),
            controller: _cityController,
            requestFocusOnTap: true,
            menuHeight: 350,
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: _cityError
                      ? _errorColor
                      : Colors.grey, // Border color change
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color:
                      _cityError ? _errorColor : Colors.grey, // Normal border
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: _cityError ? _errorColor : Colors.deepPurple,
                  width: 2, // Focus border
                ),
              ),
            ),
            dropdownMenuEntries: gujaratCities
                .map((city) => DropdownMenuEntry(value: city, label: city))
                .toList(),
            onSelected: (value) {
              setState(() {
                _selectedCity = value;
                _cityController.text = value!;
                _cityError = false;
              });
            },
          ),
          if (_cityError)
            Padding(
              padding: EdgeInsets.only(top: 5, left: 10),
              child: Text(
                'Please select a city',
                style: TextStyle(color: _errorColor, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

// **Other Information Section**
  Widget _otherInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomTextField(
          label: 'Profession',
          controller: _professionController,
          maxLength: 100,
          maxLines: 1,
          validator: (value) =>
              value!.isEmpty ? 'Profession is required' : null,
        ),
        CustomTextField(
          label: 'Cast',
          controller: _castController,
          maxLength: 50,
          maxLines: 1,
          validator: (value) => null,
        ),
        CustomTextField(
          label: 'Religion',
          controller: _religionController,
          maxLength: 50,
          maxLines: 1,
          validator: (value) => null,
        ),
        _hobbies(),
      ],
    );
  }

  // **Hobbies Section**
  Widget _hobbies() {
    List<String> hobbiesList = [
      'Reading',
      'Writing',
      'Coding',
      'Singing',
      'Dancing',
      'Cooking',
      'Gaming',
      'Travelling'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: _padding),
        const Text('Hobbies', style: TextStyle(fontSize: 16)),
        const SizedBox(height: _padding / 2),
        Wrap(
          spacing: 5,
          children: hobbiesList.map((hobby) {
            bool isSelected = _selectedHobbies.contains(hobby);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedHobbies.remove(hobby);
                  } else {
                    _selectedHobbies.add(hobby);
                  }
                });
              },
              child: Chip(
                label: Text(hobby),
                backgroundColor:
                    isSelected ? Colors.deepPurple[400] : Colors.transparent,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
