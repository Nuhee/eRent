// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
  id: (json['id'] as num?)?.toInt() ?? 0,
  rentId: (json['rentId'] as num?)?.toInt(),
  stripePaymentIntentId: json['stripePaymentIntentId'] as String? ?? '',
  stripeCustomerId: json['stripeCustomerId'] as String?,
  amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
  currency: json['currency'] as String? ?? 'EUR',
  status: json['status'] as String? ?? 'pending',
  paymentMethod: json['paymentMethod'] as String?,
  customerName: json['customerName'] as String?,
  customerEmail: json['customerEmail'] as String?,
  billingAddress: json['billingAddress'] as String?,
  billingCity: json['billingCity'] as String?,
  billingState: json['billingState'] as String?,
  billingCountry: json['billingCountry'] as String?,
  billingZipCode: json['billingZipCode'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  propertyTitle: json['propertyTitle'] as String? ?? '',
  userId: (json['userId'] as num?)?.toInt(),
  userName: json['userName'] as String? ?? '',
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'id': instance.id,
  'rentId': instance.rentId,
  'stripePaymentIntentId': instance.stripePaymentIntentId,
  'stripeCustomerId': instance.stripeCustomerId,
  'amount': instance.amount,
  'currency': instance.currency,
  'status': instance.status,
  'paymentMethod': instance.paymentMethod,
  'customerName': instance.customerName,
  'customerEmail': instance.customerEmail,
  'billingAddress': instance.billingAddress,
  'billingCity': instance.billingCity,
  'billingState': instance.billingState,
  'billingCountry': instance.billingCountry,
  'billingZipCode': instance.billingZipCode,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'propertyTitle': instance.propertyTitle,
  'userId': instance.userId,
  'userName': instance.userName,
};
