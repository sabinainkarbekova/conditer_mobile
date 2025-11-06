// lib/models/payment_card.dart
class PaymentCard {
  final int id;
  final String cardholderName;
  final String cardNumber; // Это будет, например, "**** **** **** 1234"
  final String expiryDate;
  // final String securityCode; // ❌ Удалить
  final String cardType;
  final bool isDefault;

  PaymentCard({
    required this.id,
    required this.cardholderName,
    required this.cardNumber,
    required this.expiryDate,
    // required this.securityCode, // ❌ Удалить
    required this.cardType,
    required this.isDefault,
  });

  factory PaymentCard.fromJson(Map<String, dynamic> json) {
    return PaymentCard(
      id: json['id'] as int,
      cardholderName: json['cardholderName'] as String,
      cardNumber: json['cardNumber'] as String,
      expiryDate: json['expiryDate'] as String,
      // securityCode: json['securityCode'] as String, // ❌ Удалить
      cardType: json['cardType'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardholderName': cardholderName,
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      // 'securityCode': securityCode, // ❌ Удалить
      'cardType': cardType,
      'isDefault': isDefault,
    };
  }
}