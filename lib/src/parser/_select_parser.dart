import 'package:gsheet_to_arb/src/arb/arb.dart';
import 'package:gsheet_to_arb/src/parser/_helper.dart';
import 'package:gsheet_to_arb/src/utils/log.dart';

final _countPlaceHolder = ArbResourcePlaceholder(
  name: _selectPlaceholder,
  description: 'selector',
  type: 'String',
);

class SelectParser {
  final bool? addContextPrefix;

  final _selectSeparator = '=';

  SelectParser(this.addContextPrefix);
  final _arbResources = <ArbResource>[];
  final _selects = <Select>[];

  consume(ArbResource resource) {
    _arbResources.add(resource);
  }

  List<ArbResource> compile() {
    for (ArbResource resource in _arbResources) {
      final selectCase = _getCase(resource.key!);
      if (selectCase == null) {
        Log.e('valid SelectCase is not present for key: ${resource.key}');
        continue;
      }
      final caseKey = _getCaseKey(resource.key!);
      _addToSelects(caseKey, selectCase, resource);
    }
    return _selects
        .map((e) => ArbResource(
              getContexedKey(addContextPrefix, e.key, e.resource.context),
              e.value,
              context: e.resource.context,
              description: e.resource.description,
              placeholders: [...e.resource.placeholders, _countPlaceHolder],
            ))
        .toList();
  }

  void _addToSelects(
    String key,
    String selectCase,
    ArbResource resource,
  ) {
    int index = _selects.indexWhere((selects) => selects.key == key);
    resource.addPlaceHolders([
      ...(index == -1 ? [] : _selects[index].resource.placeholders),
      ...resource.placeholders,
    ]);
    if (index == -1) {
      Select select = new Select(key);
      select.addSelect(selectCase, resource.value);
      select.addResource(resource);
      _selects.add(select);
    } else {
      _selects[index].addSelect(selectCase, resource.value);
      _selects[index].addResource(resource);
    }
  }

  String? _getCase(String key) {
    if (key.contains(_selectSeparator)) {
      return key.split(_selectSeparator).last.trim();
    }
    return null;
  }

  String _getCaseKey(String key) {
    return key.substring(0, key.lastIndexOf(_selectSeparator));
  }
}

class Select {
  final Map<String, String> values = {};
  final String key;
  late ArbResource resource;

  Select(this.key);

  addSelect(String selectCase, String value) {
    if (values[selectCase] != null) {
      Log.e('Duplicate select case for key: $key and selectCase: $selectCase');
    }
    values[selectCase] = value;
  }

  addResource(ArbResource resource) {
    this.resource = resource;
  }

  get value {
    if (values['other'] == null) {
      Log.e('other case is not present for: $key and selectCase: other');
    }
    return SelectsFormatter.format(values);
  }
}

final String _selectPlaceholder = 'select';

class SelectsFormatter {
  static String format(Map<String, String> select) {
    final builder = StringBuffer();
    builder.write('{$_selectPlaceholder, select,');
    select.forEach((key, value) {
      if (value.isNotEmpty) {
        builder.write(' ${key} {$value}');
      }
    });
    builder.write('}');
    return builder.toString();
  }
}
