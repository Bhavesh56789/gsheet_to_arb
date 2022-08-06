// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'arb.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArbResourcePlaceholder _$ArbResourcePlaceholderFromJson(
        Map<String, dynamic> json) =>
    ArbResourcePlaceholder(
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      format: json['format'] as String?,
      example: json['example'] as String?,
    );

Map<String, dynamic> _$ArbResourcePlaceholderToJson(
    ArbResourcePlaceholder instance) {
  final val = <String, dynamic>{
    'name': instance.name,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('format', instance.format);
  writeNotNull('example', instance.example);
  writeNotNull('description', instance.description);
  val['type'] = instance.type;
  return val;
}
