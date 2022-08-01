import 'package:zodiac_i_ching/planets.dart';
import 'package:test_api/test_api.dart';

bool kindaSortaEqual(double value1, double value2, double tolerance) {
  if (value1.isInfinite || value2.isInfinite) {
    return value1 == value2;
  }

  if (value1.isNaN || value2.isNaN) {
    return false;
  }

  if (value1 > (value2 + tolerance)) {
    return false;
  }
  return !(value1 < (value2 - tolerance));
}

// INPUTS
const year = 2022;
const month = 7;
const day = 31;
const hour = 8;
const minute = 44;
const longitude = -112.2653190067936;
const latitude = 33.58238299981991;
const localSiderealTime = 192.32252224509193;
const oblique = 23.43804171005144;
const angle = [266.00167031046084, 193.392314254203];
// EXPECTED RESULTS
const julianDate = 2459790.92;
const sun = 127.25;
const moon = 145.94;
const mercury = 141.47;
const venus = 104.96;
const mars = 47.05;
const jupiter = 8.72;
const saturn = 323.02;
const uranus = 48.65;
const neptune = 355.18;
const pluto = 297.11;
const lunarNode = 48.93;
const apogee = 108.95;
const ascendant = 95.19;
const midHeaven = 348.05;

void main() {
  group('Planets', (() {
    test('Test julian date', () {
      var julianDateResult = calculateJulianDate(year, month, day, hour, minute);
      // [Log] testJD: 2459791.4888888886 (zodiac_i_ching, line 48)
      expect(kindaSortaEqual(2459791.4888888886, julianDateResult, 0.05), true);
      var correctedJulianDateResult = julianDateResult + correctTDT(julianDateResult);
      // [Log] testCorrectedJD: 2459791.4900193606 (zodiac_i_ching, line 50)
      expect(kindaSortaEqual(2459791.4900193606, correctedJulianDateResult, 0.05), true);
    });

    test('Test local sidereal time', () {
      var julianDateResult = calculateJulianDate(year, month, day, hour, minute);
      var localSiderealTimeResult = calculateLocalSiderealTime(julianDateResult, hour, minute, longitude);
      // [Log] testLST: 192.32252224509193 (zodiac_i_ching, line 49)
      expect(kindaSortaEqual(192.32252224509193, localSiderealTimeResult, 0.05), true);

      // Test again with corrected julian date
      julianDateResult += correctTDT(julianDateResult);
      localSiderealTimeResult = calculateLocalSiderealTime(julianDateResult, hour, minute, longitude);
      // [Log] testCorrectedLST: 192.73060637376375 (zodiac_i_ching, line 51)
      expect(kindaSortaEqual(192.73060637376375, localSiderealTimeResult, 0.05), true);
    });

    test('Test oblique', () {
      var julianDateResult = calculateJulianDate(year, month, day, hour, minute);
      var obliqueResult = calculateOblique(julianDateResult);
      // [Log] testObl: 23.438041692233575 (zodiac_i_ching, line 54)
      expect(kindaSortaEqual(23.438041692233575, obliqueResult, 0.05), true);

      // Test again with corrected julian date
      julianDateResult += correctTDT(julianDateResult);
      obliqueResult = calculateOblique(julianDateResult);
      // [Log] testCorrectedObl: 23.43804171005144 (zodiac_i_ching, line 55)
      expect(kindaSortaEqual(23.43804171005144, obliqueResult, 0.05), true);
    });

    test('Test angles', () {
      var julianDateResult = calculateJulianDate(year, month, day, hour, minute);
      var localSiderealTimeResult = calculateLocalSiderealTime(julianDateResult, hour, minute, longitude);
      var obliqueResult = calculateOblique(julianDateResult);
      var angleResult = calculateGeoPoint(localSiderealTimeResult, latitude, obliqueResult);
      // [Log] testAngle: 266.00167032305757, 193.39231425246254 (zodiac_i_ching, line 56)
      expect(kindaSortaEqual(266.00167032305757, angleResult[0], 0.05), true);
      expect(kindaSortaEqual(193.39231425246254, angleResult[1], 0.05), true);

      // Test again with corrected julian date
      julianDateResult += correctTDT(julianDateResult);
      localSiderealTimeResult = calculateLocalSiderealTime(julianDateResult, hour, minute, longitude);
      obliqueResult = calculateOblique(julianDateResult);
      angleResult = calculateGeoPoint(localSiderealTimeResult, latitude, obliqueResult);
      // [Log] testAngle: 266.36840725478174, 193.83319874906667 (zodiac_i_ching, line 56)
      expect(kindaSortaEqual(266.36840725478174, angleResult[0], 0.05), true);
      expect(kindaSortaEqual(193.83319874906667, angleResult[1], 0.05), true);
    });

    test('Test nutation', () {
      var julianDateResult = calculateJulianDate(year, month, day, hour, minute);
      var nutationResult = calculateNutation(julianDateResult);
      // [Log] testNutation: -11.187162703595416 (zodiac_i_ching, line 59)
      expect(kindaSortaEqual(-11.187162703595416, nutationResult, 0.05), true);

      // Test again with corrected julian date
      julianDateResult += correctTDT(julianDateResult);
      nutationResult = calculateNutation(julianDateResult);
      // [Log] testCorrectedNutation: -11.187223385942044 (zodiac_i_ching, line 60)
      expect(kindaSortaEqual(-11.187223385942044, nutationResult, 0.05), true);
    });

    test('Test planet positions', () {
      var positions = calculatePlanetPositions(year, month, day, hour, minute, longitude, latitude);
      expect(positions.length, 15);
      // 2459791.4900193606,127.79358311636943,152.83291343630646,142.49333150096354,105.64886362294301,47.415731176188494,8.716903609601014,322.9856668347187,48.67088713103135,355.17366076425736,297.0988984296245,48.830613363909116,111.38433993438571,266.00167031046084,193.392314254203
      expect(kindaSortaEqual(positions[julianDateIndex], 2459791.4900193606, 0.05), true);
      expect(kindaSortaEqual(positions[sunIndex], 127.79358311636943, 0.05), true);
      expect(kindaSortaEqual(positions[moonIndex], 152.83291343630646, 0.06), true);
      expect(kindaSortaEqual(positions[mercuryIndex], 142.49333150096354, 0.05), true);
      expect(kindaSortaEqual(positions[venusIndex], 105.64886362294301, 0.05), true);
      expect(kindaSortaEqual(positions[marsIndex], 47.415731176188494, 0.05), true);
      expect(kindaSortaEqual(positions[jupiterIndex], 8.716903609601014, 0.05), true);
      expect(kindaSortaEqual(positions[saturnIndex], 322.9856668347187, 0.05), true);
      expect(kindaSortaEqual(positions[uranusIndex], 48.67088713103135, 0.05), true);
      expect(kindaSortaEqual(positions[neptuneIndex], 355.17366076425736, 0.05), true);
      expect(kindaSortaEqual(positions[plutoIndex], 297.0988984296245, 0.05), true);
      expect(kindaSortaEqual(positions[lunarNodeIndex], 48.830613363909116, 0.05), true);
      expect(kindaSortaEqual(positions[apogeeLongitudeIndex], 111.38433993438571, 0.05), true);
      expect(kindaSortaEqual(positions[longitudeOfAscendantIndex], 266.00167031046084, 0.05), true);
      expect(kindaSortaEqual(positions[midHeavenIndex], 193.392314254203, 0.05), true);
    });
  }));
}
