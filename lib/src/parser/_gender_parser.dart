import 'package:gsheet_to_arb/src/arb/arb.dart';
import 'package:gsheet_to_arb/src/parser/_helper.dart';
import 'package:gsheet_to_arb/src/utils/log.dart';

enum GenderCase { male, female, other }

final _countPlaceHolder = ArbResourcePlaceholder(
  name: _genderPlaceholder,
  description: 'gender count',
  type: 'String',
);

class GenderParser {
  final bool? addContextPrefix;

  final _genderSeparator = '=';

  final _genderKeywords = {
    'male': GenderCase.male,
    'female': GenderCase.female,
    'other': GenderCase.other
  };

  GenderParser(this.addContextPrefix);
  final _arbResources = <ArbResource>[];
  final _genders = <Gender>[];

  consume(ArbResource resource) {
    _arbResources.add(resource);
  }

  List<ArbResource> compile() {
    for (ArbResource resource in _arbResources) {
      final genderCase = _getCase(resource.key!);
      if (genderCase == null) {
        Log.e('valid GenderCase is not present for key: ${resource.key}');
        continue;
      }
      final caseKey = _getCaseKey(resource.key!);
      _addToGenders(caseKey, genderCase, resource);
    }
    return _genders
        .map((e) => ArbResource(
              getContexedKey(addContextPrefix, e.key, e.resource.context),
              e.value,
              context: e.resource.context,
              description: e.resource.description,
              placeholders: [...e.resource.placeholders, _countPlaceHolder],
            ))
        .toList();
  }

  void _addToGenders(
    String key,
    GenderCase genderCase,
    ArbResource resource,
  ) {
    int index = _genders.indexWhere((genders) => genders.key == key);
    resource.addPlaceHolders([
      ...(index == -1 ? [] : _genders[index].resource.placeholders),
      ...resource.placeholders,
    ]);
    if (index == -1) {
      Gender gender = new Gender(key);
      gender.addGender(genderCase, resource.value);
      gender.addResource(resource);
      _genders.add(gender);
    } else {
      _genders[index].addGender(genderCase, resource.value);
      _genders[index].addResource(resource);
    }
  }

  GenderCase? _getCase(String key) {
    if (key.contains(_genderSeparator)) {
      for (var gender in _genderKeywords.keys) {
        if (key.endsWith('$_genderSeparator$gender')) {
          return _genderKeywords[gender];
        }
      }
    }
    return null;
  }

  String _getCaseKey(String key) {
    return key.substring(0, key.lastIndexOf(_genderSeparator));
  }
}

class Gender {
  final Map<GenderCase, String> values = {};
  final String key;
  late ArbResource resource;

  Gender(this.key);

  addGender(GenderCase genderCase, String value) {
    if (values[genderCase] != null) {
      Log.e('Duplicate gender case for key: $key and genderCase: $genderCase');
    }
    values[genderCase] = value;
  }

  addResource(ArbResource resource) {
    this.resource = resource;
  }

  get value {
    if (values[GenderCase.other] == null) {
      Log.e(
          'other case is not present for: $key and genderCase: ${GenderCase.other.name}');
    }
    if (values[GenderCase.male] == null) {
      Log.e(
          'male case is not present for: $key and genderCase: ${GenderCase.other.name}');
    }
    if (values[GenderCase.female] == null) {
      Log.e(
          'female case is not present for: $key and genderCase: ${GenderCase.other.name}');
    }
    return GendersFormatter.format(values);
  }
}

final String _genderPlaceholder = 'gender';

class GendersFormatter {
  static final _icuGenderFormats = {
    GenderCase.male: 'male',
    GenderCase.female: 'female',
    GenderCase.other: 'other'
  };

  static String format(Map<GenderCase, String> gender) {
    final builder = StringBuffer();
    builder.write('{$_genderPlaceholder, select,');
    gender.forEach((key, value) {
      if (value.isNotEmpty) {
        builder.write(' ${_icuGenderFormats[key]} {$value}');
      }
    });
    builder.write('}');
    return builder.toString();
  }
}
