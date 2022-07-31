import 'dart:math';

const julianDateIndex = 0;
const sunIndex = 1;
const moonIndex = 2;
const mercuryIndex = 3;
const venusIndex = 4;
const marsIndex = 5;
const jupiterIndex = 6;
const saturnIndex = 7;
const uranusIndex = 8;
const neptuneIndex = 9;
const plutoIndex = 10;
const lunarNodeIndex = 11;
const apogeeLongitudeIndex = 12;
const longitudeOfAscendantIndex = 13;
const midHeavenIndex = 14;

/*
* 0 Julian day
* 1-10 Planetary Position(Geocentric apparent ecliptic longitude): Sun, Moon, Mercury, Venus, Mars, Jupiter, Saturn, Uranus, Neptune, Pluto
* 11, 12 Lunar Node & apogee Longitude(from approximate osculate orbital elements)
* 13, 14 Longitude of Ascendant, MC(Mid heaven)
* All value is expressed in degree, without Julian day.
*/

List calculatePlanetPositions(
    year, month, day, hour, minute, longitude, latitude) {
/*
  ye 2022 
  mo 7
  da 30
  ho 19
  mi 6
  lon -112.26531900608147
  lat 33.582382999889354
  res 145.87773551196665,4.963475718020265
*/
  var julianDate = calculateJulianDate(year, month, day, hour, minute);
  var localSiderealTime =
      calculateLocalSiderealTime(julianDate, hour, minute, longitude);
  var planetPositions = List<double>.filled(15, 0.0);
  // Not used. DKL var date = year * 10000 + month * 100 + day * 1;

  julianDate += correctTDT(julianDate);
  // Not used. DKL
  // var coef = calculateTimeCoefficient(julianDate);
  // var d = coef[0];
  // var T = coef[1];

  planetPositions[julianDateIndex] = julianDate;

  for (var loop = sunIndex; loop <= plutoIndex; loop++) {
    planetPositions[loop] = calculatePlanetPosition(julianDate, loop);
  }

  var luna = calculatePositionOfLuna(julianDate);
  planetPositions[11] = luna[0];
  planetPositions[12] = luna[1];

  var obl = calculateOblique(julianDate);
  var angle = calculateGeoPoint(localSiderealTime, latitude, obl);
  planetPositions[13] = angle[0];
  planetPositions[14] = angle[1];

  var dpsi = calculateNutation(julianDate) / 3600.0;
  for (var loop = 1; loop <= 12; loop++) {
    planetPositions[loop] -= dpsi;
    if (planetPositions[loop] < 0.0) {
      planetPositions[loop] += 360.0;
    } else if (planetPositions[loop] >= 360.0) {
      planetPositions[loop] -= 360.0;
    }
  }
  return planetPositions;
}

double calculatePlanetPosition(julianDate, planetIndex) {
  var t = (julianDate - 2451545.0) / 36525.0;
  var t2 = (julianDate - 2451545.0) / 365250.0;

  var C = [
    0.00347,
    0.00484,
    0.00700,
    0.01298,
    0.01756,
    0.02490,
    0.03121,
    0.03461
  ];
  double dl;
  var epos = List<double>.filled(3, 0.0);
  var gpos = List<double>.filled(3, 0.0);
  var ppos = List<double>.filled(3, 0.0);

  epos = calculatePositionOfSun(t2);
  if (planetIndex == sunIndex) {
    gpos[0] = epos[0] - 0.005693 / epos[2];
  } else if (planetIndex == moonIndex) {
    gpos = calculatePositionOfMoon(t);
  } else {
    switch (planetIndex) {
      case mercuryIndex:
        ppos = calculatePositionOfMercury(t2);
        break;
      case venusIndex:
        ppos = calculatePositionOfVenus(t2);
        break;
      case marsIndex:
        ppos = calculatePositionOfMars(t2);
        break;
      case jupiterIndex:
        ppos = calculatePositionOfJupiter(t2);
        break;
      case saturnIndex:
        ppos = calculatePositionOfSaturn(t2);
        break;
      case uranusIndex:
        ppos = calculatePositionOfUranus(t2);
        break;
      case neptuneIndex:
        ppos = calculatePositionOfNeptune(t2);
        break;
      case plutoIndex:
        if (-1.15 <= t && t < 1.0) {
          // Pluto_mee valids thru 1885-2099
          ppos = calculatePositionOfPlutoMee(t);
        } else {
          // Pluto_obspm valids thru -3000 - 3000, but intentionally uses to 0 - 4000
          ppos = calculatePositionOfPlutoObspm(t);
        }
        ppos[0] += 5029.0966 / 3600.0 * t; // ���^�ߎ��̍΍��␳����
        break;
    }
    gpos = convertGeocentric(epos, ppos);
    dl = -0.005693 * cos((gpos[0] - epos[0]) * pi / 180.0);
    dl -= C[planetIndex - 3] * cos((gpos[0] - ppos[0]) * pi / 180.0) / ppos[2];
    gpos[0] += dl;
  }

  return gpos[0];
}

List<double> calculatePositionOfMoon(T) {
  var mf = List<double>.filled(4, 0.0);
  double dl, db;

  // Mean Longitude of the Moon(J2000.0)
  var w1 = 481266.0 * T;
  w1 = mod360(w1);
  w1 += 0.48437 * T;
  w1 -= 0.00163 * T * T;
  w1 += 218.31665;
  w1 = mod360(w1);

  // D : Mean elongation of the Moon
  mf[0] = 445267.0 * T;
  mf[0] = mod360(mf[0]);
  mf[0] += 0.11151 * T;
  mf[0] -= 0.00163 * T * T;
  mf[0] += 297.85020;
  mf[0] = mod360(mf[0]);

  // l' : Mean anomary of the Sun
  mf[1] = 35999.0 * T;
  mf[1] = mod360(mf[1]);
  mf[1] += 0.05029 * T;
  mf[1] -= 0.00015 * T * T;
  mf[1] += 357.51687;
  mf[1] = mod360(mf[1]);

  // l : Mean anomary of the Moon
  mf[2] = 477198.0 * T;
  mf[2] = mod360(mf[2]);
  mf[2] += 0.86763 * T;
  mf[2] += 0.008997 * T * T;
  mf[2] += 134.96341;
  mf[2] = mod360(mf[2]);

  // F : Argument of latitude of the Moon
  mf[3] = 483202.0 * T;
  mf[3] = mod360(mf[3]);
  mf[3] += 0.01753 * T;
  mf[3] -= 0.00340 * T * T;
  mf[3] += 93.27210;
  mf[3] = mod360(mf[3]);

  dl = 6.28876 * sin4deg(0 * mf[0] + 0 * mf[1] + 1 * mf[2] + 0 * mf[3]);
  dl += 1.27401 * sin4deg(2 * mf[0] + 0 * mf[1] - 1 * mf[2] + 0 * mf[3]);
  dl += 0.65831 * sin4deg(2 * mf[0] + 0 * mf[1] + 0 * mf[2] + 0 * mf[3]);
  dl += 0.21362 * sin4deg(0 * mf[0] + 0 * mf[1] + 2 * mf[2] + 0 * mf[3]);
  dl += -0.18512 * sin4deg(0 * mf[0] + 1 * mf[1] + 0 * mf[2] + 0 * mf[3]);
  dl += -0.11433 * sin4deg(0 * mf[0] + 0 * mf[1] + 0 * mf[2] + 2 * mf[3]);
  dl += 0.05879 * sin4deg(2 * mf[0] + 0 * mf[1] - 2 * mf[2] + 0 * mf[3]);
  dl += 0.05707 * sin4deg(2 * mf[0] - 1 * mf[1] - 1 * mf[2] + 0 * mf[3]);
  dl += 0.05332 * sin4deg(2 * mf[0] + 0 * mf[1] + 1 * mf[2] + 0 * mf[3]);
  dl += 0.04576 * sin4deg(2 * mf[0] - 1 * mf[1] + 0 * mf[2] + 0 * mf[3]);
  dl += -0.04092 * sin4deg(0 * mf[0] + 1 * mf[1] - 1 * mf[2] + 0 * mf[3]);
  dl += -0.03472 * sin4deg(1 * mf[0] + 0 * mf[1] + 0 * mf[2] + 0 * mf[3]);
  dl += -0.03038 * sin4deg(0 * mf[0] + 1 * mf[1] + 1 * mf[2] + 0 * mf[3]);
  dl += 0.01533 * sin4deg(2 * mf[0] + 0 * mf[1] + 0 * mf[2] - 2 * mf[3]);
  dl += -0.01253 * sin4deg(0 * mf[0] + 0 * mf[1] + 1 * mf[2] + 2 * mf[3]);
  dl += 0.01098 * sin4deg(0 * mf[0] + 0 * mf[1] + 1 * mf[2] - 2 * mf[3]);
  dl += 0.01067 * sin4deg(4 * mf[0] + 0 * mf[1] - 1 * mf[2] + 0 * mf[3]);
  dl += 0.01003 * sin4deg(0 * mf[0] + 0 * mf[1] + 3 * mf[2] + 0 * mf[3]);
  dl += 0.00855 * sin4deg(4 * mf[0] + 0 * mf[1] - 2 * mf[2] + 0 * mf[3]);

  db = 5.12817 * sin4deg(0 * mf[0] + 0 * mf[1] + 0 * mf[2] + 1 * mf[3]);
  db += 0.27769 * sin4deg(0 * mf[0] + 0 * mf[1] + 1 * mf[2] - 1 * mf[3]);
  db += 0.28060 * sin4deg(0 * mf[0] + 0 * mf[1] + 1 * mf[2] + 1 * mf[3]);
  db += 0.00882 * sin4deg(0 * mf[0] + 0 * mf[1] + 2 * mf[2] - 1 * mf[3]);
  db += 0.01720 * sin4deg(0 * mf[0] + 0 * mf[1] + 2 * mf[2] + 1 * mf[3]);
  db += 0.04627 * sin4deg(2 * mf[0] + 0 * mf[1] - 1 * mf[2] - 1 * mf[3]);
  db += 0.05541 * sin4deg(2 * mf[0] + 0 * mf[1] - 1 * mf[2] + 1 * mf[3]);
  db += 0.17324 * sin4deg(2 * mf[0] + 0 * mf[1] + 0 * mf[2] - 1 * mf[3]);
  db += 0.03257 * sin4deg(2 * mf[0] + 0 * mf[1] + 0 * mf[2] + 1 * mf[3]);
  db += 0.00927 * sin4deg(2 * mf[0] + 0 * mf[1] + 1 * mf[2] - 1 * mf[3]);

  w1 += dl + 5029.0966 / 3600.0 * T;

  var res = [w1, db];
  return res;
}

