// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plugin_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PluginConfigRoot _$PluginConfigRootFromJson(Map<String, dynamic> json) =>
    PluginConfigRoot(
      json['gsheet_to_arb'] == null
          ? null
          : GsheetToArbConfig.fromJson(
              json['gsheet_to_arb'] as Map<String, dynamic>),
      dataTypes: json['data_types'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PluginConfigRootToJson(PluginConfigRoot instance) =>
    <String, dynamic>{
      'gsheet_to_arb': instance.content,
      'data_types': instance.dataTypes,
    };

GsheetToArbConfig _$GsheetToArbConfigFromJson(Map<String, dynamic> json) =>
    GsheetToArbConfig(
      outputDirectoryPath: json['output_directory'] as String?,
      arbFilePrefix: json['arb_file_prefix'] as String?,
      gsheet: json['gsheet'] == null
          ? null
          : GoogleSheetConfig.fromJson(json['gsheet'] as Map<String, dynamic>),
      localizationFileName: json['localization_file_name'] as String?,
      generateCode: json['generate_code'] as bool?,
      addContextPrefix: json['add_context_prefix'] as bool?,
    );

Map<String, dynamic> _$GsheetToArbConfigToJson(GsheetToArbConfig instance) =>
    <String, dynamic>{
      'output_directory': instance.outputDirectoryPath,
      'arb_file_prefix': instance.arbFilePrefix,
      'localization_file_name': instance.localizationFileName,
      'generate_code': instance.generateCode,
      'add_context_prefix': instance.addContextPrefix,
      'gsheet': instance.gsheet,
    };

GoogleSheetConfig _$GoogleSheetConfigFromJson(Map<String, dynamic> json) =>
    GoogleSheetConfig(
      authFile: json['auth_file'] as String?,
      sheetId: json['sheet_id'] as int?,
      categoryPrefix: json['category_prefix'] as String?,
      sheetColumns: SheetColumns.generateFromJson(json['columns']),
      sheetRows: SheetRows.generateFromJson(json['rows']),
    );

Map<String, dynamic> _$GoogleSheetConfigToJson(GoogleSheetConfig instance) =>
    <String, dynamic>{
      'sheet_id': instance.sheetId,
      'category_prefix': instance.categoryPrefix,
      'auth_file': instance.authFile,
      'columns': instance.sheetColumns,
      'rows': instance.sheetRows,
    };

SheetColumns _$SheetColumnsFromJson(Map<String, dynamic> json) => SheetColumns(
      key: json['key'] as int? ?? DefaultSheetColumns.key,
      description:
          json['description'] as int? ?? DefaultSheetColumns.description,
      first_language_key: json['first_language_key'] as int? ??
          DefaultSheetColumns.first_language_key,
      category: json['category'] as int? ?? DefaultSheetColumns.category,
    );

Map<String, dynamic> _$SheetColumnsToJson(SheetColumns instance) =>
    <String, dynamic>{
      'key': instance.key,
      'description': instance.description,
      'first_language_key': instance.first_language_key,
      'category': instance.category,
    };

SheetRows _$SheetRowsFromJson(Map<String, dynamic> json) => SheetRows(
      header_row: json['header_row'] as int? ?? 0,
      first_translation_row: json['first_translation_row'] as int? ?? 1,
    );

Map<String, dynamic> _$SheetRowsToJson(SheetRows instance) => <String, dynamic>{
      'header_row': instance.header_row,
      'first_translation_row': instance.first_translation_row,
    };

AuthConfig _$AuthConfigFromJson(Map<String, dynamic> json) => AuthConfig(
      oauthClientId: json['oauth_client_id'] == null
          ? null
          : OAuthClientId.fromJson(
              json['oauth_client_id'] as Map<String, dynamic>),
      serviceAccountKey: json['service_account_key'] == null
          ? null
          : ServiceAccountKey.fromJson(
              json['service_account_key'] as Map<String, dynamic>),
      documentId: json['document_id'] as String?,
    );

Map<String, dynamic> _$AuthConfigToJson(AuthConfig instance) =>
    <String, dynamic>{
      'oauth_client_id': instance.oauthClientId,
      'service_account_key': instance.serviceAccountKey,
      'document_id': instance.documentId,
    };

OAuthClientId _$OAuthClientIdFromJson(Map<String, dynamic> json) =>
    OAuthClientId(
      clientId: json['client_id'] as String,
      clientSecret: json['client_secret'] as String,
    );

Map<String, dynamic> _$OAuthClientIdToJson(OAuthClientId instance) =>
    <String, dynamic>{
      'client_id': instance.clientId,
      'client_secret': instance.clientSecret,
    };

ServiceAccountKey _$ServiceAccountKeyFromJson(Map<String, dynamic> json) =>
    ServiceAccountKey(
      clientId: json['client_id'] as String,
      clientEmail: json['client_email'] as String,
      privateKey: json['private_key'] as String,
    );

Map<String, dynamic> _$ServiceAccountKeyToJson(ServiceAccountKey instance) =>
    <String, dynamic>{
      'client_id': instance.clientId,
      'client_email': instance.clientEmail,
      'private_key': instance.privateKey,
    };
