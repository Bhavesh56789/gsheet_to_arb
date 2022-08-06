import 'package:gsheet_to_arb/src/arb/arb.dart';
import 'package:gsheet_to_arb/src/parser/_helper.dart';
import 'package:gsheet_to_arb/src/utils/log.dart';

enum PluralCase { zero, one, two, few, many, other }

final _countPlaceHolder = ArbResourcePlaceholder(
  name: _countPlaceholder,
  description: 'plural count',
  type: 'num',
);

class PluralParser {
  final bool? addContextPrefix;

  final _pluralSeparator = '=';

  final _pluralKeywords = {
    'zero': PluralCase.zero,
    'one': PluralCase.one,
    'two': PluralCase.two,
    'few': PluralCase.few,
    'many': PluralCase.many,
    'other': PluralCase.other
  };
  PluralParser(this.addContextPrefix);
  final _arbResources = <ArbResource>[];
  final _plurals = <Plural>[];

  consume(ArbResource resource) {
    _arbResources.add(resource);
  }

  List<ArbResource> compile() {
    for (ArbResource resource in _arbResources) {
      final pluralCase = _getCase(resource.key!);
      if (pluralCase == null) {
        Log.e('valid PluralCase is not present for key: ${resource.key}');
        continue;
      }
      final caseKey = _getCaseKey(resource.key!);
      _addToPlurals(caseKey, pluralCase, resource);
    }
    return _plurals
        .map((e) => ArbResource(
              getContexedKey(addContextPrefix, e.key, e.resource.context),
              e.value,
              context: e.resource.context,
              description: e.resource.description,
              placeholders: [...e.resource.placeholders, _countPlaceHolder],
            ))
        .toList();
  }

  void _addToPlurals(
    String key,
    PluralCase pluralCase,
    ArbResource resource,
  ) {
    int index = _plurals.indexWhere((plurals) => plurals.key == key);
    resource.addPlaceHolders([
      ...(index == -1 ? [] : _plurals[index].resource.placeholders),
      ...resource.placeholders,
    ]);
    if (index == -1) {
      Plural plural = new Plural(key);
      plural.addPlural(pluralCase, resource.value);
      plural.addResource(resource);
      _plurals.add(plural);
    } else {
      _plurals[index].addPlural(pluralCase, resource.value);
      _plurals[index].addResource(resource);
    }
  }

  PluralCase? _getCase(String key) {
    if (key.contains(_pluralSeparator)) {
      for (var plural in _pluralKeywords.keys) {
        if (key.endsWith('$_pluralSeparator$plural')) {
          return _pluralKeywords[plural];
        }
      }
    }
    return null;
  }

  String _getCaseKey(String key) {
    return key.substring(0, key.lastIndexOf(_pluralSeparator));
  }
}

class Plural {
  final Map<PluralCase, String> values = {};
  final String key;
  late ArbResource resource;

  Plural(this.key);

  addPlural(PluralCase pluralCase, String value) {
    if (values[pluralCase] != null) {
      Log.e('Duplicate plural case for key: $key and pluralCase: $pluralCase');
    }
    values[pluralCase] = value;
  }

  addResource(ArbResource resource) {
    this.resource = resource;
  }

  get value {
    if (values[PluralCase.other] == null) {
      Log.e(
          'other case is not present for: $key and pluralCase: ${PluralCase.other.name}');
    }
    return PluralsFormatter.format(values);
  }
}

final String _countPlaceholder = 'count';

class PluralsFormatter {
  static final _icuPluralFormats = {
    PluralCase.zero: '=0',
    PluralCase.one: '=1',
    PluralCase.two: '=2',
    PluralCase.few: 'few',
    PluralCase.many: 'many',
    PluralCase.other: 'other'
  };

  static String format(Map<PluralCase, String> plural) {
    final builder = StringBuffer();
    builder.write('{$_countPlaceholder, plural,');
    plural.forEach((key, value) {
      if (value.isNotEmpty) {
        builder.write(' ${_icuPluralFormats[key]} {$value}');
      }
    });
    builder.write('}');
    return builder.toString();
  }
}
