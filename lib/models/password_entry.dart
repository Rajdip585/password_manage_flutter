class PasswordEntry {
  int? id;
  String platform;
  String account;
  String password;
  String note;
  String lastUpdated;

  PasswordEntry({
    this.id,
    required this.platform,
    required this.account,
    required this.password,
    required this.note,
    required this.lastUpdated,
  });

  PasswordEntry copyWith({
    int? id,
    String? platform,
    String? account,
    String? password,
    String? note,
    String? lastUpdated,
  }) {
    return PasswordEntry(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      account: account ?? this.account,
      password: password ?? this.password,
      note: note ?? this.note,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'platform': platform,
      'account': account,
      'password': password,
      'note': note,
      'last_updated': lastUpdated,
    };
  }

  static PasswordEntry fromMap(Map<String, dynamic> map) {
    return PasswordEntry(
      id: map['id'],
      platform: map['platform'],
      account: map['account'],
      password: map['password'],
      note: map['note'],
      lastUpdated: map['last_updated'],
    );
  }
}
