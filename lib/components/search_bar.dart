import 'package:flutter/material.dart';
import 'text_field.dart';

PreferredSizeWidget searchBar(
    {required TextEditingController searchController,required Function(String) onChanged}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(60),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: CustomTextField(
        label: 'Search Users',
        controller: searchController,
        keyboardType: TextInputType.text,
        maxLines: 1,
        suffixIcon: const Icon(Icons.search),
        onChanged: onChanged,
        validator: (value) => null,
      ),
    ),
  );
}
