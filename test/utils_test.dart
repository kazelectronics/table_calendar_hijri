// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter_test/flutter_test.dart';
import 'package:table_calendar_hijri/src/shared/utils.dart';
import 'package:hijri/hijri_calendar.dart';

void main() {
  group('isSameDay() tests:', () {
    test('Same day, different time', () {
      final dateA = HijriAndGregorianDate.fromGregorianDate(DateTime(2020, 5, 10, 4, 32, 16),null);
      final dateB = HijriAndGregorianDate.fromGregorianDate(DateTime(2020, 5, 10, 8, 21, 44),null);

      expect(isSameDay(dateA, dateB), true);
    });

    test('Different day, same time', () {
      final dateA = HijriAndGregorianDate.fromGregorianDate(DateTime(2020, 5, 10, 4, 32, 16),null);
      final dateB = HijriAndGregorianDate.fromGregorianDate(DateTime(2020, 5, 11, 4, 32, 16),null);

      expect(isSameDay(dateA, dateB), false);
    });

    test('UTC and local time zone', () {
      final dateA = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2020, 5, 10),null);
      final dateB = HijriAndGregorianDate.fromGregorianDate(DateTime(2020, 5, 10),null);

      expect(isSameDay(dateA, dateB), true);
    });
  });

  group('normalizeDate() tests:', () {
    test('Local time zone gets converted to UTC', () {
      final dateA = HijriAndGregorianDate.fromGregorianDate(DateTime(2020, 5, 10, 4, 32, 16),null);
      final dateB = normalizeDate(dateA,null);

      expect(dateB.gregorianDate.isUtc, true);
    });

    test('Date is unchanged', () {
      final dateA = HijriAndGregorianDate.fromGregorianDate(DateTime(2020, 5, 10, 4, 32, 16),null);
      final dateB = normalizeDate(dateA,null);

      expect(dateB.gregorianDate.year, 2020);
      expect(dateB.gregorianDate.month, 5);
      expect(dateB.gregorianDate.day, 10);
    });

    test('Time gets trimmed', () {
      final dateA = HijriAndGregorianDate.fromGregorianDate(DateTime(2020, 5, 10, 4, 32, 16),null);
      final dateB = normalizeDate(dateA,null);

      expect(dateB.gregorianDate.hour, 0);
      expect(dateB.gregorianDate.minute, 0);
      expect(dateB.gregorianDate.second, 0);
      expect(dateB.gregorianDate.millisecond, 0);
      expect(dateB.gregorianDate.microsecond, 0);
    });
  });

  group('getWeekdayNumber() tests:', () {
    test('Monday returns number 1', () {
      expect(getWeekdayNumber(StartingDayOfWeek.monday), 1);
    });

    test('Sunday returns number 7', () {
      expect(getWeekdayNumber(StartingDayOfWeek.sunday), 7);
    });
  });
}
