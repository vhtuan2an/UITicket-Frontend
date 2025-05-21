class Event {
  final String id;
  final String name;
  final List<String> images;
  final String description;
  final List<String> categoryId;
  final String location;
  final DateTime date;
  final double price;
  final String createdBy;
  final List<String> attendees;
  final List<String> collaborators;
  final int maxAttendees;
  final int ticketsSold;
  final String status;
  final String conservation;
  final bool isDeleted;

  Event({
    required this.id,
    required this.name,
    required this.images,
    this.description = '',
    this.categoryId = const [],
    required this.location,
    required this.date,
    this.price = 0.0,
    this.createdBy = '',
    this.attendees = const [],
    this.collaborators = const [],
    this.maxAttendees = 0,
    this.ticketsSold = 0,
    this.status = 'active',
    this.conservation = '',
    this.isDeleted = false,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      images: json['images'] != null 
          ? List<String>.from(json['images']) 
          : ['https://via.placeholder.com/150'],
      description: json['description'] ?? '',
      categoryId: json['categoryId'] != null 
          ? List<String>.from(json['categoryId']) 
          : [],
      location: json['location'] ?? '',
      date: json['date'] != null 
          ? DateTime.parse(json['date']) 
          : DateTime.now(),
      price: json['price']?.toDouble() ?? 0.0,
      createdBy: json['createdBy'] ?? '',
      attendees: json['attendees'] != null 
          ? List<String>.from(json['attendees']) 
          : [],
      collaborators: json['collaborators'] != null 
          ? List<String>.from(json['collaborators']) 
          : [],
      maxAttendees: json['maxAttendees'] ?? 0,
      ticketsSold: json['ticketsSold'] ?? 0,
      status: json['status'] ?? 'active',
      conservation: json['conservation'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}