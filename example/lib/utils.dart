// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'dart:collection';

import 'package:hijri/hijri_calendar.dart';

final int adjustDays = 0;
final bool showHijriDate = false;
final bool showGregorianDate = true;
final bool hijriHasPreference = false;

/// Example event class.
class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

/// Example events.
///
/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
final kEvents = LinkedHashMap<HijriAndGregorianDate, List<Event>>(
  equals: _isSameDay,
  hashCode: getHashCode,
)..addAll(_kEventSource);

final _kEventSource = Map.fromIterable(List.generate(50, (index) => index),
    key: (item) => HijriAndGregorianDate.fromGregorianDate(DateTime.utc(kFirstDay.gregorianDate.year, kFirstDay.gregorianDate.month, item * 5),null),
    value: (item) => List.generate(
        item % 4 + 1, (index) => Event('Event $item | ${index + 1}')))
  ..addAll({
    kToday: [
      Event('Today\'s Event 1'),
      Event('Today\'s Event 2'),
    ],
  });

int getHashCode(HijriAndGregorianDate key) {
  return key.gregorianDate.day * 1000000 + key.gregorianDate.month * 10000 + key.gregorianDate.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<HijriAndGregorianDate> daysInRange(HijriAndGregorianDate first, HijriAndGregorianDate last) {
  final dayCount = last.gregorianDate.difference(first.gregorianDate).inDays + 1;
  return List.generate(
    dayCount,
    (index) => HijriAndGregorianDate.fromGregorianDate(DateTime.utc(first.gregorianDate.year, first.gregorianDate.month, first.gregorianDate.day + index),null
  ));
}

final kToday = HijriAndGregorianDate.fromGregorianDate(DateTime.now(),null);
final kFirstDay = HijriAndGregorianDate.fromGregorianDate(DateTime(kToday.gregorianDate.year-1, kToday.gregorianDate.month, kToday.gregorianDate.day),null);
final kLastDay = HijriAndGregorianDate.fromGregorianDate(DateTime(kToday.gregorianDate.year+1, kToday.gregorianDate.month, kToday.gregorianDate.day),null);

bool _isSameDay(HijriAndGregorianDate? a, HijriAndGregorianDate? b) {
  if (a == null || b == null) {
    return false;
  }

  if (hijriHasPreference) {
    return a.hijriDate.hYear == b.hijriDate.hYear &&
      a.hijriDate.hMonth == b.hijriDate.hMonth &&
      a.hijriDate.hDay == b.hijriDate.hDay;
  } else {
    return a.gregorianDate.year == b.gregorianDate.year &&
      a.gregorianDate.month == b.gregorianDate.month &&
      a.gregorianDate.day == b.gregorianDate.day;
  }
}