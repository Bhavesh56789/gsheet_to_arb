/*
 * Copyright (c) 2020, Marek Gocał
 * All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

import 'package:json_annotation/json_annotation.dart';
part 'arb.g.dart';

class ArbDocument {
  String? locale;
  DateTime? lastModified;
  List<ArbResource>? entries;

  ArbDocument(this.locale, this.lastModified, this.entries);

  Map<String?, Object?> toJson({bool compact = false}) {
    final json = <String?, Object?>{};

    json['@@locale'] = locale;
    json['@@last_modified'] = lastModified!.toIso8601String();

    entries!.forEach((ArbResource resource) {
      json[resource.key] = resource.value;
      if (resource.attributes.isNotEmpty && !compact) {
        json['@${resource.key}'] = resource.attributes;
      }
    });

    return json;
  }

  ArbDocument.fromJson(Map<String, dynamic> _json) {
    var entriesMap = <String, ArbResource>{};
    entries = <ArbResource>[];

    _json.forEach((key, value) {
      if ('@@locale' == key) {
        locale = value;
      } else if ('@@last_modified' == key) {
        lastModified = DateTime.parse(value);
      } else if (key.startsWith('@')) {
        var entry = entriesMap[key.substring(2)]!;
        entry.attributes.addAll(value);
      } else {
        var entry = ArbResource(key, value);
        entries!.add(entry);
        entriesMap[key] = entry;
      }
    });
  }
}

class ArbResource {
  final String? key;
  final String value;
  final Map<String, Object> attributes = {};
  final List<ArbResourcePlaceholder> placeholders;
  final String? description;
  final String? context;

  ArbResource(
    String? key,
    String value, {
    this.description = '',
    this.context = '',
    this.placeholders = const [],
  })  : key = key,
        value = value {
    // Possible values are "text", "image", "css"
    attributes['type'] = 'text';

    if (placeholders.isNotEmpty) {
      attributes['placeholders'] = _formatPlaceholders(placeholders);
    }

    if (description != null && description!.isNotEmpty) {
      attributes['description'] = description!;
    }

    if (context != null && context!.isNotEmpty) {
      attributes['context'] = context!;
    }
  }

  addPlaceHolders(List<ArbResourcePlaceholder> placeholders) {
    for (ArbResourcePlaceholder placeholder in placeholders) {
      if (this
              .placeholders
              .indexWhere((element) => element.name == placeholder.name) ==
          -1) {
        this.placeholders.addAll(placeholders);
      }
    }
  }

  Map<String?, Object> _formatPlaceholders(
    List<ArbResourcePlaceholder> placeholders,
  ) {
    final map = <String?, Object>{};
    placeholders.forEach((placeholder) {
      final placeholderArgs = {
        ...placeholder.toJson(),
        ...(placeholder.dataType ?? {})
      };
      map[placeholder.name] = placeholderArgs;
    });
    return map;
  }
}

@JsonSerializable(includeIfNull: false)
class ArbResourcePlaceholder {
  final String name;
  final String? format;
  final String? example;
  final String? description;
  final String? type;

  @JsonKey(ignore: true)
  Map<String, dynamic>? dataType;

  ArbResourcePlaceholder({
    required this.name,
    this.type,
    this.description,
    this.format,
    this.example,
    this.dataType,
  });
  factory ArbResourcePlaceholder.fromJson(Map<String, dynamic> json) =>
      _$ArbResourcePlaceholderFromJson(json);

  Map<String, dynamic> toJson() => _$ArbResourcePlaceholderToJson(this);
  @override
  bool operator ==(other) {
    return this.name == (other as ArbResourcePlaceholder).name;
  }
}

class ArbBundle {
  final List<ArbDocument> documents;

  ArbBundle(this.documents);
}

class ArbDocumentBuilder {
  String? locale;
  DateTime? lastModified;
  List<ArbResource> entries = [];

  ArbDocumentBuilder(this.locale, this.lastModified);

  ArbDocument build() {
    final bundle = ArbDocument(locale, lastModified, entries);
    return bundle;
  }

  ArbDocumentBuilder add(ArbResource entry) {
    entries.add(entry);
    return this;
  }
}
