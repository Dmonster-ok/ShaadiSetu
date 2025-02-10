import 'table_details.dart';

class UserModel {
  final int? id;
  final String? profileImage;
  final String firstName;
  final String lastName;
  final String address;
  final String city;
  final String cast;
  final String religion;
  final String profession;
  final String hobbies;
  final String email;
  final String phone;
  final int gender;
  final int favourite;
  final String birthdate;
  final String createdAt;
  late int age;

  UserModel({
    this.id,
    this.profileImage,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.city,
    required this.cast,
    required this.religion,
    required this.profession,
    required this.hobbies,
    required this.email,
    required this.phone,
    required this.gender,
    this.favourite = 0,
    required this.birthdate,
    required this.createdAt,
  }) {
    age = _calculateAge(birthdate);
  }
  static int _calculateAge(String birthdate) {
    DateTime birthDate = DateTime.parse(birthdate);
    DateTime today = DateTime.now();

    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Map<String, dynamic> toMap() {
    return {
      TableDetails.id: id,
      TableDetails.profileImage: profileImage,
      TableDetails.firstName: firstName,
      TableDetails.lastName: lastName,
      TableDetails.address: address,
      TableDetails.city: city,
      TableDetails.cast: cast,
      TableDetails.religion: religion,
      TableDetails.profession: profession,
      TableDetails.hobbies: hobbies,
      TableDetails.email: email,
      TableDetails.phone: phone,
      TableDetails.gender: gender,
      TableDetails.favourite: favourite,
      TableDetails.birthdate: birthdate,
      TableDetails.createdAt: createdAt,
      'age': age,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map[TableDetails.id],
      profileImage: map[TableDetails.profileImage],
      firstName: map[TableDetails.firstName],
      lastName: map[TableDetails.lastName],
      address: map[TableDetails.address],
      city: map[TableDetails.city],
      cast: map[TableDetails.cast],
      religion: map[TableDetails.religion],
      profession: map[TableDetails.profession],
      hobbies: map[TableDetails.hobbies],
      email: map[TableDetails.email],
      phone: map[TableDetails.phone],
      gender: map[TableDetails.gender],
      favourite: map[TableDetails.favourite],
      birthdate: map[TableDetails.birthdate],
      createdAt: map[TableDetails.createdAt],
    );
  }
}
