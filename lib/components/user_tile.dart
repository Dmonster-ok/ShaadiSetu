import 'dart:io';
import 'package:flutter/material.dart';

class UserTile extends StatefulWidget {
  final int index;
  final bool isSelected;
  final String title;
  final String subtitle;
  final String other;
  final String? profileImage;
  final bool isFavourite;
  final void Function()? onProfileTap;
  final void Function()? onTap;
  final void Function()? onFavourite;
  final void Function()? onDelete;
  final void Function()? onUpdate;
  final Widget? extraContent;
  final VoidCallback? onRefresh;

  const UserTile({
    super.key,
    required this.index,
    required this.title,
    required this.subtitle,
    required this.other,
    required this.isSelected,
    required this.isFavourite,
    this.profileImage,
    this.onProfileTap,
    this.onFavourite,
    this.onDelete,
    this.onUpdate,
    this.onTap,
    this.extraContent,
    this.onRefresh,
  });

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  static const double _pfpSize = 90;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 2,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: widget.onProfileTap,
                    child: Container(
                      width: _pfpSize,
                      height: _pfpSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: widget.profileImage != null &&
                                  File(widget.profileImage!).existsSync()
                              ? FileImage(File(widget.profileImage!))
                              : const AssetImage('assets/images/default.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          widget.other,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: _pfpSize,
                    child: Center(
                        child: IconButton(
                          style: ButtonStyle(
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                      onPressed: widget.onFavourite,
                      icon: Icon(
                        widget.isFavourite ? Icons.star : Icons.star_border,
                        color: widget.isFavourite
                            ? Colors.deepPurple[300]
                            : Colors.grey,
                      ),
                    )),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.fastEaseInToSlowEaseOut,
                child: widget.isSelected
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: widget.extraContent,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