List<double> calculatePositionOfMercury(T) {
  var lo = 0.0;
  var bo = 0.0;
  var ro = 0.0;
  var longitude = List<double>.filled(3, 0.0);
  var latitude = List<double>.filled(3, 0.0);
  var radius = List<double>.filled(2, 0.0);

  // Mercury's Longitude
  longitude[0] = 4.40251 * cos(0.00000 + 0.00000 * T);
  longitude[0] += 0.40989 * cos(1.48302 + 26087.90314 * T);
  longitude[0] += 0.05046 * cos(4.47785 + 52175.80628 * T);
  longitude[0] += 0.00855 * cos(1.16520 + 78263.70942 * T);
  longitude[0] += 0.00166 * cos(4.11969 + 104351.61257 * T);
  longitude[0] += 0.00035 * cos(0.77931 + 130439.51571 * T);
  longitude[1] = 26088.14706 * cos(0.00000 + 0.00000 * T);
  longitude[1] += 0.01126 * cos(6.21704 + 26087.90314 * T);
  longitude[1] += 0.00303 * cos(3.05565 + 52175.80628 * T);
  longitude[1] += 0.00081 * cos(6.10455 + 78263.70942 * T);
  longitude[1] += 0.00021 * cos(2.83532 + 104351.61257 * T);
  longitude[2] = 0.00053 * cos(0.00000 + 0.00000 * T);
  longitude[2] += 0.00017 * cos(4.69072 + 26087.90314 * T);
  // Mercury's Latitude
  latitude[0] = 0.11738 * cos(1.98357 + 26087.90314 * T);
  latitude[0] += 0.02388 * cos(5.03739 + 52175.80628 * T);
  latitude[0] += 0.01223 * cos(3.14159 + 0.00000 * T);
  latitude[0] += 0.00543 * cos(1.79644 + 78263.70942 * T);
  latitude[0] += 0.00130 * cos(4.83233 + 104351.61257 * T);
  latitude[0] += 0.00032 * cos(1.58088 + 130439.51571 * T);
  latitude[1] = 0.00429 * cos(3.50170 + 26087.90314 * T);
  latitude[1] += 0.00146 * cos(3.14159 + 0.00000 * T);
  latitude[1] += 0.00023 * cos(0.01515 + 52175.80628 * T);
  latitude[1] += 0.00011 * cos(0.48540 + 78263.70942 * T);
  latitude[2] = 0.00012 * cos(4.79066 + 26087.90314 * T);
  // Mercury's Radius Vector
  radius[0] = 0.39528 * cos(0.00000 + 0.00000 * T);
  radius[0] += 0.07834 * cos(6.19234 + 26087.90314 * T);
  radius[0] += 0.00796 * cos(2.95990 + 52175.80628 * T);
  radius[0] += 0.00121 * cos(6.01064 + 78263.70942 * T);
  radius[0] += 0.00022 * cos(2.77820 + 104351.61257 * T);
  radius[1] = 0.00217 * cos(4.65617 + 26087.90314 * T);
  radius[1] += 0.00044 * cos(1.42386 + 52175.80628 * T);
  radius[1] += 0.00010 * cos(4.47466 + 78263.70942 * T);

  lo = mod360(calculateVsopTerm(T, longitude) / degreesToRadians);
  bo = calculateVsopTerm(T, latitude) / degreesToRadians;
  ro = calculateVsopTerm(T, radius);

  var res = [lo, bo, ro];
  return res;
}

List<double> calculatePositionOfVenus(T) {
  var lo = 0.0;
  var bo = 0.0;
  var ro = 0.0;
  var longitudeVector = List<double>.filled(3, 0.0);
  var latitudeVector = List<double>.filled(3, 0.0);
  var radiusVector = List<double>.filled(2, 0.0);

  // Venus's Longitude
  longitudeVector[0] = 3.17615 * cos(0.00000 + 0.00000 * T);
  longitudeVector[0] += 0.01354 * cos(5.59313 + 10213.28555 * T);
  longitudeVector[0] += 0.00090 * cos(5.30650 + 20426.57109 * T);
  longitudeVector[1] = 10213.52943 * cos(0.00000 + 0.00000 * T);
  longitudeVector[1] += 0.00096 * cos(2.46424 + 10213.28555 * T);
  longitudeVector[1] += 0.00014 * cos(0.51625 + 20426.57109 * T);
  longitudeVector[2] = 0.00054 * cos(0.00000 + 0.00000 * T);
  // Venus's Latitude
  latitudeVector[0] = 0.05924 * cos(0.26703 + 10213.28555 * T);
  latitudeVector[0] += 0.00040 * cos(1.14737 + 20426.57109 * T);
  latitudeVector[0] += 0.00033 * cos(3.14159 + 0.00000 * T);
  latitudeVector[1] = 0.00513 * cos(1.80364 + 10213.28555 * T);
  latitudeVector[2] = 0.00022 * cos(3.38509 + 10213.28555 * T);
  // Venus's Radius Vector
  radiusVector[0] = 0.72335 * cos(0.00000 + 0.00000 * T);
  radiusVector[0] += 0.00490 * cos(4.02152 + 10213.28555 * T);
  radiusVector[1] = 0.00035 * cos(0.89199 + 10213.28555 * T);

  lo = mod360(calculateVsopTerm(T, longitudeVector) / degreesToRadians);
  bo = calculateVsopTerm(T, latitudeVector) / degreesToRadians;
  ro = calculateVsopTerm(T, radiusVector);

  var res = [lo, bo, ro];
  return res;
}

List<double> calculatePositionOfMars(T) {
  var lo = 0.0;
  var bo = 0.0;
  var ro = 0.0;
  var longitude = List<double>.filled(3, 0.0);
  var latitude = List<double>.filled(3, 0.0);
  var radius = List<double>.filled(3, 0.0);

  // Mars's Longitude
  longitude[0] = 6.20348 * cos(0.00000 + 0.00000 * T);
  longitude[0] += 0.18656 * cos(5.05037 + 3340.61243 * T);
  longitude[0] += 0.01108 * cos(5.40100 + 6681.22485 * T);
  longitude[0] += 0.00092 * cos(5.75479 + 10021.83728 * T);
  longitude[0] += 0.00028 * cos(5.97050 + 3.52312 * T);
  longitude[0] += 0.00011 * cos(2.93959 + 2281.23050 * T);
  longitude[0] += 0.00012 * cos(0.84956 + 2810.92146 * T);
  longitude[1] = 3340.85627 * cos(0.00000 + 0.00000 * T);
  longitude[1] += 0.01458 * cos(3.60426 + 3340.61243 * T);
  longitude[1] += 0.00165 * cos(3.92631 + 6681.22485 * T);
  longitude[1] += 0.00020 * cos(4.26594 + 10021.83728 * T);
  longitude[2] = 0.00058 * cos(2.04979 + 3340.61243 * T);
  longitude[2] += 0.00054 * cos(0.00000 + 0.00000 * T);
  longitude[2] += 0.00014 * cos(2.45742 + 6681.22485 * T);
  // Mars's Latitude
  latitude[0] = 0.03197 * cos(3.76832 + 3340.61243 * T);
  latitude[0] += 0.00298 * cos(4.10617 + 6681.22485 * T);
  latitude[0] += 0.00289 * cos(0.00000 + 0.00000 * T);
  latitude[0] += 0.00031 * cos(4.44651 + 10021.83728 * T);
  latitude[1] = 0.00350 * cos(5.36848 + 3340.61243 * T);
  latitude[1] += 0.00014 * cos(3.14159 + 0.00000 * T);
  latitude[1] += 0.00010 * cos(5.47878 + 6681.22485 * T);
  latitude[2] = 0.00017 * cos(0.60221 + 3340.61243 * T);
  // Mars's Radius Vector
  radius[0] = 1.53033 * cos(0.00000 + 0.00000 * T);
  radius[0] += 0.14185 * cos(3.47971 + 3340.61243 * T);
  radius[0] += 0.00661 * cos(3.81783 + 6681.22485 * T);
  radius[0] += 0.00046 * cos(4.15595 + 10021.83728 * T);
  radius[1] = 0.01107 * cos(2.03251 + 3340.61243 * T);
  radius[1] += 0.00103 * cos(2.37072 + 6681.22485 * T);
  radius[1] += 0.00013 * cos(0.00000 + 0.00000 * T);
  radius[1] += 0.00011 * cos(2.70888 + 10021.83728 * T);
  radius[2] = 0.00044 * cos(0.47931 + 3340.61243 * T);

  lo = mod360(calculateVsopTerm(T, longitude) / degreesToRadians);
  bo = calculateVsopTerm(T, latitude) / degreesToRadians;
  ro = calculateVsopTerm(T, radius);

  var res = [lo, bo, ro];
  return res;
}

