import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ShowImagePicker extends StatefulWidget {
  final Function(String path)? onImagePicked;
  const ShowImagePicker({super.key, required this.onImagePicked});

  @override
  State<ShowImagePicker> createState() => _ShowImagePickerState();
}

class _ShowImagePickerState extends State<ShowImagePicker> {
  String? _savedImagePath;

  static const double _imagePickerSize = 135;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        clipBehavior: Clip.antiAlias,
        height: _imagePickerSize,
        width: _imagePickerSize,
        decoration: BoxDecoration(
          image: _savedImagePath != null
              ? DecorationImage(image: FileImage(File(_savedImagePath!)), fit: BoxFit.cover)
              : null,
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onTap: () async {
        final pickedPath = await _pickImage();
        if (pickedPath != null) {
          setState(() {
            _savedImagePath = pickedPath;
          });
          widget.onImagePicked?.call(pickedPath);
        }
      },
    );
  }

  Future<String?> _pickImage() async {
    final ImagePicker imagePicker = ImagePicker();

    final source = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Choose Image Source"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, 'camera'), child: const Text("Camera")),
          TextButton(onPressed: () => Navigator.pop(context, 'gallery'), child: const Text("Gallery")),
          TextButton(onPressed: () => Navigator.pop(context, 'remove'), child: const Text("Remove")),
        ],
      ),
    );

    if (source == null) return null; // No selection

    if (source == 'remove') {
      setState(() {
        _savedImagePath = null;
      });
      return null;
    }

    final imgSource = source == 'camera' ? ImageSource.camera : ImageSource.gallery;
    final pickedFile = await imagePicker.pickImage(source: imgSource, imageQuality: 25);

    if (pickedFile != null) {
      return _saveImageToFolder(pickedFile);
    }
    return null;
  }

  Future<String> _saveImageToFolder(XFile imageFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${appDir.path}/saved_images');
    if (!await imageDir.exists()) await imageDir.create(recursive: true);

    final newImagePath = '${imageDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(imageFile.path).copy(newImagePath);
    
    return newImagePath;
  }
}
