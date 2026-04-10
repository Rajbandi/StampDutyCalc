import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:stamp_duty_calc/models/rate_models.dart';
import 'package:stamp_duty_calc/models/calculation_result.dart';
import 'package:stamp_duty_calc/services/stamp_duty_calculator.dart';

late RateData rateData;
late Country au;

void main() {
  setUpAll(() {
    final jsonString = File('assets/rates/rates.json').readAsStringSync();
    rateData = RateData.fromJson(json.decode(jsonString));
    au = rateData.countries.firstWhere((c) => c.code == 'AU');
  });

  CalculationResult? calc(
    String stateCode,
    double price,
    Map<String, String> selections, {
    DateTime? date,
  }) {
    final state = au.states.firstWhere((s) => s.code == stateCode);
    return StampDutyCalculator.calculate(
      country: au,
      state: state,
      vehiclePrice: price,
      selections: selections,
      registrationDate: date ?? DateTime(2026, 1, 15),
    );
  }

  CalculationResult? calcOnRoad(
    String stateCode,
    double price,
    Map<String, String> selections, {
    double delivery = 0,
    bool fuelEfficient = false,
    bool isNew = true,
  }) {
    final state = au.states.firstWhere((s) => s.code == stateCode);
    return StampDutyCalculator.calculateOnRoad(
      country: au,
      state: state,
      vehiclePrice: price,
      selections: selections,
      registrationDate: DateTime(2026, 1, 15),
      dealerDelivery: delivery,
      isFuelEfficient: fuelEfficient,
      isNewVehicle: isNew,
      lct: rateData.luxuryCarTax,
    );
  }

  // ─── NSW ──────────────────────────────────────────────────────────
  group('NSW', () {
    test('passenger \$30,000 → \$900', () {
      final r = calc('NSW', 30000, {'vehicleType': 'passenger'});
      expect(r!.stampDuty, 900);
    });

    test('passenger \$60,000 → \$2,100', () {
      final r = calc('NSW', 60000, {'vehicleType': 'passenger'});
      expect(r!.stampDuty, 2100);
    });

    test('non-passenger \$80,000 → \$2,400', () {
      final r = calc('NSW', 80000, {'vehicleType': 'non-passenger'});
      expect(r!.stampDuty, 2400);
    });

    test('passenger at slab boundary \$45,000', () {
      final r = calc('NSW', 45000, {'vehicleType': 'passenger'});
      expect(r!.stampDuty, 1350);
    });
  });

  // ─── VIC ──────────────────────────────────────────────────────────
  group('VIC', () {
    test('standard car \$50,000 → \$2,100', () {
      final r = calc('VIC', 50000, {
        'vicVehicleType': 'car',
        'vicCarCategory': 'standard',
      });
      expect(r!.stampDuty, 2100);
    });

    test('standard car \$90,000 hits second tier', () {
      final r = calc('VIC', 90000, {
        'vicVehicleType': 'car',
        'vicCarCategory': 'standard',
      });
      expect(r!.stampDuty, 4680);
    });

    test('green car \$90,000 → flat rate (no luxury tiers)', () {
      final r = calc('VIC', 90000, {
        'vicVehicleType': 'car',
        'vicCarCategory': 'green',
      });
      // 450 * $8.40 = $3,780 (no luxury surcharge)
      expect(r!.stampDuty, 3780);
    });

    test('primary producer car \$90,000 → flat rate', () {
      final r = calc('VIC', 90000, {
        'vicVehicleType': 'car',
        'vicCarCategory': 'primary-producer',
      });
      expect(r!.stampDuty, 3780);
    });

    test('motorcycle \$15,000', () {
      final r = calc('VIC', 15000, {'vicVehicleType': 'motorcycle'});
      // 75 * $8.40 = $630
      expect(r!.stampDuty, 630);
    });

    test('trailer \$8,000', () {
      final r = calc('VIC', 8000, {'vicVehicleType': 'trailer'});
      // 40 * $8.40 = $336
      expect(r!.stampDuty, 336);
    });

    test('new non-passenger \$30,000', () {
      final r = calc('VIC', 30000, {'vicVehicleType': 'non-passenger-new'});
      expect(r!.stampDuty, 810);
    });

    test('used non-passenger \$30,000', () {
      final r = calc('VIC', 30000, {'vicVehicleType': 'non-passenger-used'});
      expect(r!.stampDuty, 1260);
    });
  });

  // ─── QLD ──────────────────────────────────────────────────────────
  group('QLD', () {
    test('light 4-cyl \$50,000 → \$1,500', () {
      final r = calc('QLD', 50000, {
        'qldVehicleType': 'light',
        'qldMotorType': '1-4cyl',
      });
      expect(r!.stampDuty, 1500);
    });

    test('light 4-cyl \$120,000 hits second tier', () {
      final r = calc('QLD', 120000, {
        'qldVehicleType': 'light',
        'qldMotorType': '1-4cyl',
      });
      expect(r!.stampDuty, 6000);
    });

    test('light electric \$80,000 → \$1,600', () {
      final r = calc('QLD', 80000, {
        'qldVehicleType': 'light',
        'qldMotorType': 'electric',
      });
      expect(r!.stampDuty, 1600);
    });

    test('heavy 4-cyl \$120,000 → flat \$3/100', () {
      final r = calc('QLD', 120000, {
        'qldVehicleType': 'heavy',
        'qldMotorType': '1-4cyl',
      });
      expect(r!.stampDuty, 3600);
    });

    test('special purpose → flat \$25', () {
      final r = calc('QLD', 999999, {'qldVehicleType': 'special'});
      expect(r!.stampDuty, 25);
    });
  });

  // ─── SA ───────────────────────────────────────────────────────────
  group('SA', () {
    test('non-commercial \$500 no fleet discount → \$10', () {
      final r = calc('SA', 500, {
        'vehicleUse': 'non-commercial',
        'saFleetDiscount': 'no',
      });
      expect(r!.stampDuty, 10);
    });

    test('non-commercial \$25,000 no fleet discount → \$940', () {
      final r = calc('SA', 25000, {
        'vehicleUse': 'non-commercial',
        'saFleetDiscount': 'no',
      });
      expect(r!.stampDuty, 940);
    });

    test('non-commercial \$25,000 with fleet discount → lower rate', () {
      final r = calc('SA', 25000, {
        'vehicleUse': 'non-commercial',
        'saFleetDiscount': 'yes',
      });
      // $60 base + (25000-3000)/100 * $3 = 60 + 660 = $720
      expect(r!.stampDuty, 720);
    });

    test('commercial \$25,000', () {
      final r = calc('SA', 25000, {
        'vehicleUse': 'commercial',
        'saFleetDiscount': 'no',
      });
      // $30 base + (25000-2000)/100 * $3 = 30 + 690 = $720
      expect(r!.stampDuty, 720);
    });
  });

  // ─── WA ───────────────────────────────────────────────────────────
  group('WA', () {
    test('light \$20,000 → 2.75%', () {
      final r = calc('WA', 20000, {'vehicleWeight': 'light'});
      expect(r!.stampDuty, 550);
    });
  });

  // ─── NT ───────────────────────────────────────────────────────────
  group('NT', () {
    test('standard \$40,000 → \$1,200', () {
      final r = calc('NT', 40000, {'ntVehicleType': 'standard'});
      expect(r!.stampDuty, 1200);
    });

    test('electric \$40,000 → \$0 (EV concession)', () {
      final r = calc('NT', 40000, {'ntVehicleType': 'electric'},
          date: DateTime(2026, 1, 1));
      expect(r!.stampDuty, 0);
    });

    test('electric \$70,000 → duty on amount above \$50k', () {
      final r = calc('NT', 70000, {'ntVehicleType': 'electric'},
          date: DateTime(2026, 1, 1));
      expect(r!.stampDuty, 600);
    });
  });

  // ─── TAS ──────────────────────────────────────────────────────────
  group('TAS', () {
    test('passenger \$300 → \$20 minimum', () {
      final r = calc('TAS', 300, {'tasVehicleType': 'passenger'});
      expect(r!.stampDuty, 20);
    });

    test('passenger \$20,000 → \$600', () {
      final r = calc('TAS', 20000, {'tasVehicleType': 'passenger'});
      expect(r!.stampDuty, 600);
    });

    test('caravan \$30,000 → \$920', () {
      final r = calc('TAS', 30000, {'tasVehicleType': 'caravan'});
      // $20 base + 300 * $3 = $920
      expect(r!.stampDuty, 920);
    });

    test('heavy vehicle \$50,000 → \$520', () {
      final r = calc('TAS', 50000, {'tasVehicleType': 'heavy'});
      expect(r!.stampDuty, 520);
    });
  });

  // ─── ACT new system (from Sep 2025) ───────────────────────────────
  group('ACT new system', () {
    test('new passenger AAA \$30,000', () {
      final r = calc('ACT', 30000, {
        'actVehicleType': 'passenger',
        'registrationType': 'new',
        'emissionsRating': 'AAA',
      }, date: DateTime(2025, 10, 1));
      expect(r!.stampDuty, 750);
    });

    test('new passenger D rating \$30,000', () {
      final r = calc('ACT', 30000, {
        'actVehicleType': 'passenger',
        'registrationType': 'new',
        'emissionsRating': 'D',
      }, date: DateTime(2025, 10, 1));
      expect(r!.stampDuty, 1359);
    });

    test('new passenger non-rated \$30,000', () {
      final r = calc('ACT', 30000, {
        'actVehicleType': 'passenger',
        'registrationType': 'new',
        'emissionsRating': 'non-rated',
      }, date: DateTime(2025, 10, 1));
      // C-rate equivalent: 300 * $3.17 = $951
      expect(r!.stampDuty, 951);
    });

    test('motorcycle new \$15,000', () {
      final r = calc('ACT', 15000, {
        'actVehicleType': 'motorcycle',
        'registrationType': 'new',
      }, date: DateTime(2025, 10, 1));
      // 150 * $3 = $450
      expect(r!.stampDuty, 450);
    });

    test('motorcycle used \$10,000', () {
      final r = calc('ACT', 10000, {
        'actVehicleType': 'motorcycle',
        'registrationType': 'used',
      }, date: DateTime(2025, 10, 1));
      // 100 * $3.17 = $317
      expect(r!.stampDuty, 317);
    });

    test('trailer \$5,000', () {
      final r = calc('ACT', 5000, {
        'actVehicleType': 'trailer',
      }, date: DateTime(2025, 10, 1));
      // 50 * $3.17 = $158.50
      expect(r!.stampDuty, 158.5);
    });

    test('other (truck) \$80,000', () {
      final r = calc('ACT', 80000, {
        'actVehicleType': 'other',
      }, date: DateTime(2025, 10, 1));
      // 800 * $3.17 = $2,536
      expect(r!.stampDuty, 2536);
    });
  });

  // ─── ACT old green rating (pre-Sep 2025) ──────────────────────────
  group('ACT old green rating', () {
    test('green rating A (5+ stars) → exempt', () {
      final r = calc('ACT', 60000, {
        'actVehicleType': 'passenger',
        'registrationType': 'new',
        'greenRating': 'A',
      }, date: DateTime(2025, 6, 1));
      expect(r!.stampDuty, 0);
    });

    test('green rating B \$30,000 → \$300', () {
      final r = calc('ACT', 30000, {
        'actVehicleType': 'passenger',
        'registrationType': 'new',
        'greenRating': 'B',
      }, date: DateTime(2025, 6, 1));
      expect(r!.stampDuty, 300);
    });

    test('green rating C \$60,000 → \$2,100', () {
      final r = calc('ACT', 60000, {
        'actVehicleType': 'passenger',
        'registrationType': 'new',
        'greenRating': 'C',
      }, date: DateTime(2025, 6, 1));
      expect(r!.stampDuty, 2100);
    });

    test('green rating D \$30,000 → \$1,200', () {
      final r = calc('ACT', 30000, {
        'actVehicleType': 'passenger',
        'registrationType': 'new',
        'greenRating': 'D',
      }, date: DateTime(2025, 6, 1));
      expect(r!.stampDuty, 1200);
    });

    test('used vehicle pre-Sep 2025 → \$3/100', () {
      final r = calc('ACT', 40000, {
        'actVehicleType': 'passenger',
        'registrationType': 'used',
      }, date: DateTime(2025, 6, 1));
      expect(r!.stampDuty, 1200);
    });
  });

  // ─── Luxury Car Tax ───────────────────────────────────────────────
  group('LCT', () {
    test('LCT on \$100,000 standard vehicle', () {
      final lct = rateData.luxuryCarTax!;
      final tax = lct.calculate(100000);
      expect(tax, closeTo(5830.10, 1.0));
    });

    test('no LCT below threshold', () {
      expect(rateData.luxuryCarTax!.calculate(70000), 0);
    });

    test('fuel-efficient uses higher threshold', () {
      final lct = rateData.luxuryCarTax!;
      expect(lct.calculate(85000, fuelEfficient: true), 0);
      expect(lct.calculate(85000, fuelEfficient: false), greaterThan(0));
    });
  });

  // ─── On-Road Mode ─────────────────────────────────────────────────
  group('On-Road', () {
    test('includes registration and CTP', () {
      final r = calcOnRoad('NSW', 30000, {'vehicleType': 'passenger'});
      expect(r!.isOnRoadMode, true);
      expect(r.registration, 462);
      expect(r.ctp, 630);
      expect(r.totalPayable, greaterThan(r.stampDuty));
    });

    test('includes dealer delivery when set', () {
      final r = calcOnRoad('NSW', 30000, {'vehicleType': 'passenger'},
          delivery: 1500);
      expect(r!.dealerDelivery, 1500);
      expect(r.breakdown.any((b) => b.description == 'Dealer delivery'), true);
    });

    test('LCT included for expensive new vehicle', () {
      final r = calcOnRoad('NSW', 100000, {'vehicleType': 'passenger'});
      expect(r!.luxuryCarTax, isNotNull);
      expect(r.luxuryCarTax!, greaterThan(0));
    });

    test('no LCT for used vehicle', () {
      final r = calcOnRoad('VIC', 100000, {
        'vicVehicleType': 'non-passenger-used',
      }, isNew: false);
      expect(r!.luxuryCarTax, isNull);
    });
  });

  // ─── Date matching ────────────────────────────────────────────────
  group('Date matching', () {
    test('NT EV concession expires after June 2027', () {
      final r = calc('NT', 40000, {'ntVehicleType': 'electric'},
          date: DateTime(2027, 7, 1));
      expect(r, isNull);
    });

    test('NT EV concession valid during period', () {
      final r = calc('NT', 40000, {'ntVehicleType': 'electric'},
          date: DateTime(2025, 1, 1));
      expect(r!.stampDuty, 0);
    });
  });

  // ─── Edge cases ───────────────────────────────────────────────────
  group('Edge cases', () {
    test('\$0 price', () {
      final r = calc('NSW', 0, {'vehicleType': 'passenger'});
      expect(r!.stampDuty, 0);
    });

    test('very large price', () {
      final r = calc('NSW', 5000000, {'vehicleType': 'passenger'});
      expect(r!.stampDuty, greaterThan(0));
    });
  });

  // ─── NZ ───────────────────────────────────────────────────────────
  group('NZ', () {
    test('petrol 1301-2600cc has zero stamp duty + licensing fee', () {
      final nz = rateData.countries.firstWhere((c) => c.code == 'NZ');
      final state = nz.states.first;
      final r = StampDutyCalculator.calculate(
        country: nz,
        state: state,
        vehiclePrice: 30000,
        selections: {'nzFuelType': 'petrol', 'nzEngineSize': '1301-2600cc'},
        registrationDate: DateTime(2026, 1, 1),
      );
      expect(r!.stampDuty, 0);
      expect(r.additionalFees['annualLicensingTotal'], 325.74);
      expect(r.totalPayable, 325.74);
    });
  });
}