List<double> calculatePositionOfJupiter(T) {
  var lo = 0.0;
  var bo = 0.0;
  var ro = 0.0;
  var longitude = List<double>.filled(3, 0.0);
  var latitude = List<double>.filled(2, 0.0);
  var radius = List<double>.filled(3, 0.0);

  // Jupiter's Longitude
  longitude[0] = 0.59955 * cos(0.00000 + 0.00000 * T);
  longitude[0] += 0.09696 * cos(5.06192 + 529.69097 * T);
  longitude[0] += 0.00574 * cos(1.44406 + 7.11355 * T);
  longitude[0] += 0.00306 * cos(5.41735 + 1059.38193 * T);
  longitude[0] += 0.00097 * cos(4.14265 + 632.78374 * T);
  longitude[0] += 0.00073 * cos(3.64043 + 522.57742 * T);
  longitude[0] += 0.00064 * cos(3.41145 + 103.09277 * T);
  longitude[0] += 0.00040 * cos(2.29377 + 419.48464 * T);
  longitude[0] += 0.00039 * cos(1.27232 + 316.39187 * T);
  longitude[0] += 0.00028 * cos(1.78455 + 536.80451 * T);
  longitude[0] += 0.00014 * cos(5.77481 + 1589.07290 * T);
  longitude[1] = 529.93481 * cos(0.00000 + 0.00000 * T);
  longitude[1] += 0.00490 * cos(4.22067 + 529.69097 * T);
  longitude[1] += 0.00229 * cos(6.02647 + 7.11355 * T);
  longitude[1] += 0.00028 * cos(4.57266 + 1059.38193 * T);
  longitude[1] += 0.00021 * cos(5.45939 + 522.57742 * T);
  longitude[1] += 0.00012 * cos(0.16986 + 536.80451 * T);
  longitude[2] = 0.00047 * cos(4.32148 + 7.11355 * T);
  longitude[2] += 0.00031 * cos(2.93021 + 529.69097 * T);
  longitude[2] += 0.00039 * cos(0.00000 + 0.00000 * T);
  // Jupiter's Latitude
  latitude[0] = 0.02269 * cos(3.55853 + 529.69097 * T);
  latitude[0] += 0.00110 * cos(3.90809 + 1059.38193 * T);
  latitude[0] += 0.00110 * cos(0.00000 + 0.00000 * T);
  latitude[1] = 0.00177 * cos(5.70166 + 529.69097 * T);
  // Jupiter's Radius Vector
  radius[0] = 5.20887 * cos(0.00000 + 0.00000 * T);
  radius[0] += 0.25209 * cos(3.49109 + 529.69097 * T);
  radius[0] += 0.00611 * cos(3.84115 + 1059.38193 * T);
  radius[0] += 0.00282 * cos(2.57420 + 632.78374 * T);
  radius[0] += 0.00188 * cos(2.07590 + 522.57742 * T);
  radius[0] += 0.00087 * cos(0.71001 + 419.48464 * T);
  radius[0] += 0.00072 * cos(0.21466 + 536.80451 * T);
  radius[0] += 0.00066 * cos(5.97996 + 316.39187 * T);
  radius[0] += 0.00029 * cos(1.67759 + 103.09277 * T);
  radius[0] += 0.00030 * cos(2.16132 + 949.17561 * T);
  radius[0] += 0.00023 * cos(3.54023 + 735.87651 * T);
  radius[0] += 0.00022 * cos(4.19363 + 1589.07290 * T);
  radius[0] += 0.00024 * cos(0.27458 + 7.11355 * T);
  radius[0] += 0.00013 * cos(2.96043 + 1162.47470 * T);
  radius[0] += 0.00010 * cos(1.90670 + 206.18555 * T);
  radius[0] += 0.00013 * cos(2.71550 + 1052.26838 * T);
  radius[1] = 0.01272 * cos(2.64938 + 529.69097 * T);
  radius[1] += 0.00062 * cos(3.00076 + 1059.38193 * T);
  radius[1] += 0.00053 * cos(3.89718 + 522.57742 * T);
  radius[1] += 0.00031 * cos(4.88277 + 536.80451 * T);
  radius[1] += 0.00041 * cos(0.00000 + 0.00000 * T);
  radius[1] += 0.00012 * cos(2.41330 + 419.48464 * T);
  radius[2] = 0.00080 * cos(1.35866 + 529.69097 * T);

  lo = mod360(calculateVsopTerm(T, longitude) / degreesToRadians);
  bo = calculateVsopTerm(T, latitude) / degreesToRadians;
  ro = calculateVsopTerm(T, radius);

  var res = [lo, bo, ro];
  return res;
}

List<double> calculatePositionOfSaturn(T) {
  var lo = 0.0;
  var bo = 0.0;
  var ro = 0.0;
  var longitude = List<double>.filled(4, 0.0);
  var latitude = List<double>.filled(3, 0.0);
  var radius = List<double>.filled(4, 0.0);

  // Saturn's Longitude
  longitude[0] = 0.87401 * cos(0.00000 + 0.00000 * T);
  longitude[0] += 0.11108 * cos(3.96205 + 213.29910 * T);
  longitude[0] += 0.01414 * cos(4.58582 + 7.11355 * T);
  longitude[0] += 0.00398 * cos(0.52112 + 206.18555 * T);
  longitude[0] += 0.00351 * cos(3.30330 + 426.59819 * T);
  longitude[0] += 0.00207 * cos(0.24658 + 103.09277 * T);
  longitude[0] += 0.00079 * cos(3.84007 + 220.41264 * T);
  longitude[0] += 0.00024 * cos(4.66977 + 110.20632 * T);
  longitude[0] += 0.00017 * cos(0.43719 + 419.48464 * T);
  longitude[0] += 0.00015 * cos(5.76903 + 316.39187 * T);
  longitude[0] += 0.00016 * cos(0.93809 + 632.78374 * T);
  longitude[0] += 0.00015 * cos(1.56519 + 3.93215 * T);
  longitude[0] += 0.00013 * cos(4.44891 + 14.22709 * T);
  longitude[0] += 0.00015 * cos(2.71670 + 639.89729 * T);
  longitude[0] += 0.00013 * cos(5.98119 + 11.04570 * T);
  longitude[0] += 0.00011 * cos(3.12940 + 202.25340 * T);
  longitude[1] = 213.54296 * cos(0.00000 + 0.00000 * T);
  longitude[1] += 0.01297 * cos(1.82821 + 213.29910 * T);
  longitude[1] += 0.00564 * cos(2.88500 + 7.11355 * T);
  longitude[1] += 0.00098 * cos(1.08070 + 426.59819 * T);
  longitude[1] += 0.00108 * cos(2.27770 + 206.18555 * T);
  longitude[1] += 0.00040 * cos(2.04128 + 220.41264 * T);
  longitude[1] += 0.00020 * cos(1.27955 + 103.09277 * T);
  longitude[1] += 0.00011 * cos(2.74880 + 14.22709 * T);
  longitude[2] = 0.00116 * cos(1.17988 + 7.11355 * T);
  longitude[2] += 0.00092 * cos(0.07425 + 213.29910 * T);
  longitude[2] += 0.00091 * cos(0.00000 + 0.00000 * T);
  longitude[2] += 0.00015 * cos(4.06492 + 206.18555 * T);
  longitude[2] += 0.00011 * cos(0.25778 + 220.41264 * T);
  longitude[2] += 0.00011 * cos(5.40964 + 426.59819 * T);
  longitude[3] = 0.00016 * cos(5.73945 + 7.11355 * T);
  // Saturn's Latitude
  latitude[0] = 0.04331 * cos(3.60284 + 213.29910 * T);
  latitude[0] += 0.00240 * cos(2.85238 + 426.59819 * T);
  latitude[0] += 0.00085 * cos(0.00000 + 0.00000 * T);
  latitude[0] += 0.00031 * cos(3.48442 + 220.41264 * T);
  latitude[0] += 0.00034 * cos(0.57297 + 206.18555 * T);
  latitude[0] += 0.00015 * cos(2.11847 + 639.89729 * T);
  latitude[0] += 0.00010 * cos(5.79003 + 419.48464 * T);
  latitude[1] = 0.00398 * cos(5.33290 + 213.29910 * T);
  latitude[1] += 0.00049 * cos(3.14159 + 0.00000 * T);
  latitude[1] += 0.00019 * cos(6.09919 + 426.59819 * T);
  latitude[1] += 0.00015 * cos(2.30586 + 206.18555 * T);
  latitude[1] += 0.00010 * cos(1.69675 + 220.41264 * T);
  latitude[2] = 0.00021 * cos(0.50482 + 213.29910 * T);
  // Saturn's Radius Vector
  radius[0] = 9.55758 * cos(0.00000 + 0.00000 * T);
  radius[0] += 0.52921 * cos(2.39226 + 213.29910 * T);
  radius[0] += 0.01874 * cos(5.23550 + 206.18555 * T);
  radius[0] += 0.01465 * cos(1.64763 + 426.59819 * T);
  radius[0] += 0.00822 * cos(5.93520 + 316.39187 * T);
  radius[0] += 0.00548 * cos(5.01533 + 103.09277 * T);
  radius[0] += 0.00372 * cos(2.27115 + 220.41264 * T);
  radius[0] += 0.00362 * cos(3.13904 + 7.11355 * T);
  radius[0] += 0.00141 * cos(5.70407 + 632.78374 * T);
  radius[0] += 0.00109 * cos(3.29314 + 110.20632 * T);
  radius[0] += 0.00069 * cos(5.94100 + 419.48464 * T);
  radius[0] += 0.00061 * cos(0.94038 + 639.89729 * T);
  radius[0] += 0.00049 * cos(1.55733 + 202.25340 * T);
  radius[0] += 0.00034 * cos(0.19519 + 277.03499 * T);
  radius[0] += 0.00032 * cos(5.47085 + 949.17561 * T);
  radius[0] += 0.00021 * cos(0.46349 + 735.87651 * T);
  radius[0] += 0.00021 * cos(1.52103 + 433.71174 * T);
  radius[0] += 0.00021 * cos(5.33256 + 199.07200 * T);
  radius[0] += 0.00015 * cos(3.05944 + 529.69097 * T);
  radius[0] += 0.00014 * cos(2.60434 + 323.50542 * T);
  radius[0] += 0.00012 * cos(5.98051 + 846.08283 * T);
  radius[0] += 0.00011 * cos(1.73106 + 522.57742 * T);
  radius[0] += 0.00013 * cos(1.64892 + 138.51750 * T);
  radius[0] += 0.00010 * cos(5.20476 + 1265.56748 * T);
  radius[1] = 0.06183 * cos(0.25844 + 213.29910 * T);
  radius[1] += 0.00507 * cos(0.71115 + 206.18555 * T);
  radius[1] += 0.00341 * cos(5.79636 + 426.59819 * T);
  radius[1] += 0.00188 * cos(0.47216 + 220.41264 * T);
  radius[1] += 0.00186 * cos(3.14159 + 0.00000 * T);
  radius[1] += 0.00144 * cos(1.40745 + 7.11355 * T);
  radius[1] += 0.00050 * cos(6.01744 + 103.09277 * T);
  radius[1] += 0.00021 * cos(5.09246 + 639.89729 * T);
  radius[1] += 0.00020 * cos(1.17560 + 419.48464 * T);
  radius[1] += 0.00019 * cos(1.60820 + 110.20632 * T);
  radius[1] += 0.00013 * cos(5.94330 + 433.71174 * T);
  radius[1] += 0.00014 * cos(0.75886 + 199.07200 * T);
  radius[2] = 0.00437 * cos(4.78672 + 213.29910 * T);
  radius[2] += 0.00072 * cos(2.50070 + 206.18555 * T);
  radius[2] += 0.00050 * cos(4.97168 + 220.41264 * T);
  radius[2] += 0.00043 * cos(3.86940 + 426.59819 * T);
  radius[2] += 0.00030 * cos(5.96310 + 7.11355 * T);
  radius[3] = 0.00020 * cos(3.02187 + 213.29910 * T);

  lo = mod360(calculateVsopTerm(T, longitude) / degreesToRadians);
  bo = calculateVsopTerm(T, latitude) / degreesToRadians;
  ro = calculateVsopTerm(T, radius);

  var res = [lo, bo, ro];
  return res;
}

