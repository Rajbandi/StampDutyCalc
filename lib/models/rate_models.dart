class RateData {
  final String version;
  final String lastUpdated;
  final List<Country> countries;
  final Map<String, FieldDefinition> fieldDefinitions;

  RateData({
    required this.version,
    required this.lastUpdated,
    required this.countries,
    required this.fieldDefinitions,
  });

  factory RateData.fromJson(Map<String, dynamic> json) {
    return RateData(
      version: json['version'] ?? '',
      lastUpdated: json['lastUpdated'] ?? '',
      countries: (json['countries'] as List)
          .map((c) => Country.fromJson(c))
          .toList(),
      fieldDefinitions: (json['fieldDefinitions'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, FieldDefinition.fromJson(v))) ??
          {},
    );
  }
}

class Country {
  final String code;
  final String name;
  final String currency;
  final String currencySymbol;
  final String flag;
  final List<StateRegion> states;

  Country({
    required this.code,
    required this.name,
    required this.currency,
    required this.currencySymbol,
    required this.flag,
    required this.states,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      currency: json['currency'] ?? '',
      currencySymbol: json['currencySymbol'] ?? '\$',
      flag: json['flag'] ?? '',
      states: (json['states'] as List)
          .map((s) => StateRegion.fromJson(s))
          .toList(),
    );
  }
}

class StateRegion {
  final String code;
  final String name;
  final String? description;
  final List<String> vehicleFields;
  final List<RateRule> rates;

  StateRegion({
    required this.code,
    required this.name,
    this.description,
    required this.vehicleFields,
    required this.rates,
  });

  factory StateRegion.fromJson(Map<String, dynamic> json) {
    return StateRegion(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      vehicleFields: List<String>.from(json['vehicleFields'] ?? []),
      rates: (json['rates'] as List)
          .map((r) => RateRule.fromJson(r))
          .toList(),
    );
  }
}

class RateRule {
  final String? dateFrom;
  final String? dateTo;
  final Map<String, String> filters;
  final List<RateSlab> slabs;
  final Map<String, double>? additionalFees;

  RateRule({
    this.dateFrom,
    this.dateTo,
    required this.filters,
    required this.slabs,
    this.additionalFees,
  });

  // Known non-filter keys in the JSON
  static const _nonFilterKeys = {
    'dateFrom', 'dateTo', 'slabs', 'additionalFees',
  };

  factory RateRule.fromJson(Map<String, dynamic> json) {
    // Extract all string fields that aren't dates/slabs/fees as filters
    final filters = <String, String>{};
    for (final entry in json.entries) {
      if (_nonFilterKeys.contains(entry.key)) continue;
      if (entry.value is String) {
        filters[entry.key] = entry.value;
      }
    }

    return RateRule(
      dateFrom: json['dateFrom'],
      dateTo: json['dateTo'],
      filters: filters,
      slabs: (json['slabs'] as List)
          .map((s) => RateSlab.fromJson(s))
          .toList(),
      additionalFees: (json['additionalFees'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, (v as num).toDouble())),
    );
  }

  /// Check if this rule matches the user's selections.
  /// A filter value of "any" matches everything.
  bool matches(Map<String, String> selections) {
    for (final entry in filters.entries) {
      if (entry.value == 'any') continue;
      final sel = selections[entry.key];
      if (sel != null && sel != entry.value) return false;
    }
    return true;
  }
}

class RateSlab {
  final double min;
  final double? max;
  final double rate;
  final double per;
  final double? base;
  final double? chargeFrom;
  final bool graduated;
  final double? divisor;

  RateSlab({
    required this.min,
    this.max,
    required this.rate,
    required this.per,
    this.base,
    this.chargeFrom,
    this.graduated = false,
    this.divisor,
  });

  factory RateSlab.fromJson(Map<String, dynamic> json) {
    return RateSlab(
      min: (json['min'] as num).toDouble(),
      max: json['max'] != null ? (json['max'] as num).toDouble() : null,
      rate: (json['rate'] as num).toDouble(),
      per: (json['per'] as num?)?.toDouble() ?? 100,
      base: json['base'] != null ? (json['base'] as num).toDouble() : null,
      chargeFrom: json['chargeFrom'] != null
          ? (json['chargeFrom'] as num).toDouble()
          : null,
      graduated: json['graduated'] ?? false,
      divisor: json['divisor'] != null
          ? (json['divisor'] as num).toDouble()
          : null,
    );
  }
}

class FieldDefinition {
  final String label;
  final String type;
  final List<FieldOption> options;
  final Map<String, String>? showWhen;

  FieldDefinition({
    required this.label,
    required this.type,
    required this.options,
    this.showWhen,
  });

  factory FieldDefinition.fromJson(Map<String, dynamic> json) {
    return FieldDefinition(
      label: json['label'] ?? '',
      type: json['type'] ?? 'choice',
      options: (json['options'] as List?)
              ?.map((o) => FieldOption.fromJson(o))
              .toList() ??
          [],
      showWhen: (json['showWhen'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v.toString())),
    );
  }
}

class FieldOption {
  final String value;
  final String label;

  FieldOption({required this.value, required this.label});

  factory FieldOption.fromJson(Map<String, dynamic> json) {
    return FieldOption(
      value: json['value'] ?? '',
      label: json['label'] ?? '',
    );
  }
}
