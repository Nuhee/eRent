import 'package:json_annotation/json_annotation.dart';

part 'viewing_appointment.g.dart';

@JsonSerializable()
class ViewingAppointment {
  final int id;
  final int propertyId;
  final String propertyTitle;
  final String propertyAddress;
  final int tenantId;
  final String tenantName;
  final int landlordId;
  final DateTime appointmentDate;
  final DateTime endTime;
  final int status;
  final String statusName;
  final String? tenantNote;
  final String? landlordNote;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ViewingAppointment({
    this.id = 0,
    this.propertyId = 0,
    this.propertyTitle = '',
    this.propertyAddress = '',
    this.tenantId = 0,
    this.tenantName = '',
    this.landlordId = 0,
    required this.appointmentDate,
    required this.endTime,
    this.status = 0,
    this.statusName = '',
    this.tenantNote,
    this.landlordNote,
    required this.createdAt,
    this.updatedAt,
  });

  factory ViewingAppointment.fromJson(Map<String, dynamic> json) =>
      _$ViewingAppointmentFromJson(json);
  Map<String, dynamic> toJson() => _$ViewingAppointmentToJson(this);
}