List<double> calculatePositionOfUranus(T) {
  var lo = 0.0;
  var bo = 0.0;
  var ro = 0.0;
  var longitude = List<double>.filled(3, 0.0);
  var latitude = List<double>.filled(2, 0.0);
  var radius = List<double>.filled(3, 0.0);

  // Uranus's Longitude
  longitude[0] = 5.48129 * cos(0.00000 + 0.00000 * T);
  longitude[0] += 0.09260 * cos(0.89106 + 74.78160 * T);
  longitude[0] += 0.01504 * cos(3.62719 + 1.48447 * T);
  longitude[0] += 0.00366 * cos(1.89962 + 73.29713 * T);
  longitude[0] += 0.00272 * cos(3.35824 + 149.56320 * T);
  longitude[0] += 0.00070 * cos(5.39254 + 63.73590 * T);
  longitude[0] += 0.00069 * cos(6.09292 + 76.26607 * T);
  longitude[0] += 0.00062 * cos(2.26952 + 2.96895 * T);
  longitude[0] += 0.00062 * cos(2.85099 + 11.04570 * T);
  longitude[0] += 0.00026 * cos(3.14152 + 71.81265 * T);
  longitude[0] += 0.00026 * cos(6.11380 + 454.90937 * T);
  longitude[0] += 0.00021 * cos(4.36059 + 148.07872 * T);
  longitude[0] += 0.00018 * cos(1.74437 + 36.64856 * T);
  longitude[0] += 0.00015 * cos(4.73732 + 3.93215 * T);
  longitude[0] += 0.00011 * cos(5.82682 + 224.34480 * T);
  longitude[0] += 0.00011 * cos(0.48865 + 138.51750 * T);
  longitude[0] += 0.00010 * cos(2.95517 + 35.16409 * T);
  longitude[1] = 75.02543 * cos(0.00000 + 0.00000 * T);
  longitude[1] += 0.00154 * cos(5.24202 + 74.78160 * T);
  longitude[1] += 0.00024 * cos(1.71256 + 1.48447 * T);
  longitude[2] = 0.00053 * cos(0.00000 + 0.00000 * T);
  // Uranus's Latitude
  latitude[0] = 0.01346 * cos(2.61878 + 74.78160 * T);
  latitude[0] += 0.00062 * cos(5.08111 + 149.56320 * T);
  latitude[0] += 0.00062 * cos(3.14159 + 0.00000 * T);
  latitude[0] += 0.00010 * cos(1.61604 + 76.26607 * T);
  latitude[0] += 0.00010 * cos(0.57630 + 73.29713 * T);
  latitude[1] = 0.00206 * cos(4.12394 + 74.78160 * T);
  // Uranus's Radius Vector
  radius[0] = 19.21265 * cos(0.00000 + 0.00000 * T);
  radius[0] += 0.88785 * cos(5.60378 + 74.78160 * T);
  radius[0] += 0.03441 * cos(0.32836 + 73.29713 * T);
  radius[0] += 0.02056 * cos(1.78295 + 149.56320 * T);
  radius[0] += 0.00649 * cos(4.52247 + 76.26607 * T);
  radius[0] += 0.00602 * cos(3.86004 + 63.73590 * T);
  radius[0] += 0.00496 * cos(1.40140 + 454.90937 * T);
  radius[0] += 0.00339 * cos(1.58003 + 138.51750 * T);
  radius[0] += 0.00244 * cos(1.57087 + 71.81265 * T);
  radius[0] += 0.00191 * cos(1.99809 + 1.48447 * T);
  radius[0] += 0.00162 * cos(2.79138 + 148.07872 * T);
  radius[0] += 0.00144 * cos(1.38369 + 11.04570 * T);
  radius[0] += 0.00093 * cos(0.17437 + 36.64856 * T);
  radius[0] += 0.00071 * cos(4.24509 + 224.34480 * T);
  radius[0] += 0.00090 * cos(3.66105 + 109.94569 * T);
  radius[0] += 0.00039 * cos(1.66971 + 70.84945 * T);
  radius[0] += 0.00047 * cos(1.39977 + 35.16409 * T);
  radius[0] += 0.00039 * cos(3.36235 + 277.03499 * T);
  radius[0] += 0.00037 * cos(3.88649 + 146.59425 * T);
  radius[0] += 0.00030 * cos(0.70100 + 151.04767 * T);
  radius[0] += 0.00029 * cos(3.18056 + 77.75054 * T);
  radius[0] += 0.00020 * cos(1.55589 + 202.25340 * T);
  radius[0] += 0.00026 * cos(5.25656 + 380.12777 * T);
  radius[0] += 0.00026 * cos(3.78538 + 85.82730 * T);
  radius[0] += 0.00023 * cos(0.72519 + 529.69097 * T);
  radius[0] += 0.00020 * cos(2.79640 + 70.32818 * T);
  radius[0] += 0.00018 * cos(0.55455 + 2.96895 * T);
  radius[0] += 0.00012 * cos(5.96039 + 127.47180 * T);
  radius[0] += 0.00015 * cos(4.90434 + 108.46122 * T);
  radius[0] += 0.00011 * cos(0.43774 + 65.22037 * T);
  radius[0] += 0.00016 * cos(5.35405 + 38.13304 * T);
  radius[0] += 0.00011 * cos(1.42105 + 213.29910 * T);
  radius[0] += 0.00012 * cos(3.29826 + 3.93215 * T);
  radius[0] += 0.00012 * cos(1.75044 + 984.60033 * T);
  radius[0] += 0.00013 * cos(2.62154 + 111.43016 * T);
  radius[0] += 0.00012 * cos(0.99343 + 52.69020 * T);
  radius[1] = 0.01480 * cos(3.67206 + 74.78160 * T);
  radius[1] += 0.00071 * cos(6.22601 + 63.73590 * T);
  radius[1] += 0.00069 * cos(6.13411 + 149.56320 * T);
  radius[1] += 0.00021 * cos(5.24625 + 11.04570 * T);
  radius[1] += 0.00021 * cos(2.60177 + 76.26607 * T);
  radius[1] += 0.00024 * cos(3.14159 + 0.00000 * T);
  radius[1] += 0.00011 * cos(0.01848 + 70.84945 * T);
  radius[2] = 0.00022 * cos(0.69953 + 74.78160 * T);

  lo = mod360(calculateVsopTerm(T, longitude) / degreesToRadians);
  bo = calculateVsopTerm(T, latitude) / degreesToRadians;
  ro = calculateVsopTerm(T, radius);

  var res = [lo, bo, ro];
  return res;
}

