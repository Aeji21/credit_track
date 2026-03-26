import 'dart:convert';

enum CreditType { owe, recv }
enum CreditStatus { overdue, upcoming, paid }

extension CreditStatusExt on CreditStatus {
  String get label {
    switch (this) {
      case CreditStatus.overdue:  return 'Overdue';
      case CreditStatus.upcoming: return 'Upcoming';
      case CreditStatus.paid:     return 'Paid';
    }
  }
}

extension CreditTypeExt on CreditType {
  String get label => this == CreditType.owe ? 'I Owe' : 'Owed to Me';
}

class Credit {
  final int id;
  String title;
  double amount;
  String person;
  CreditType type;
  CreditStatus status;
  DateTime? dueDate;

  Credit({
    required this.id,
    required this.title,
    required this.amount,
    required this.person,
    required this.type,
    required this.status,
    this.dueDate,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'amount': amount,
    'person': person,
    'type': type.index,
    'status': status.index,
    'dueDate': dueDate?.toIso8601String(),
  };

  factory Credit.fromMap(Map<String, dynamic> m) => Credit(
    id: m['id'],
    title: m['title'],
    amount: (m['amount'] as num).toDouble(),
    person: m['person'],
    type: CreditType.values[m['type']],
    status: CreditStatus.values[m['status']],
    dueDate: m['dueDate'] != null ? DateTime.parse(m['dueDate']) : null,
  );

  String toJson() => jsonEncode(toMap());
  factory Credit.fromJson(String src) => Credit.fromMap(jsonDecode(src));

  Credit copyWith({
    String? title,
    double? amount,
    String? person,
    CreditType? type,
    CreditStatus? status,
    DateTime? dueDate,
    bool clearDate = false,
  }) => Credit(
    id: id,
    title: title ?? this.title,
    amount: amount ?? this.amount,
    person: person ?? this.person,
    type: type ?? this.type,
    status: status ?? this.status,
    dueDate: clearDate ? null : (dueDate ?? this.dueDate),
  );
}
