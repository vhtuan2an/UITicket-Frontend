class Ticket {
  final String id;
  final String eventId;
  final String buyerId;
  final String bookingCode;
  final String qrCode;
  final String status; // "booked" | "cancelled" | "checked-in"
  final DateTime createdAt;
  final String cancelReason;
  final String paymentStatus; // "pending" | "paid" | "failed" | "transferring" | "transferred"
  final Map<String, dynamic> paymentData;
  final bool isDeleted;

  Ticket({
    required this.id,
    required this.eventId,
    required this.buyerId,
    required this.bookingCode,
    this.qrCode = '',
    this.status = 'booked',
    required this.createdAt,
    this.cancelReason = '',
    this.paymentStatus = 'pending',
    this.paymentData = const {},
    this.isDeleted = false,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    print('Parsing ticket JSON: $json'); // Debug log
    
    return Ticket(
      id: json['_id'] ?? json['id'] ?? '',
      eventId: json['eventId'] ?? '',
      buyerId: json['buyerId'] ?? '',
      bookingCode: json['bookingCode'] ?? '',
      qrCode: json['qrCode'] ?? '',
      status: json['status'] ?? 'booked',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      cancelReason: json['cancelReason'] ?? '',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      paymentData: json['paymentData'] is Map<String, dynamic>
          ? json['paymentData']
          : {},
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'eventId': eventId,
      'buyerId': buyerId,
      'bookingCode': bookingCode,
      'qrCode': qrCode,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'cancelReason': cancelReason,
      'paymentStatus': paymentStatus,
      'paymentData': paymentData,
      'isDeleted': isDeleted,
    };
  }

  // Phương thức tiện ích để kiểm tra trạng thái
  bool get isBooked => status == 'booked';
  bool get isCancelled => status == 'cancelled';
  bool get isCheckedIn => status == 'checked-in';
  
  // Phương thức tiện ích để kiểm tra payment status
  bool get isPending => paymentStatus == 'pending';
  bool get isPaid => paymentStatus == 'paid';
  bool get isFailed => paymentStatus == 'failed';
  bool get isTransferring => paymentStatus == 'transferring';
  bool get isTransferred => paymentStatus == 'transferred';

  // Phương thức để lấy màu sắc dựa trên status
  String get statusColor {
    switch (status) {
      case 'booked':
        return '#4CAF50'; // Green
      case 'cancelled':
        return '#F44336'; // Red
      case 'checked-in':
        return '#2196F3'; // Blue
      default:
        return '#9E9E9E'; // Grey
    }
  }

  // Phương thức để lấy màu sắc dựa trên payment status
  String get paymentStatusColor {
    switch (paymentStatus) {
      case 'paid':
        return '#4CAF50'; // Green
      case 'pending':
        return '#FF9800'; // Orange
      case 'failed':
        return '#F44336'; // Red
      case 'transferring':
        return '#2196F3'; // Blue
      case 'transferred':
        return '#9C27B0'; // Purple
      default:
        return '#9E9E9E'; // Grey
    }
  }

  // Phương thức để lấy text hiển thị cho status
  String get statusDisplayText {
    switch (status) {
      case 'booked':
        return 'Booked';
      case 'cancelled':
        return 'Cancelled';
      case 'checked-in':
        return 'Checked In';
      default:
        return 'Unknown';
    }
  }

  // Phương thức để lấy text hiển thị cho payment status
  String get paymentStatusDisplayText {
    switch (paymentStatus) {
      case 'pending':
        return 'Pending Payment';
      case 'paid':
        return 'Paid';
      case 'failed':
        return 'Payment Failed';
      case 'transferring':
        return 'Transferring';
      case 'transferred':
        return 'Transferred';
      default:
        return 'Unknown';
    }
  }

  // Phương thức để tạo một bản sao của Ticket với các thuộc tính được cập nhật
  Ticket copyWith({
    String? id,
    String? eventId,
    String? buyerId,
    String? bookingCode,
    String? qrCode,
    String? status,
    DateTime? createdAt,
    String? cancelReason,
    String? paymentStatus,
    Map<String, dynamic>? paymentData,
    bool? isDeleted,
  }) {
    return Ticket(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      buyerId: buyerId ?? this.buyerId,
      bookingCode: bookingCode ?? this.bookingCode,
      qrCode: qrCode ?? this.qrCode,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      cancelReason: cancelReason ?? this.cancelReason,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentData: paymentData ?? this.paymentData,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  String toString() {
    return 'Ticket(id: $id, bookingCode: $bookingCode, status: $status, paymentStatus: $paymentStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ticket && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}