List<double> calculatePositionOfNeptune(T) {
  var lo = 0.0;
  var bo = 0.0;
  var ro = 0.0;
  var longitude = List<double>.filled(3, 0.0);
  var latitude = List<double>.filled(3, 0.0);
  var radius = List<double>.filled(2, 0.0);

  // Neptune's Longitude
  longitude[0] = 5.31189 * cos(0.00000 + 0.00000 * T);
  longitude[0] += 0.01798 * cos(2.90101 + 38.13304 * T);
  longitude[0] += 0.01020 * cos(0.48581 + 1.48447 * T);
  longitude[0] += 0.00125 * cos(4.83008 + 36.64856 * T);
  longitude[0] += 0.00042 * cos(5.41055 + 2.96895 * T);
  longitude[0] += 0.00038 * cos(6.09222 + 35.16409 * T);
  longitude[0] += 0.00034 * cos(1.24489 + 76.26607 * T);
  longitude[0] += 0.00016 * cos(0.00008 + 491.55793 * T);
  longitude[1] = 38.37688 * cos(0.00000 + 0.00000 * T);
  longitude[1] += 0.00017 * cos(4.86319 + 1.48447 * T);
  longitude[1] += 0.00016 * cos(2.27923 + 38.13304 * T);
  longitude[2] = 0.00054 * cos(0.00000 + 0.00000 * T);
  // Neptune's Latitude
  latitude[0] = 0.03089 * cos(1.44104 + 38.13304 * T);
  latitude[0] += 0.00028 * cos(5.91272 + 76.26607 * T);
  latitude[0] += 0.00028 * cos(0.00000 + 0.00000 * T);
  latitude[0] += 0.00015 * cos(2.52124 + 36.64856 * T);
  latitude[0] += 0.00015 * cos(3.50877 + 39.61751 * T);
  latitude[1] = 0.00227 * cos(3.80793 + 38.13304 * T);
  latitude[2] = 0.00010 * cos(5.57124 + 38.13304 * T);
  // Neptune's Radius Vector
  radius[0] = 30.07013 * cos(0.00000 + 0.00000 * T);
  radius[0] += 0.27062 * cos(1.32999 + 38.13304 * T);
  radius[0] += 0.01692 * cos(3.25186 + 36.64856 * T);
  radius[0] += 0.00808 * cos(5.18593 + 1.48447 * T);
  radius[0] += 0.00538 * cos(4.52114 + 35.16409 * T);
  radius[0] += 0.00496 * cos(1.57106 + 491.55793 * T);
  radius[0] += 0.00275 * cos(1.84552 + 175.16606 * T);
  radius[0] += 0.00135 * cos(3.37221 + 39.61751 * T);
  radius[0] += 0.00122 * cos(5.79754 + 76.26607 * T);
  radius[0] += 0.00101 * cos(0.37703 + 73.29713 * T);
  radius[0] += 0.00070 * cos(3.79617 + 2.96895 * T);
  radius[0] += 0.00047 * cos(5.74938 + 33.67962 * T);
  radius[0] += 0.00025 * cos(0.50802 + 109.94569 * T);
  radius[0] += 0.00017 * cos(1.59422 + 71.81265 * T);
  radius[0] += 0.00014 * cos(1.07786 + 74.78160 * T);
  radius[0] += 0.00012 * cos(1.92062 + 1021.24889 * T);
  radius[1] = 0.00236 * cos(0.70498 + 38.13304 * T);
  radius[1] += 0.00013 * cos(3.32015 + 1.48447 * T);

  lo = mod360(calculateVsopTerm(T, longitude) / degreesToRadians);
  bo = calculateVsopTerm(T, latitude) / degreesToRadians;
  ro = calculateVsopTerm(T, radius);

  var res = [lo, bo, ro];
  return res;
}

List<double> calculatePositionOfPlutoMee(T) {
  var lo = 238.9581 + 144.96 * T;
  var bo = -3.9082;
  var ro = 40.7241;

  var saturn = mod360(50.58 + 1222.1138 * T);
  var pluto = mod360(238.96 + 144.9600 * T);

  // Pluto's Longitude
  lo += -19.7998 * sin4deg(pluto * 1.0) + 19.8501 * cos4deg(pluto * 1.0);
  lo += 0.8971 * sin4deg(pluto * 2.0) - 4.9548 * cos4deg(pluto * 2.0);
  lo += 0.6111 * sin4deg(pluto * 3.0) + 1.2110 * cos4deg(pluto * 3.0);
  lo += -0.3412 * sin4deg(pluto * 4.0) - 0.1896 * cos4deg(pluto * 4.0);
  lo += 0.1293 * sin4deg(pluto * 5.0) - 0.0350 * cos4deg(pluto * 5.0);
  lo += -0.0382 * sin4deg(pluto * 6.0) + 0.0309 * cos4deg(pluto * 6.0);
  lo += 0.0204 * sin4deg(saturn - pluto) - 0.0100 * cos4deg(saturn - pluto);
  lo += -0.0041 * sin4deg(saturn * 1.0) - 0.0051 * cos4deg(saturn * 1.0);
  lo += -0.0060 * sin4deg(saturn + pluto) - 0.0033 * cos4deg(saturn + pluto);

  // Pluto's Latitude
  bo += -5.4529 * sin4deg(pluto * 1.0) - 14.9749 * cos4deg(pluto * 1.0);
  bo += 3.5278 * sin4deg(pluto * 2.0) + 1.6728 * cos4deg(pluto * 2.0);
  bo += -1.0507 * sin4deg(pluto * 3.0) + 0.3276 * cos4deg(pluto * 3.0);
  bo += 0.1787 * sin4deg(pluto * 4.0) - 0.2922 * cos4deg(pluto * 4.0);
  bo += 0.0187 * sin4deg(pluto * 5.0) + 0.1003 * cos4deg(pluto * 5.0);
  bo += -0.0307 * sin4deg(pluto * 6.0) - 0.0258 * cos4deg(pluto * 6.0);
  bo += 0.0049 * sin4deg(saturn - pluto) + 0.0112 * cos4deg(saturn - pluto);
  bo += 0.0020 * sin4deg(saturn + pluto) - 0.0008 * cos4deg(saturn + pluto);

  // Pluto's Radius Vector
  ro += 6.6865 * sin4deg(pluto * 1.0) + 6.8952 * cos4deg(pluto * 1.0);
  ro += -1.1828 * sin4deg(pluto * 2.0) - 0.0332 * cos4deg(pluto * 2.0);
  ro += 0.1593 * sin4deg(pluto * 3.0) - 0.1439 * cos4deg(pluto * 3.0);
  ro += -0.0018 * sin4deg(pluto * 4.0) + 0.0483 * cos4deg(pluto * 4.0);
  ro += -0.0065 * sin4deg(pluto * 5.0) - 0.0085 * cos4deg(pluto * 5.0);
  ro += 0.0031 * sin4deg(pluto * 6.0) - 0.0006 * cos4deg(pluto * 6.0);
  ro += -0.0006 * sin4deg(saturn - pluto) - 0.0022 * cos4deg(saturn - pluto);
  ro += 0.0005 * sin4deg(saturn * 1.0) - 0.0004 * cos4deg(saturn * 1.0);
  ro += -0.0002 * sin4deg(saturn + pluto);

  var res = [lo, bo, ro];
  return res;
}

