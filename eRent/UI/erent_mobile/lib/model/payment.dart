import 'package:json_annotation/json_annotation.dart';

part 'payment.g.dart';

@JsonSerializable()
class Payment {
  final int id;
  final int? rentId;
  final String stripePaymentIntentId;
  final String? stripeCustomerId;
  final double amount;
  final String currency;
  final String status;
  final String? paymentMethod;
  final String? customerName;
  final String? customerEmail;
  final String? billingAddress;
  final String? billingCity;
  final String? billingState;
  final String? billingCountry;
  final String? billingZipCode;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String propertyTitle;
  final int? userId;
  final String userName;

  const Payment({
    this.id = 0,
    this.rentId,
    this.stripePaymentIntentId = '',
    this.stripeCustomerId,
    this.amount = 0.0,
    this.currency = 'EUR',
    this.status = 'pending',
    this.paymentMethod,
    this.customerName,
    this.customerEmail,
    this.billingAddress,
    this.billingCity,
    this.billingState,
    this.billingCountry,
    this.billingZipCode,
    required this.createdAt,
    this.updatedAt,
    this.propertyTitle = '',
    this.userId,
    this.userName = '',
  });

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentToJson(this);

  /// Friendly status label
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'succeeded':
        return 'Paid';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      case 'canceled':
        return 'Cancelled';
      case 'refunded':
        return 'Refunded';
      default:
        return status;
    }
  }
}
