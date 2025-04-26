class User {
  final String id;
  final String name;
  final String email;  
  final String position;
  final String staffNumber;
  final String role;
  final String? image;
  final String? createdAt;
  final String? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,    
    required this.position,
    required this.staffNumber,
    required this.role,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',      
      position: json['position'] ?? '',
      staffNumber: json['staffNumber'] ?? '',
      role: json['role'] ?? 'user',
      image: json['image'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['position'] = position;
    data['staffNumber'] = staffNumber;
    if (image != null) data['image'] = image;
    if (createdAt != null) data['createdAt'] = createdAt;
    if (updatedAt != null) data['updatedAt'] = updatedAt;
    data['role'] = role;
    return data;
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? position,
    String? staffNumber,
    String? role,
    String? image,
    String? createdAt,
    String? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      position: position ?? this.position,
      staffNumber: staffNumber ?? this.staffNumber,
      role: role ?? this.role,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
