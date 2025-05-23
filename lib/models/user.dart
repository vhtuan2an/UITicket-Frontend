class User {
  final String id;
  final String email;
  final String password;
  final String name;
  final String phone;
  final String avatar;
  final String university;
  final String faculty;
  final String major;
  final String studentId;
  final String gender;
  final String role;
  final List<String> eventsCreated;
  final List<String> ticketsBought;
  final bool isDeleted;

  User({
    required this.id,
    required this.email,
    this.password = '',
    required this.name,
    this.phone = '',
    this.avatar = '',
    this.university = '',
    this.faculty = '',
    this.major = '',
    this.studentId = '',
    this.gender = '',
    required this.role,
    this.eventsCreated = const [],
    this.ticketsBought = const [],
    this.isDeleted = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print('Parsing user JSON: $json'); // Debug log
    
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'] ?? '',
      university: json['university']?.toString() ?? '',
      faculty: json['faculty']?.toString() ?? '',
      major: json['major']?.toString() ?? '',
      studentId: json['studentId'] ?? '',
      gender: json['gender'] ?? '',
      role: json['role'] ?? '',
      // Xử lý eventsCreated - có thể là array objects hoặc array strings
      eventsCreated: _parseStringArray(json['eventsCreated']),
      // Xử lý ticketsBought - có thể là array objects hoặc array strings  
      ticketsBought: _parseStringArray(json['ticketsBought']),
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  // Phương thức helper để parse array có thể chứa objects hoặc strings
  static List<String> _parseStringArray(dynamic arrayData) {
    if (arrayData == null) return [];
    
    if (arrayData is List) {
      return arrayData.map((item) {
        if (item is String) {
          return item;
        } else if (item is Map<String, dynamic> && item.containsKey('_id')) {
          return item['_id'].toString();
        } else {
          return item.toString();
        }
      }).toList();
    }
    
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'avatar': avatar,
      'university': university,
      'faculty': faculty,
      'major': major,
      'studentId': studentId,
      'gender': gender,
      'role': role,
      'eventsCreated': eventsCreated,
      'ticketsBought': ticketsBought,
      'isDeleted': isDeleted,
    };
  }

  // Phương thức tiện ích để kiểm tra role
  bool get isAdmin => role == 'admin';
  bool get isEventCreator => role == 'event_creator';
  bool get isTicketBuyer => role == 'ticket_buyer';

  // Phương thức để tạo một bản sao của User với các thuộc tính được cập nhật
  User copyWith({
    String? id,
    String? email,
    String? password,
    String? name,
    String? phone,
    String? avatar,
    String? university,
    String? faculty,
    String? major,
    String? studentId,
    String? gender,
    String? role,
    List<String>? eventsCreated,
    List<String>? ticketsBought,
    bool? isDeleted,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      university: university ?? this.university,
      faculty: faculty ?? this.faculty,
      major: major ?? this.major,
      studentId: studentId ?? this.studentId,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      eventsCreated: eventsCreated ?? this.eventsCreated,
      ticketsBought: ticketsBought ?? this.ticketsBought,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}