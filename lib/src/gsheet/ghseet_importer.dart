import 'dart:async';

import 'package:gsheet_to_arb/gsheet_to_arb.dart';

import 'package:gsheet_to_arb/src/translation_document.dart';

import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:uuid/uuid.dart';

class GSheetImporter {
  final PluginConfigRoot? config;

  GSheetImporter({
    this.config,
  });

  Future<TranslationsDocument> import(String documentId) async {
    Log.i('Importing ARB from Google sheet...');
    var authClient = await _getAuthClient(config!.auth);
    Log.startTimeTracking();
    var sheetsApi = SheetsApi(authClient!);
    var spreadsheet =
        await sheetsApi.spreadsheets.get(documentId, includeGridData: true);
    final document = await _importFrom(spreadsheet);
    authClient.close();

    Log.i('Loaded document ${document.describe()}');
    Log.i(
        'Importing ARB from Google sheet completed, took ${Log.stopTimeTracking()}');

    return document;
  }

  Future<AuthClient?> _getAuthClient(AuthConfig auth) async {
    final scopes = [SheetsApi.spreadsheetsReadonlyScope];
    AuthClient? authClient;
    if (auth.oauthClientId != null) {
      void clientAuthPrompt(String url) {
        Log.i(
            'Please go to the following URL and grant Google Spreadsheet access:\n$url\n');
      }

      final client = auth.oauthClientId;

      if (client == null) {
        throw Exception('Auth client config is invalid');
      }

      var id = ClientId(client.clientId, client.clientSecret);
      authClient = await clientViaUserConsent(id, scopes, clientAuthPrompt);
    } else if (auth.serviceAccountKey != null) {
      final service = auth.serviceAccountKey;
      var credentials = ServiceAccountCredentials(
        service!.clientEmail,
        ClientId(service.clientId, null),
        service.privateKey,
      );
      authClient = await clientViaServiceAccount(credentials, scopes);
    }
    return authClient;
  }

  Future<TranslationsDocument> _importFrom(Spreadsheet spreadsheet) async {
    final sheet = spreadsheet.sheets![config!.content!.gsheet!.sheetId!];
    final rows = sheet.data![0].rowData!;
    final header = rows[0];
    final headerValues = header.values!;

    final languages = <String?>[];
    final items = <TranslationRow>[];

    var firstLanguageColumn =
        config!.content!.gsheet!.sheetColumns!.first_language_key;
    var firstTranslationsRow =
        config!.content!.gsheet!.sheetRows!.first_translation_row;

    for (var column = firstLanguageColumn!;
        column < headerValues.length;
        column++) {
      //Stop parsing on first empty language code
      if (headerValues[column].formattedValue == null) {
        break;
      }
      final language = headerValues[column].formattedValue;
      languages.add(language);
    }

    // rows
    for (var i = firstTranslationsRow!; i < rows.length; i++) {
      var row = rows[i];
      var languages = row.values;

      //Skip empty rows
      if (languages == null) {
        continue;
      }

      var key =
          languages[config!.content!.gsheet!.sheetColumns!.key!].formattedValue;
      var category = languages[config!.content!.gsheet!.sheetColumns!.category!]
          .formattedValue;
      //Skip rows with missing key value
      if (key == null) {
        continue;
      }
      category ??= Uuid().v4().replaceAll('-', '');

      // if (key.startsWith(config.categoryPrefix)) {
      //   currentCategory = key.substring(config.categoryPrefix.length);
      //   continue;
      // }

      final description =
          languages[config!.content!.gsheet!.sheetColumns!.description!]
                  .formattedValue ??
              '';

      final values = row.values!
          .sublist(firstLanguageColumn, row.values!.length)
          .map((data) => data.formattedValue ?? '')
          .toList();

      final item = TranslationRow(
        key: key,
        category: category,
        description: description,
        values: values,
      );

      items.add(item);
    }

    final document = TranslationsDocument(
      lastModified: DateTime.now(),
      languages: languages,
      items: items,
    );
    return document;
  }
}