// Taken from ftp://cyrano-se.obspm.fr/pub/3_solar_system/3_pluto/notice.txt
List<double> calculatePositionOfPlutoObspm(T) {
  var tSquared = T * T;
  var tCubed = tSquared * T;

  var a = 39.5404;
  a += 0.004471 * T;
  a += 0.0315 * sin(2.545150 * T + 1.8271);
  a += 0.0490 * sin(18.787117 * T + 4.4687);
  a += 0.0536 * sin(47.883664 * T + 3.8553);
  a += 0.2141 * sin(50.426476 * T + 4.1802);
  a += 0.0004 * sin(47.883664 * T + 4.1379);
  a += 0.0066 * sin(50.426476 * T + 5.1987);
  a += 0.0091 * sin(47.883664 * T + 5.6881);
  a += 0.0200 * sin(50.426476 * T + 6.0165);
  a += 0.000018 * T * sin(47.883664 * T + 4.1379);
  a += 0.000330 * T * sin(50.426476 * T + 5.1987);
  a += 0.000905 * T * sin(47.883664 * T + 5.6881);
  a += 0.001990 * T * sin(50.426476 * T + 6.0165);
  a += 0.00002256 * tSquared * sin(47.883664 * T + 5.6881);
  a += 0.00004958 * tSquared * sin(50.426476 * T + 6.0165);

  var l = 4.1702;
  l += 2.533953 * T;
  l += -0.00021295 * tSquared;
  l += 0.0000001231 * tCubed;
  l += 0.0014 * sin(0.199159 * T + 5.8539);
  l += 0.0050 * sin(0.364944 * T + 1.2137);
  l += 0.0055 * sin(0.397753 * T + 4.9469);
  l += 0.0002 * sin(2.543029 * T + 3.0186);
  l += 0.0012 * sin(18.787098 * T + 3.4938);
  l += 0.0008 * sin(18.817229 * T + 2.0097);
  l += 0.0050 * sin(50.426472 * T + 2.6252);
  l += 0.0015 * sin(52.969319 * T + 6.1048);
  l += 0.0008 * sin(292.208471 * T + 4.7603);
  l += 0.0008 * sin(292.265343 * T + 2.8055);
  l += 0.0031 * sin(0.364944 * T + 2.7888);
  l += 0.0004 * sin(2.543029 * T + 0.5111);
  l += 0.0003 * sin(18.787098 * T + 6.1336);
  l += 0.0000 * sin(50.426472 * T + 2.2515);
  l += 0.0004 * sin(292.208471 * T + 0.0813);
  l += 0.0004 * sin(292.265343 * T + 1.2477);
  l += 0.0004 * sin(50.426472 * T + 4.2694);
  l += 0.000156 * T * sin(0.364944 * T + 2.7888);
  l += 0.000020 * T * sin(2.543029 * T + 0.5111);
  l += 0.000017 * T * sin(18.787098 * T + 6.1336);
  l += 0.000000 * T * sin(50.426472 * T + 2.2515);
  l += 0.000022 * T * sin(292.208471 * T + 0.0813);
  l += 0.000022 * T * sin(292.265343 * T + 1.2477);
  l += 0.000044 * T * sin(50.426472 * T + 4.2694);
  l += 0.00000110 * tSquared * sin(50.426472 * T + 4.2694);
  l /= degreesToRadians;

  var h = -0.1733;
  h += -0.000013 * T;
  h += 0.0012 * sin(2.541849 * T + 3.9572);
  h += 0.0008 * sin(21.329808 * T + 0.8858);
  h += 0.0012 * sin(47.883781 * T + 1.4929);
  h += 0.0005 * sin(50.426641 * T + 5.3286);
  h += 0.0037 * sin(52.969135 * T + 0.6139);

  var k = -0.1787;
  k += -0.000070 * T;
  k += 0.0006 * sin(2.512561 * T + 3.8516);
  k += 0.0013 * sin(2.543100 * T + 0.0218);
  k += 0.0008 * sin(21.329765 * T + 2.4324);
  k += 0.0012 * sin(47.883788 * T + 6.2432);
  k += 0.0005 * sin(50.426611 * T + 3.0920);
  k += 0.0038 * sin(52.969155 * T + 2.1566);
  k += 0.0004 * sin(2.512561 * T + 5.3919);
  k += 0.000022 * T * sin(2.512561 * T + 5.3919);

  var p = 0.1398;
  p += 0.000007 * T;
  p += 0.0002 * sin(50.426871 * T + 0.6705);
  p += 0.0002 * sin(55.512211 * T + 6.0770);

  var q = -0.0517;
  q += 0.000020 * T;
  q += 0.0002 * sin(50.426859 * T + 5.4131);
  q += 0.0002 * sin(55.512206 * T + 1.3314);

  // my( $L, $opi, $omg, $i, $e, $a ) = convertOrbitalElement( $a, $l, $h, $k, $p, $q );
  var orbitalElements = convertOrbitalElement(a, l, h, k, p, q);
  return orbitWork(orbitalElements[0], orbitalElements[1], orbitalElements[2],
      orbitalElements[3], orbitalElements[4], orbitalElements[5]);
}

double calculateSolarVelocity(julianDate) {
  var T = (julianDate - 2451545.0) / 365250.0;
  var velocity = 3548.330;

  velocity += 118.568 * sin4deg(87.5287 + 359993.7286 * T);
  return velocity / 3600.0;
}

double calculateLunarVelocity(julianDate) {
  var T = (julianDate - 2451545.0) / 36525.0;
  var mf = List<double>.filled(4, 0.0);
  double velocity;

  // D : Mean elongation of the Moon
  mf[0] = 445267.0 * T;
  mf[0] = mod360(mf[0]);
  mf[0] += 0.11151 * T;
  mf[0] -= 0.00163 * T * T;
  mf[0] += 297.85020;
  mf[0] = mod360(mf[0]);

  // l' : Mean anomary of the Sun
  mf[1] = 35999.0 * T;
  mf[1] = mod360(mf[1]);
  mf[1] += 0.05029 * T;
  mf[1] -= 0.00015 * T * T;
  mf[1] += 357.51687;
  mf[1] = mod360(mf[1]);

  // l : Mean anomary of the Moon
  mf[2] = 477198.0 * T;
  mf[2] = mod360(mf[2]);
  mf[2] += 0.86763 * T;
  mf[2] += 0.008997 * T * T;
  mf[2] += 134.96341;
  mf[2] = mod360(mf[2]);

  // F : Argument of latitude of the Moon
  mf[3] = 483202.0 * T;
  mf[3] = mod360(mf[3]);
  mf[3] += 0.01753 * T;
  mf[3] -= 0.00340 * T * T;
  mf[3] += 93.27210;
  mf[3] = mod360(mf[3]);

  velocity = 13.176397;
  velocity += 1.434006 * cos4deg(mf[2]);
  velocity += 0.280135 * cos4deg(2.0 * mf[0]);
  velocity += 0.251632 * cos4deg(2.0 * mf[0] - mf[2]);
  velocity += 0.097420 * cos4deg(2.0 * mf[2]);
  velocity -= 0.052799 * cos4deg(2.0 * mf[3]);
  velocity += 0.034848 * cos4deg(2.0 * mf[0] + mf[2]);
  velocity += 0.018732 * cos4deg(2.0 * mf[0] - mf[1]);
  velocity += 0.010316 * cos4deg(2.0 * mf[0] - mf[1] - mf[2]);
  velocity += 0.008649 * cos4deg(mf[1] - mf[2]);
  velocity -= 0.008642 * cos4deg(2.0 * mf[3] + mf[2]);
  velocity -= 0.007471 * cos4deg(mf[1] + mf[2]);
  velocity -= 0.007387 * cos4deg(mf[0]);
  velocity += 0.006864 * cos4deg(3.0 * mf[2]);
  velocity += 0.006650 * cos4deg(4.0 * mf[0] - mf[2]);

  return velocity;
}

// This function from "Numerical expressions for precession formulae
// and mean elements for the Moon and the planets" J. L. Simon, et al.,
// Astron. Astrophys., 282, 663-683(1994).
List<double> calculatePositionOfLuna(julianDate) {
  var d = julianDate - 2451545.0;
  var T = d / 36525.0;
  double D, F, l, l1, omg, opi, dh, lt;

  omg = mod360(125.0445550 - 0.0529537628 * d + 0.0020761667 * T * T);
  opi = mod360(83.3532430 + 0.1114308160 * d - 0.0103237778 * T * T);

  D = mod360(297.8502042 + 12.19074912 * d - 0.0016299722 * T * T);
  F = mod360(93.2720993 + 13.22935024 * d - 0.0034029167 * T * T);
  l = mod360(134.9634114 + 13.06499295 * d + 0.0089970278 * T * T);
  l1 = mod360(357.5291092 + 0.98560028 * d - 0.0001536667 * T * T);

  dh = omg;
  dh -= 1.4978 * sin4deg(2.0 * (D - F));
  dh -= 0.1500 * sin4deg(l1);
  dh -= 0.1225 * sin4deg(2.0 * D);
  dh += 0.1175 * sin4deg(2.0 * F);
  dh -= 0.0800 * sin4deg(2.0 * (l - F));
  dh = mod360(dh);

  lt = opi + 180.0;
  lt -= 15.4469 * sin4deg(2.0 * D - l);
  lt -= 9.6419 * sin4deg(2.0 * (D - l));
  lt -= 2.7200 * sin4deg(l);
  lt += 2.6069 * sin4deg(4.0 * D - 3.0 * l);
  lt += 2.0847 * sin4deg(4.0 * D - 2.0 * l);
  lt += 1.4772 * sin4deg(2.0 * D + l);
  lt += 0.9678 * sin4deg(4.0 * (D - l));
  lt -= 0.9412 * sin4deg(2.0 * D - l1 - l);
  lt -= 0.7028 * sin4deg(6.0 * D - 4.0 * l);
  lt -= 0.6600 * sin4deg(2.0 * D);
  lt -= 0.5764 * sin4deg(2.0 * D - 3.0 * l);
  lt -= 0.5231 * sin4deg(2.0 * l);
  lt -= 0.4822 * sin4deg(6.0 * D - 5.0 * l);
  lt += 0.4517 * sin4deg(l1);
  lt -= 0.3806 * sin4deg(6.0 * D - 3.0 * l);

  var luna = [dh, lt];
  return luna;
}

