import 'table_details.dart';

class UserModel {
  final String? id;
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
  final String birthDate;
  final String createdAt;

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
    required this.birthDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap({bool includeId = false}) {
    final data = {
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
      TableDetails.birthdate: birthDate,
      TableDetails.createdAt: createdAt,
    };

    if (includeId && id != null) {
      data['id'] = id;
    }

    return data;
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
      favourite: map[TableDetails.favourite] ?? 0,
      birthDate: map[TableDetails.birthdate],
      createdAt: map[TableDetails.createdAt],
    );
  }
}
