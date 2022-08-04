// ignore_for_file: prefer_single_quotes

/*
 * Copyright (c) 2020, Marek Gocał
 * All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

import 'dart:async';
import 'package:gsheet_to_arb/src/arb/arb.dart';
import 'package:gsheet_to_arb/src/translation_document.dart';
import 'package:gsheet_to_arb/src/utils/log.dart';

import 'package:quiver/iterables.dart' as iterables;
import 'package:recase/recase.dart';

import '_plurals_parser.dart';

class TranslationParser {
  final bool? addContextPrefix;

  TranslationParser({this.addContextPrefix});

  Future<ArbBundle> parseDocument(TranslationsDocument document) async {
    final builders = <ArbDocumentBuilder>[];
    final parsers = <PluralsParser>[];

    for (var langauge in document.languages!) {
      final builder = ArbDocumentBuilder(langauge, document.lastModified);
      final parser = PluralsParser(addContextPrefix);
      builders.add(builder);
      parsers.add(parser);
    }

    // for each row
    for (var item in document.items!) {
      // for each language
      for (var index in iterables.range(0, document.languages!.length)) {
        var itemValue;
        //incase value does not exist
        if (index < item.values!.length) {
          itemValue = item.values![index as int];
        } else {
          itemValue = '';
        }

        if (itemValue == '') {
          Log.i('WARNING: empty string in lang: ' +
              document.languages![index as int]! +
              ', key: ' +
              item.key!);
        }

        final itemPlaceholders = _findPlaceholders(itemValue);
        itemValue = _replacePlaceholders(itemValue);

        final builder = builders[index as int];
        final parser = parsers[index];

        // plural consume
        final status = parser.consume(ArbResource(
          item.key,
          itemValue,
          placeholders: itemPlaceholders,
          context: item.context,
          description: item.description,
        ));
        // TODO: THIS STATUS CHECK WON'T WORK IF THERE IS NO PLURAL FOR THE PARTICULAR DOCUMENT FORMAT
        if (status is Consumed) {
          continue;
        }

        if (status is Completed) {
          builder.add(status.resource);

          // next plural
          if (status.consumed) {
            continue;
          }
        }

        final key = addContextPrefix! && item.category!.isNotEmpty
            ? ReCase(item.category! + '_' + item.key!).camelCase
            : ReCase(item.key!).camelCase;

        // add resource
        builder.add(ArbResource(
          key,
          itemValue,
          context: item.category,
          description: item.description,
          placeholders: itemPlaceholders,
        ));
      }
    }

    // finalizer
    for (var index in iterables.range(0, document.languages!.length - 1)) {
      final builder = builders[index as int];
      final parser = parsers[index];
      final status = parser.complete();
      if (status is Completed) {
        builder.add(status.resource);
      }
    }

    // build all documents
    var documents = <ArbDocument>[];
    builders.forEach((builder) => documents.add(builder.build()));
    return ArbBundle(documents);
  }

  // TODO: VISIT THIS AND CHANGE THE IMPLEMENTATION of the same
  final _placeholderRegex = RegExp('\\{{(.+?)\\}}');

  List<ArbResourcePlaceholder> _findPlaceholders(String text) {
    if (text.isEmpty) {
      return <ArbResourcePlaceholder>[];
    }

    var matches = _placeholderRegex.allMatches(text);
    var placeholders = <String, ArbResourcePlaceholder>{};
    matches.forEach((Match match) {
      var group = match.group(0)!;
      var diff = group.length - 2;
      String variableType = 'string';
      if (group.contains(',')) {
        diff = group.indexOf(',');
        variableType = group.substring(diff + 1, group.length - 2).trim();
      }
      var placeholderName = group.substring(2, diff).trim();

      if (placeholders.containsKey(placeholderName)) {
        throw Exception('Placeholder $placeholderName already declared');
      }
      // TODO: This is now coming as a variable from the user
      placeholders[placeholderName] = ArbResourcePlaceholder(
        name: placeholderName,
        type: optionalParametersMap[variableType]!.type,
        optionalParameters:
            optionalParametersMap[variableType]?.optionalParameters,
        format: optionalParametersMap[variableType]?.format,
      );
    });
    return placeholders.values.toList();
  }

  String _replacePlaceholders(String text) {
    var matches = _placeholderRegex.allMatches(text);
    matches.forEach((Match match) {
      var group = match.group(0)!;
      var diff = group.length - 2;
      if (group.contains(',')) {
        diff = group.indexOf(',');
      }
      var placeholderName = group.substring(2, diff).trim();
      // ignore:  prefer_adjacent_string_concatenation
      text = text.replaceAll(group, '{$placeholderName}');
    });
    return text;
  }
}

// TODO: This should come from global config
Map<String, CleanOptionalParameters> optionalParametersMap = {
  'string': CleanOptionalParameters(type: 'String'),
  "int": CleanOptionalParameters(
    type: "int",
    format: "decimalPattern",
    optionalParameters: OptionalParameters(
      decimalDigits: 0,
    ),
  ),
  'num': CleanOptionalParameters(
    type: "num",
    format: "currency",
    optionalParameters: OptionalParameters(
      decimalDigits: 2,
      customPattern: "00",
    ),
  ),
  'date': CleanOptionalParameters(
    type: "DateTime",
    format: 'dd-MMM-yyyy',
  ),
  "money": CleanOptionalParameters(
    type: "num",
    format: "currency",
    optionalParameters: OptionalParameters(
      decimalDigits: 2,
      name: "INR",
      symbol: "₹",
      customPattern: "¤#0.00",
    ),
  ),
  "double": CleanOptionalParameters(
    type: "double",
    format: "currency",
    optionalParameters: OptionalParameters(
      decimalDigits: 2,
    ),
  )
};

class CleanOptionalParameters {
  final String type;
  final OptionalParameters? optionalParameters;
  final String? format;

  CleanOptionalParameters({
    this.format,
    required this.type,
    this.optionalParameters,
  });
}
