class User {
  final String prontuario;
  final String senha;
  String? name;
  String? email;
  String? photoPath; // can be set at runtime when user picks a photo
  String? phone;
  String? department;
  String? role;
  String? campus;
  DateTime? registrationDate;

  User({
    required this.prontuario,
    required this.senha,
    this.name,
    this.email,
    this.photoPath,
    this.phone,
    this.department,
    this.role,
    this.campus,
    this.registrationDate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      prontuario: json['prontuario'],
      senha: json['senha'],
      name: json['name'],
      email: json['email'],
      photoPath: json['photoPath'],
      phone: json['phone'],
      department: json['department'],
      role: json['role'],
      campus: json['campus'],
      registrationDate: json['registrationDate'] != null 
          ? DateTime.parse(json['registrationDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'prontuario': prontuario,
    'senha': senha,
    'name': name,
    'email': email,
    'photoPath': photoPath,
    'phone': phone,
    'department': department,
    'role': role,
    'campus': campus,
    'registrationDate': registrationDate?.toIso8601String(),
  };
}
