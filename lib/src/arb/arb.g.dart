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
      optionalParameters: json['optionalParameters'] == null
          ? null
          : OptionalParameters.fromJson(
              json['optionalParameters'] as Map<String, dynamic>),
    )..isCustomDateFormat = json['isCustomDateFormat'] as String?;

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
  writeNotNull('optionalParameters', instance.optionalParameters);
  writeNotNull('isCustomDateFormat', instance.isCustomDateFormat);
  return val;
}

OptionalParameters _$OptionalParametersFromJson(Map<String, dynamic> json) =>
    OptionalParameters(
      decimalDigits: json['decimalDigits'] as int?,
      name: json['name'] as String?,
      symbol: json['symbol'] as String?,
      customPattern: json['customPattern'] as String?,
    );

Map<String, dynamic> _$OptionalParametersToJson(OptionalParameters instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('decimalDigits', instance.decimalDigits);
  writeNotNull('name', instance.name);
  writeNotNull('symbol', instance.symbol);
  writeNotNull('customPattern', instance.customPattern);
  return val;
}
