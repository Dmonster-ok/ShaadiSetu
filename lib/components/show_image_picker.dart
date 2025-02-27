import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ShowImagePicker extends StatefulWidget {
  final Function(String? path)? onImagePicked;
  final String? initialImagePath;

  const ShowImagePicker(
      {super.key, required this.onImagePicked, this.initialImagePath});

  @override
  State<ShowImagePicker> createState() => _ShowImagePickerState();
}

class _ShowImagePickerState extends State<ShowImagePicker> {

  String? _savedImagePath;
  static const double _imagePickerSize = 135;
  
  @override
  void initState() {
    super.initState();
    _savedImagePath = widget.initialImagePath;
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final pickedPath = await _pickImage();
        setState(() {
          _savedImagePath = pickedPath;
        });
        widget.onImagePicked?.call(pickedPath);
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        height: _imagePickerSize,
        width: _imagePickerSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.grey[300],
          image: _savedImagePath != null
              ? DecorationImage(
                  image: FileImage(File(_savedImagePath!)),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                )
              : null,
        ),
        child: _savedImagePath == null
            ? const Center(
                child: Icon(Icons.camera_alt, size: 40, color: Colors.grey))
            : null,
      ),
    );
  }

  Future<String?> _pickImage() async {
    final ImagePicker imagePicker = ImagePicker();

    final source = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Choose Image Source"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, 'camera'),
              child: const Text("Camera")),
          TextButton(
              onPressed: () => Navigator.pop(context, 'gallery'),
              child: const Text("Gallery")),
          TextButton(
              onPressed: () => Navigator.pop(context, 'remove'),
              child: const Text("Remove")),
        ],
      ),
    );

    if (source == null) return null;

    if (source == 'remove') {
      widget.onImagePicked?.call(null);
      return null;
    }

    final imgSource =
        source == 'camera' ? ImageSource.camera : ImageSource.gallery;
    final pickedFile =
        await imagePicker.pickImage(source: imgSource, imageQuality: 50);

    if (pickedFile == null) return null;

    return _saveImageToFolder(pickedFile);
  }

  Future<String> _saveImageToFolder(XFile imageFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${appDir.path}/saved_images');
    if (!await imageDir.exists()) await imageDir.create(recursive: true);

    final newImagePath =
        '${imageDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(imageFile.path).copy(newImagePath);

    return newImagePath;
  }
}
