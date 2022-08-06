// ignore_for_file: prefer_single_quotes

/*
 * Copyright (c) 2020, Marek Gocał
 * All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

import 'dart:async';
import 'package:gsheet_to_arb/src/arb/arb.dart';
import 'package:gsheet_to_arb/src/parser/_gender_parser.dart';
import 'package:gsheet_to_arb/src/parser/_plurals_parser.dart';
import 'package:gsheet_to_arb/src/parser/_select_parser.dart';
import 'package:gsheet_to_arb/src/parser/_helper.dart';
import 'package:gsheet_to_arb/src/translation_document.dart';
import 'package:gsheet_to_arb/src/utils/log.dart';

import 'package:quiver/iterables.dart' as iterables;

class TranslationParser {
  final bool? addContextPrefix;

  TranslationParser({this.addContextPrefix});

  Future<ArbBundle> parseDocument(
    TranslationsDocument document,
    Map<String, dynamic>? types,
  ) async {
    final builders = <ArbDocumentBuilder>[];
    final pluralparsers = <PluralParser>[];
    final selectparsers = <SelectParser>[];
    final genderparsers = <GenderParser>[];

    for (var language in document.languages!) {
      final builder = ArbDocumentBuilder(language, document.lastModified);
      builders.add(builder);
      pluralparsers.add(PluralParser(addContextPrefix));
      selectparsers.add(SelectParser(addContextPrefix));
      genderparsers.add(GenderParser(addContextPrefix));
    }

    for (var index in iterables.range(0, document.languages!.length)) {
      final builder = builders[index as int];
      final pluralparser = pluralparsers[index];
      final selectParser = selectparsers[index];
      final genderParser = genderparsers[index];
      Log.i('Parsing language ${builder.locale}');
      for (var item in document.items!) {
        String itemValue;
        //incase value does not exist
        if (index < item.values!.length) {
          itemValue = item.values![index];
        } else {
          itemValue = '';
        }
        if (itemValue.isEmpty) {
          Log.i('WARNING: empty string in lang: ' +
              document.languages![index]! +
              ', key: ' +
              item.key!);
          continue;
        }
        final itemPlaceholders = findPlaceholders(itemValue, types);
        itemValue = replacePlaceholders(itemValue);

        if (item.category == 'plurals') {
          pluralparser.consume(ArbResource(
            item.key,
            itemValue,
            placeholders: itemPlaceholders,
            context: item.context,
            description: item.description,
          ));
        } else if (item.category == 'gender') {
          genderParser.consume(ArbResource(
            item.key,
            itemValue,
            placeholders: itemPlaceholders,
            context: item.context,
            description: item.description,
          ));
        } else if (item.category == 'select') {
          selectParser.consume(ArbResource(
            item.key,
            itemValue,
            placeholders: itemPlaceholders,
            context: item.context,
            description: item.description,
          ));
        } else {
          final key = getContexedKey(addContextPrefix, item.key!, item.context);
          builder.add(ArbResource(
            key,
            itemValue,
            placeholders: itemPlaceholders,
            context: item.context,
            description: item.description,
          ));
        }
      }
      pluralparser.compile().forEach((resource) {
        builder.add(resource);
      });
      selectParser.compile().forEach((resource) {
        builder.add(resource);
      });
      genderParser.compile().forEach((resource) {
        builder.add(resource);
      });
    }
    // build all documents
    var documents = <ArbDocument>[];
    builders.forEach((builder) => documents.add(builder.build()));
    return ArbBundle(documents);
  }
}