List<double> calculateGeoPoint(lst, la, obl) {
  var mcX = sin4deg(lst);
  var mcY = cos4deg(lst) * cos4deg(obl);
  var mc = mod360(atan2(mcX, mcY) / degreesToRadians);

  if (mc < 0.0) {
    mc += 360.0;
  }

  var ascX = cos4deg(lst);
  var ascY = -(sin4deg(obl) * tan4deg(la));
  ascY -= cos4deg(obl) * sin4deg(lst);

  var asc = mod360(atan2(ascX, ascY) / degreesToRadians);

  if (asc < 0.0) {
    asc += 360.0;
  }

  var res = [asc, mc];

  return res;
}

double calculateVsopTerm(T, term) {
  var res = 0.0;

  for (var i = term.length - 1; i >= 0; i--) {
    res = term[i] + res * T;
  }

  return res;
}

List<double> calculatePositionOfSun(T) {
  var lo = 0.0;
  var bo = 0.0;
  var ro = 0.0;
  var longitude = List<double>.filled(3, 0.0);
  var radius = List<double>.filled(2, 0.0);
  // Earth(Sun)'s Longitude
  longitude[0] = 1.75347 * cos(0.00000 + 0.00000 * T);
  longitude[0] += 0.03342 * cos(4.66926 + 6283.07585 * T);
  longitude[0] += 0.00035 * cos(4.62610 + 12566.15170 * T);
  longitude[1] = 6283.31967 * cos(0.00000 + 0.00000 * T);
  longitude[1] += 0.00206 * cos(2.67823 + 6283.07585 * T);
  longitude[2] = 0.00053 * cos(0.00000 + 0.00000 * T);

  // Earth(Sun)'s Radius Vector
  radius[0] = 1.00014 * cos(0.00000 + 0.00000 * T);
  radius[0] += 0.01671 * cos(3.09846 + 6283.07585 * T);
  radius[0] += 0.00014 * cos(3.05525 + 12566.15170 * T);
  radius[1] = 0.00103 * cos(1.10749 + 6283.07585 * T);

  lo = mod360(calculateVsopTerm(T, longitude) / degreesToRadians);
  ro = calculateVsopTerm(T, radius);

  lo = mod360(lo + 180.0);

  var res = [lo, bo, ro];
  return res;
}

List<int> convertCalendar(julianDate) {
  julianDate += 0.5;
  var Z = julianDate.floor();
  var F = julianDate - Z;

  var A = 0;
  if (Z >= 2299161) {
    var alpha = ((Z - 1867216.25) / 36524.25).floor();
    A = Z + 1 + alpha - (alpha / 4).floor();
  } else {
    A = Z;
  }

  var B = A + 1524;
  var C = ((B - 122.1) / 365.25).floor();
  var D = (365.25 * C).floor();
  var E = ((B - D) / 30.6001).floor();

  int day = B - D - (30.6001 * E).floor();
  int month = (E < 13.5) ? (E - 1) : (E - 13);
  int year = (month > 2.5) ? (C - 4716) : (C - 4715);

  var time = F * 24.0;
  int hour = time.floor();
  int minute = (time - hour) * 60.0;

  var res = [year, month, day, hour, minute];
  return res;
}

double calculateJulianDate(year, month, day, hour, minute) {
  // �����̏�
  var y0 = (month > 2) ? year : (year - 1);
  var m0 = (month > 2) ? month : (month + 12);
  num julianDate =
      (365.25 * y0).floor() + (y0 / 400).floor() - (y0 / 100).floor();
  julianDate += (30.59 * (m0 - 2)).floor() + day;
  julianDate += ((hour - 9) * 60.0 + minute) / 1440.0 + 1721088.5;

  return julianDate.toDouble();
}

int convertJulianDateR(julianDate) {
  var date = convertCalendar(julianDate);
  var ye = date[0];
  var mo = date[1];
  var da = date[2];
  var julianDateZ = calculateJulianDateZ(ye, mo, da);

  return julianDateZ;
}

int calculateJulianDateZ(year, month, int day) {
  // ������
  var yt = year;
  var mt = month;
  var dt = day;

  if (month < 3) {
    yt--;
    mt += 12;
  }

  int julianDate = (365.25 * yt).floor() + (30.6001 * (mt + 1)).floor();
  julianDate += dt + 1720995;
  julianDate += 2 - int.parse((yt / 100).floor() + (yt / 400).floor());

  return julianDate;
}

List<double> calculateTimeCoefficient(julianDate) {
  double d = julianDate - 2451545.0;
  double T = d / 36525.0;
  var coef = [d, T];

  return coef;
}

// a : semi-major axis (au).
// l : mean longitude (degree).
// h : e * sin(pi).
// k : e * cos(pi).
// p : g * sin(om).
// q : g * cos(om).
// e : eccentricity.
// g : sine of the half inclination.
// pi: longitude of the perihelion.
// om: longitude of the ascending node.
List<double> convertOrbitalElement(a, l, h, k, p, q) {
  double L = l;
  double e = sqrt(h * h + k * k);
  double g = sqrt(p * p + q * q);
  double i = asin(g) * 2.0 / degreesToRadians;
  double opi = atan2(h, k) / degreesToRadians;
  double omg = atan2(p, q) / degreesToRadians;
  List<double> result = [L, opi, omg, i, e, a];

  return result;
}

List<double> orbitWork(L, opi, omg, i, e, a) {
  var M = mod360(L - opi);
  var E = mod360(solveKepler(M, e));

  var rE = E * degreesToRadians;
  var thv = sqrt((1 + e) / (1 - e)) * tan(rE / 2.0);
  var v = mod360(atan2(thv, 1.0) * 2.0 / degreesToRadians);
  double r = a * (1.0 - e * cos(rE));
  var u = L + v - M - omg;

  var ri = i * degreesToRadians;
  var ru = u * degreesToRadians;
  double l = mod360(omg + atan2(cos(ri) * sin(ru), cos(ru)) / degreesToRadians);

  var rb = asin(sin(ru) * sin(ri));
  double b = rb / degreesToRadians;

  var res = [l, b, r];
  return res;
}

double solveKepler(M, e) {
  var mr = M * degreesToRadians;
  var er = mr;

  for (var i = 0; i < 20; i++) {
    er = mr + e * sin(er);
  }

  return er / degreesToRadians;
}

List<double> convertGeocentric(earthCoor, planetCoor) {
  var ls = earthCoor[0];
  var bs = earthCoor[1];
  var rs = earthCoor[2];
  var lp = planetCoor[0];
  var bp = planetCoor[1];
  var rp = planetCoor[2];

  var xs = rs * cos(ls * degreesToRadians) * cos(bs * degreesToRadians);
  var ys = rs * sin(ls * degreesToRadians) * cos(bs * degreesToRadians);
  var zs = rs * sin(bs * degreesToRadians);
  var xp = rp * cos(lp * degreesToRadians) * cos(bp * degreesToRadians);
  var yp = rp * sin(lp * degreesToRadians) * cos(bp * degreesToRadians);
  var zp = rp * sin(bp * degreesToRadians);

  var xg = xp + xs;
  var yg = yp + ys;
  var zg = zp + zs;

  var rg = sqrt(xg * xg + yg * yg + zg * zg);
  var lg = atan2(yg, xg) / degreesToRadians;
  if (lg < 0.0) lg += 360.0;
  var bg = asin4deg(zg / rg);

  var res = [lg, bg, rg];
  return res;
}

List<double> convertEquatorial(lon, lat, obl) {
  var xs = cos4deg(lon) * cos4deg(lat);
  var ys = sin4deg(lon) * cos4deg(lat);
  var zs = sin4deg(lat);

  var xd = xs;
  var yd = ys * cos4deg(obl) - zs * sin4deg(obl);
  var zd = ys * sin4deg(obl) + zs * cos4deg(obl);

  double rightAscention = atan2(yd, xd) / degreesToRadians;
  if (rightAscention < 0.0) {
    rightAscention += 360.0;
  }
  double declination = asin4deg(zd);

  var res = [rightAscention, declination];
  return res;
}

List<double> coordinateConvertFromJ2000(arg) {
  double x, y, z, xd, yd, zd;
  var xs = arg[0];
  var ys = arg[1];
  var zs = arg[2];
  var tjd = arg[3];
  var T = (tjd - 2451545.0) / 36525.0;
  var zeta = (((0.017998 * T + 0.30188) * T + 2306.2181) * T) / 3600.0;
  var zz = (((0.018203 * T + 1.09468) * T + 2306.2181) * T) / 3600.0;
  var theta = (((-0.041833 * T - 0.42665) * T + 2004.3109) * T) / 3600.0;

  // Step 1
  x = sin4deg(zeta) * xs + cos4deg(zeta) * ys;
  y = -cos4deg(zeta) * xs + sin4deg(zeta) * ys;
  z = zs;

  // Step 2;
  // 	x = x;
  y = 0 * x + cos4deg(theta) * y + sin4deg(theta) * z;
  z = 0 * x - sin4deg(theta) * y + cos4deg(theta) * z;

  // Step 3
  xd = -sin4deg(zz) * x - cos4deg(zz) * y;
  yd = cos4deg(zz) * x - sin4deg(zz) * y;
  zd = z;

  var res = [xd, yd, zd];
  return res;
}

