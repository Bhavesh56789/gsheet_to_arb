import 'package:gsheet_to_arb/src/parser/translation_parser.dart';
import 'package:gsheet_to_arb/src/utils/log.dart';

import 'arb/arb_serializer.dart';
import 'config/plugin_config.dart';
import 'gsheet/ghseet_importer.dart';

class GSheetToArb {
  final PluginConfigRoot? config;

  final _arbSerializer = ArbSerializer();

  GSheetToArb({this.config});

  void build() async {
    Log.i('Building translation...');
    Log.startTimeTracking();

    final documentId = config!.auth.documentId!;

    // import TranslationsDocument
    final importer = GSheetImporter(config: config);
    final document = await importer.import(documentId);

    // Parse TranslationsDocument to ArbBundle
    final sheetParser =
        TranslationParser(addContextPrefix: config!.content!.addContextPrefix);
    final arbBundle =
        await sheetParser.parseDocument(document, config?.dataTypes);

    // Save ArbBundle
    _arbSerializer.saveArbBundle(
      arbBundle,
      config!.content!.outputDirectoryPath!,
      config!.content!.arbFilePrefix!,
    );

    Log.i('Succeeded after ${Log.stopTimeTracking()}');
  }
}
