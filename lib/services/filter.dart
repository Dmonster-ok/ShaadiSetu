import 'table_details.dart';

List<Map<String, dynamic>> filter({
  required List<Map<String, dynamic>> users,
  required String searchQuery,
}) {
  final String query = searchQuery.trim().toLowerCase();

  if (query.isEmpty) return users;

  return users.where((user) {
    final String firstname = (user[TableDetails.firstName] as String?)?.toLowerCase() ?? '';
    final String lastname = (user[TableDetails.lastName] as String?)?.toLowerCase() ?? '';
    final String city = (user[TableDetails.address] as String?)?.toLowerCase() ?? '';
    final String age = (user['age']?.toString() ?? '').toLowerCase();
    final String phone = (user[TableDetails.phone]?.toString() ?? '').toLowerCase();
    final String email = (user[TableDetails.email] as String?)?.toLowerCase() ?? '';

    return firstname.contains(query) ||
        lastname.contains(query) ||
        city.contains(query) ||
        age.contains(query) ||
        phone.contains(query) ||
        email.contains(query);
  }).toList();
}