double calculateLocalSiderealTime(julianDate, hour, minute, longitude) {
  var jd0 = (julianDate - 0.5).floor() + 0.5;
  var T = (jd0 - 2451545.0) / 36525.0;
  var ut = (julianDate - jd0) * 360.0 * 1.002737909350795;
  if (ut < 0) ut += 360.0;
  var globalSiderealTime =
      0.279057273 + 100.0021390378 * T + 1.077591667e-06 * T * T;

  globalSiderealTime = globalSiderealTime - globalSiderealTime.floor();
  globalSiderealTime *= 360.0;

  var localSiderealTime = mod360(globalSiderealTime + ut + longitude);
  var dpsi = calculateNutation(julianDate);
  var eps = calculateOblique(julianDate);
  localSiderealTime += dpsi * cos4deg(eps) / 3600.0;
  if (localSiderealTime < 0.0) localSiderealTime += 360.0;

  return localSiderealTime;
}

double calculateOblique(julianDate) {
  var T = (julianDate - 2451545.0) / 36525.0;
  var omg = mod360(125.00452 - T * 1934.136261);
  var ls = mod360(280.4665 + T * 36000.7698);
  var lm = mod360(218.3165 + T * 481267.8813);
  var e = 84381.448 + T * (-46.8150 + T * (-0.00059 + T * 0.001813));
  var deps = 9.20 * cos4deg(1.0 * omg);

  deps += 0.57 * cos4deg(2.0 * ls);
  deps += 0.10 * cos4deg(2.0 * lm);
  deps += -0.09 * cos4deg(2.0 * omg);

  return (e + deps) / 3600.0;
}

const degreesToRadians = pi / 180.0;

double sin4deg(X) {
  return sin(X * degreesToRadians);
}

double cos4deg(X) {
  return cos(X * degreesToRadians);
}

double tan4deg(X) {
  return tan(X * degreesToRadians);
}

double asin4deg(X) {
  return asin(X) / degreesToRadians;
}

double acos4deg(X) {
  return acos(X) / degreesToRadians;
}

double atan4deg(X) {
  return atan(X) / degreesToRadians;
}

double atan24deg(X, Y) {
  return atan2(X, Y) / degreesToRadians;
}

double sgn(X) {
  return X.sign;
}

int fmod(X, t) {
  var res = 0.0;
  res = X - (X / t).floor() * t;
  if (res < 0.0) {
    res += t;
  }
  return res.floor();
}

double mod360(X) {
  return X - (X / 360.0).floor() * 360.0;
}

double calculateNutation(julianDate) {
  var T = (julianDate - 2451545.0) / 36525.0;
  var omg = mod360(125.00452 - T * 1934.136261);
  var ls = mod360(280.4665 + T * 36000.7698);
  var lm = mod360(218.3165 + T * 481267.8813);
  var dpsi = -17.20 * sin4deg(1.0 * omg);

  dpsi += -1.32 * sin4deg(2.0 * ls);
  dpsi += -0.23 * sin4deg(2.0 * lm);
  dpsi += 0.21 * sin4deg(2.0 * omg);

  return dpsi;
}

double calculateEqT(julianDate) {
  var T = (julianDate - 2451545.0) / 36525.0;

  var l0 = mod360(36000.76983 * T);
  l0 = mod360(280.46646 + l0 + 0.0003032 * T * T);
  l0 *= degreesToRadians;

  var M = mod360(35999.05029 * T);
  M = mod360(357.52911 + M - 0.0001537 * T * T);
  M *= degreesToRadians;

  var e = 0.016708634 + T * (-0.000042037 - 0.0000001267 * T);

  var y = calculateOblique(julianDate);
  y = tan4deg(y / 2.0);
  y = y * y;

  var E = y * sin(2 * l0) - 2.0 * e * sin(M);
  E += 4.0 * e * y * sin(M) * cos(2.0 * l0);
  E -= y * y * sin(4.0 * l0) / 2.0;
  E -= 5.0 * e * e * sin(2.0 * M) / 4.0;

  E /= degreesToRadians;
  return (E * 4.0);
}

int calculateDayOfWeek(year, month, day) {
  var julianDate = calculateJulianDateZ(year, month, day);
  var you = (julianDate + 1) % 7;
  return you;
}

bool isLeapYear(year) {
  var chk = false;

  if (year % 4 == 0) {
    chk = true;
  }
  if (year % 100 == 0) {
    chk = false;
  }
  if (year % 400 == 0) {
    chk = true;
  }

  return chk;
}

int maxDay(year, month) {
  var mday = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  var md = mday[month - 1];
  if (2 == month && isLeapYear(year)) {
    md = 29;
  }

  return md;
}

// formula A : Notes Scientifiques et Techniques du Bureau des Longitudes, nr. S055
// from ftp://cyrano-se.obspm.fr/pub/6_documents/4_lunar_tables/newexp.pdf
// formula B : Polynomial Expressions for Delta T
// from https://eclipse.gsfc.nasa.gov/SEhelp/deltatpoly2004.html
// formula C : Delta T : Polynomial Approximation of Time Period 1620-2013
// from https://www.hindawi.com/archive/2014/480964/ (license: CC-BY-3.0)
double correctTDT(julianDate) {
  var year = (julianDate - 2451545.0) / 365.2425 + 2000.0;
  double t, dt;

  if (year < 948) {
    // formula A.26
    t = (julianDate - 2451545.0) / 36525.0;
    dt = 2177.0 + t * (497.0 + t * 44.1);
  } else if (year < 1600) {
    // formula A.25
    t = (julianDate - 2451545.0) / 36525.0;
    dt = 102.0 + t * (102.0 + t * 25.3);
  } else if (year < 1620) {
    // formula B
    t = year - 1600;
    dt = 120 + t * (-0.9808 + t * (-0.01532 + t / 7129));
  } else if (year < 2014) {
    // formula C
    // last elements are sentinels.
    var tep = [1620, 1673, 1730, 1798, 1844, 1878, 1905, 1946, 1990, 2014];
    var tk = [
      3.670,
      3.120,
      2.495,
      1.925,
      1.525,
      1.220,
      0.880,
      0.455,
      0.115,
      0.000
    ];
    var ta0 = [
      76.541,
      10.872,
      13.480,
      12.584,
      6.364,
      -5.058,
      13.392,
      30.782,
      55.281,
      0.000
    ];
    var ta1 = [
      -253.532,
      -40.744,
      13.075,
      1.929,
      11.004,
      -1.701,
      128.592,
      34.348,
      91.248,
      0.000
    ];
    var ta2 = [
      695.901,
      236.890,
      8.635,
      60.896,
      407.776,
      -46.403,
      -279.165,
      46.452,
      87.202,
      0.000
    ];
    var ta3 = [
      -1256.982,
      -351.537,
      -3.307,
      -1432.216,
      -4168.394,
      -866.171,
      -1282.050,
      1295.550,
      -3092.565,
      0.000
    ];
    var ta4 = [
      627.152,
      36.612,
      -128.294,
      3129.071,
      7561.686,
      5917.585,
      4039.490,
      -3210.913,
      8255.422,
      0.000
    ];

    var i = 0;
    for (var j = 0; j < tep.length; j++) {
      if (tep[j] <= year && year < tep[j + 1]) {
        i = j;
        break;
      }
    }
    var k = tk[i];
    var a0 = ta0[i];
    var a1 = ta1[i];
    var a2 = ta2[i];
    var a3 = ta3[i];
    var a4 = ta4[i];

    var u = k + (year - 2000) / 100;
    dt = a0 + u * (a1 + u * (a2 + u * (a3 + u * a4)));
  } else {
    // formula A.25
    t = (julianDate - 2451545.0) / 36525.0;
    dt = 102.0 + t * (102.0 + t * 25.3);
    if (year < 2100) {
      dt += 0.37 * (year - 2100); // from "Astronomical Algorithms" p.78
    }
  }

  dt /= 86400.0;
  return dt;
}

double advanceDate(date, step) {
  List<int> decodedDate = decodeDate(date);
  int julianDateZ =
      calculateJulianDateZ(decodedDate[0], decodedDate[1], decodedDate[2]);
  List<int> convertedCalendar = convertCalendar(julianDateZ + step);
  double encodedDate = encodeDate(
      convertedCalendar[0], convertedCalendar[1], convertedCalendar[2]);

  return encodedDate;
}

int calculateDist(sy, sm, sd, ey, em, ed) {
  return calculateJulianDateZ(ey, em, ed) - calculateJulianDateZ(sy, sm, sd);
}

List<int> decodeDate(date) {
  int year = (date / 10000).floor();
  int month = (date % 10000).floor() / 100;
  int day = date % 100;

  var res = [year, month, day];
  return res;
}

List<int> decodeTime(time) {
  int hour = (time / 100).floor();
  int minute = fmod(time, 100);

  var res = [hour, minute];
  return res;
}

double encodeDate(year, month, day) {
  return year * 10000 + month * 100 + day;
}

double encodeTime(hour, minute) {
  return hour * 100 + minute;
}

String convertDegreeToZodiac(degree) {
  if (degree < 29.59) {
    return '♈︎';
  }
  if (degree < 59.59) {
    return '♉︎';
  }
  if (degree < 89.59) {
    return '♊︎';
  }
  if (degree < 119.59) {
    return '♋︎';
  }
  if (degree < 149.59) {
    return '♌︎';
  }
  if (degree < 179.59) {
    return '♍︎';
  }
  if (degree < 209.59) {
    return '♎︎';
  }
  if (degree < 239.59) {
    return '♏︎';
  }
  if (degree < 269.59) {
    return '♐︎';
  }
  if (degree < 299.59) {
    return '♑︎';
  }
  if (degree < 329.59) {
    return '♒︎';
  }
  return '♓︎';
}
