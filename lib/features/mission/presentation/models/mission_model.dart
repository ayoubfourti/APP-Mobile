import 'package:flutter/material.dart';

enum MissionType   { search, rescue, recon }
enum MissionStatus { active, completed, aborted }

extension MissionTypeExt on MissionType {
  String get label {
    switch (this) {
      case MissionType.search: return 'RECHERCHE';
      case MissionType.rescue: return 'SAUVETAGE';
      case MissionType.recon:  return 'RECONNAISSANCE';
    }
  }
  String get emoji {
    switch (this) {
      case MissionType.search: return '🔍';
      case MissionType.rescue: return '🚑';
      case MissionType.recon:  return '🗺️';
    }
  }
  Color get color {
    switch (this) {
      case MissionType.search: return const Color(0xFF00E5FF);
      case MissionType.rescue: return const Color(0xFFFF6B6B);
      case MissionType.recon:  return const Color(0xFFFFD600);
    }
  }
  String get apiValue {
    switch (this) {
      case MissionType.search: return 'search';
      case MissionType.rescue: return 'rescue';
      case MissionType.recon:  return 'recon';
    }
  }
  static MissionType fromString(String v) {
    switch (v) {
      case 'rescue': return MissionType.rescue;
      case 'recon':  return MissionType.recon;
      default:       return MissionType.search;
    }
  }
}

extension MissionStatusExt on MissionStatus {
  String get label {
    switch (this) {
      case MissionStatus.active:    return 'ACTIVE';
      case MissionStatus.completed: return 'TERMINÉE';
      case MissionStatus.aborted:   return 'ANNULÉE';
    }
  }
  static MissionStatus fromString(String v) {
    switch (v) {
      case 'completed': return MissionStatus.completed;
      case 'aborted':   return MissionStatus.aborted;
      default:          return MissionStatus.active;
    }
  }
}

class MissionModel {
  final int    dbId;
  final String id;
  final String name;
  final String zone;
  final String place;
  final int?   operatorCin; // ✅ CIN de l'opérateur
  final MissionType   type;
  final MissionStatus status;
  final DateTime  startTime;
  final DateTime? endTime;
  final String?   note;

  const MissionModel({
    required this.dbId,
    required this.id,
    required this.name,
    required this.zone,
    required this.place,
    this.operatorCin,    // ✅
    required this.type,
    required this.status,
    required this.startTime,
    this.endTime,
    this.note,
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    final dbId = int.parse(json['idMission'].toString());
    final year = DateTime.now().year;
    final formatted = 'MSN-$year-${dbId.toString().padLeft(3, '0')}';

    return MissionModel(
      dbId:        dbId,
      id:          formatted,
      name:        json['titleMission'] as String,
      zone:        (json['zone']  as String?) ?? 'AUTO',
      place:       (json['place'] as String?) ?? 'AUTO',
      operatorCin: json['operatorCin'] == null ? null : int.parse(json['operatorCin'].toString()),
      type:        MissionTypeExt.fromString((json['type']   as String?) ?? 'search'),
      status:      MissionStatusExt.fromString((json['status'] as String?) ?? 'active'),
      startTime:   DateTime.parse(json['startTime'] as String),
      endTime:     json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
    );
  }

  String get duration {
    final end  = endTime ?? DateTime.now();
    final diff = end.difference(startTime);
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String get formattedDate =>
      '${startTime.day.toString().padLeft(2, '0')}/'
      '${startTime.month.toString().padLeft(2, '0')}/'
      '${startTime.year}';

  String get formattedTime =>
      '${startTime.hour.toString().padLeft(2, '0')}h'
      '${startTime.minute.toString().padLeft(2, '0')}';

  MissionModel copyWith({MissionStatus? status, DateTime? endTime}) {
    return MissionModel(
      dbId:        dbId,
      id:          id,
      name:        name,
      zone:        zone,
      place:       place,
      operatorCin: operatorCin, // ✅
      type:        type,
      status:      status ?? this.status,
      startTime:   startTime,
      endTime:     endTime ?? this.endTime,
      note:        note,
    );
  }
}