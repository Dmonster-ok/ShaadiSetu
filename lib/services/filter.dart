import 'table_details.dart';

List<Map<String, dynamic>> filter({
  required List<Map<String, dynamic>> users,
  required String searchQuery,
  String sortingMethod = '??newest',
}) {
  final String query = searchQuery.trim().toLowerCase();

  List<Map<String, dynamic>> filteredUsers = users.where((user) {
    final String firstname =
        (user[TableDetails.firstName] as String?)?.toLowerCase() ?? '';
    final String lastname =
        (user[TableDetails.lastName] as String?)?.toLowerCase() ?? '';
    final String fullname = '$firstname $lastname';
    final String city =
        (user[TableDetails.city] as String?)?.toLowerCase() ?? '';
    final String profession =
        (user[TableDetails.profession] as String?)?.toLowerCase() ?? '';
    final String age = (user[TableDetails.age]?.toString() ?? '').toLowerCase();
    final String phone =
        (user[TableDetails.phone]?.toString() ?? '').toLowerCase();

    return firstname.contains(query) ||
        lastname.contains(query) ||
        fullname.contains(query) ||
        city.contains(query) ||
        profession.contains(query) ||
        age.contains(query) ||
        phone.contains(query);
  }).toList();

  switch (sortingMethod) {
    case 'a-z':
      filteredUsers.sort((a, b) {
        final String nameA =
            ('${a[TableDetails.firstName]} ${a[TableDetails.lastName]}')
                .toLowerCase();
        final String nameB =
            ('${b[TableDetails.firstName]} ${b[TableDetails.lastName]}')
                .toLowerCase();
        return nameA.compareTo(nameB);
      });
      break;

    case 'z-a':
      filteredUsers.sort((a, b) {
        final String nameA =
            ('${a[TableDetails.firstName]} ${a[TableDetails.lastName]}')
                .toLowerCase();
        final String nameB =
            ('${b[TableDetails.firstName]} ${b[TableDetails.lastName]}')
                .toLowerCase();
        return nameB.compareTo(nameA);
      });
      break;

    case 'city':
      filteredUsers.sort((a, b) {
        final String cityA =
            (a[TableDetails.city] as String?)?.toLowerCase() ?? '';
        final String cityB =
            (b[TableDetails.city] as String?)?.toLowerCase() ?? '';
        return cityA.compareTo(cityB);
      });
      break;

    case 'newest':
      filteredUsers = filteredUsers.reversed.toList();
      break;

    case 'oldest':
    default:
      break;
  }

  return filteredUsers;
}
