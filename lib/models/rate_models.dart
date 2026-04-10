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
  final String? vehicleType;
  final String? registrationType;
  final String? qldCategory;
  final String? vehicleWeight;
  final String? vehicleUse;
  final String? greenRating;
  final String? fuelType;
  final List<RateSlab> slabs;
  final Map<String, double>? additionalFees;

  RateRule({
    this.dateFrom,
    this.dateTo,
    this.vehicleType,
    this.registrationType,
    this.qldCategory,
    this.vehicleWeight,
    this.vehicleUse,
    this.greenRating,
    this.fuelType,
    required this.slabs,
    this.additionalFees,
  });

  factory RateRule.fromJson(Map<String, dynamic> json) {
    return RateRule(
      dateFrom: json['dateFrom'],
      dateTo: json['dateTo'],
      vehicleType: json['vehicleType'],
      registrationType: json['registrationType'],
      qldCategory: json['qldCategory'],
      vehicleWeight: json['vehicleWeight'],
      vehicleUse: json['vehicleUse'],
      greenRating: json['greenRating'],
      fuelType: json['fuelType'],
      slabs: (json['slabs'] as List)
          .map((s) => RateSlab.fromJson(s))
          .toList(),
      additionalFees: (json['additionalFees'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, (v as num).toDouble())),
    );
  }

  bool matches(Map<String, String> selections) {
    if (vehicleType != null && vehicleType != 'any') {
      final sel = selections['vehicleType'];
      if (sel != null && sel != vehicleType) return false;
    }
    if (registrationType != null) {
      final sel = selections['registrationType'];
      if (sel != null && sel != registrationType) return false;
    }
    if (qldCategory != null) {
      final sel = selections['qldCategory'];
      if (sel != null && sel != qldCategory) return false;
    }
    if (vehicleWeight != null) {
      final sel = selections['vehicleWeight'];
      if (sel != null && sel != vehicleWeight) return false;
    }
    if (vehicleUse != null) {
      final sel = selections['vehicleUse'];
      if (sel != null && sel != vehicleUse) return false;
    }
    if (greenRating != null) {
      final sel = selections['greenRating'];
      if (sel != null && sel != greenRating) return false;
    }
    if (fuelType != null) {
      final sel = selections['fuelType'];
      if (sel != null && sel != fuelType) return false;
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
