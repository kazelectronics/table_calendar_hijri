// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/widgets.dart';
import '../hijri_and_gregorian.dart';

/// Signature for a function that creates a widget for a given `day`.
typedef DayBuilder = Widget? Function(BuildContext context, HijriAndGregorianDate day);

/// Signature for a function that creates a widget for a given `day`.
/// Additionally, contains the currently focused day.
typedef FocusedDayBuilder = Widget? Function(
    BuildContext context, HijriAndGregorianDate day, HijriAndGregorianDate focusedDay);

/// Signature for a function returning text that can be localized and formatted with `DateFormat`.
typedef TextFormatter = String Function(HijriAndGregorianDate date, dynamic locale);

/// Gestures available for the calendar.
enum AvailableGestures { none, verticalSwipe, horizontalSwipe, all }

/// Formats that the calendar can display.
enum CalendarFormat { month, twoWeeks, week }

/// Days of the week that the calendar can start with.
enum StartingDayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

/// Returns a numerical value associated with given `weekday`.
///
/// Returns 1 for `StartingDayOfWeek.monday`, all the way to 7 for `StartingDayOfWeek.sunday`.
int getWeekdayNumber(StartingDayOfWeek weekday) {
  return StartingDayOfWeek.values.indexOf(weekday) + 1;
}

/// Returns `date` in UTC format, without its time part.
HijriAndGregorianDate normalizeDate(HijriAndGregorianDate date, int? offset) {
  return HijriAndGregorianDate.fromGregorianDate(DateTime.utc(date.gregorianDate.year, date.gregorianDate.month, date.gregorianDate.day),offset);
}

/// Checks if two DateTime objects are the same day.
/// Returns `false` if either of them is null.
bool isSameDay(HijriAndGregorianDate? a, HijriAndGregorianDate? b, bool _hijriHasPreference) {
  if (a == null || b == null) {
    return false;
  }

  if (_hijriHasPreference) {
    return a.hijriDate.hYear == b.hijriDate.hYear &&
        a.hijriDate.hMonth == b.hijriDate.hMonth &&
        a.hijriDate.hDay == b.hijriDate.hDay;
  } else {
    return a.gregorianDate.year == b.gregorianDate.year &&
        a.gregorianDate.month == b.gregorianDate.month &&
        a.gregorianDate.day == b.gregorianDate.day;
  }
}