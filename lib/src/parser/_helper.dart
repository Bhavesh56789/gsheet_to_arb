import 'package:gsheet_to_arb/src/arb/arb.dart';
import 'package:recase/recase.dart';

final _placeholderRegex = RegExp('\\{{(.+?)\\}}');

List<ArbResourcePlaceholder> findPlaceholders(
    String text, Map<String, dynamic>? types) {
  if (text.isEmpty) {
    return <ArbResourcePlaceholder>[];
  }

  var matches = _placeholderRegex.allMatches(text);
  var placeholders = <String, ArbResourcePlaceholder>{};
  matches.forEach((Match match) {
    var group = match.group(0)!;
    var diff = group.length - 2;
    String variableType = 'String';
    if (group.contains(',')) {
      diff = group.indexOf(',');
      variableType = group.substring(diff + 1, group.length - 2).trim();
    }
    var placeholderName = group.substring(2, diff).trim();

    if (placeholders.containsKey(placeholderName)) {
      throw Exception('Placeholder $placeholderName already declared');
    }
    var dataType;
    if (types != null && types.containsKey(variableType)) {
      dataType = types[variableType];
    }
    placeholders[placeholderName] = ArbResourcePlaceholder(
      name: placeholderName,
      type: variableType,
      dataType: dataType,
    );
  });
  return placeholders.values.toList();
}

String replacePlaceholders(String text) {
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

getContexedKey(bool? addContextPrefix, String _key, String? category) {
  final String key;
  if (addContextPrefix == true && category?.isNotEmpty == true) {
    key = ReCase(category ?? '' + '_' + _key).camelCase;
  } else {
    key = ReCase(_key).camelCase;
  }
  return key;
}
