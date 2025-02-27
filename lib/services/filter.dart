import 'table_details.dart';

List<Map<String, dynamic>> filter({
  required List<Map<String, dynamic>> users,
  required String searchQuery,
}) {
  final String query = searchQuery.trim().toLowerCase();

  return users.where((user) {
    final String firstname = (user[TableDetails.firstName] as String?)?.toLowerCase() ?? '';
    final String lastname = (user[TableDetails.lastName] as String?)?.toLowerCase() ?? '';
    final String fullname = '$firstname $lastname'.toLowerCase(); 
    final String city = (user[TableDetails.city] as String?)?.toLowerCase() ?? '';
    final String profession = (user[TableDetails.profession] as String?)?.toLowerCase() ?? '';
    final String age = (user[TableDetails.age]?.toString() ?? '').toLowerCase();
    final String phone = (user[TableDetails.phone]?.toString() ?? '').toLowerCase();

    return firstname.contains(query) ||
        lastname.contains(query) ||
        fullname.contains(query) ||
        city.contains(query) ||
        profession.contains(query) ||
        age.contains(query) ||
        phone.contains(query);
  }).toList();
}
