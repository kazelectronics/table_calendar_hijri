// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_calendar_hijri/src/widgets/calendar_page.dart';
import 'package:hijri/hijri_calendar.dart';

Widget setupTestWidget(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: child,
  );
}

List<HijriAndGregorianDate> visibleDays = getDaysInRange(
  HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 6, 27),null),
  HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 31),null),
);

List<HijriAndGregorianDate> getDaysInRange(HijriAndGregorianDate first, HijriAndGregorianDate last) {
  final dayCount = last.gregorianDate.difference(first.gregorianDate).inDays + 1;
  return List.generate(
    dayCount,
    (index) => HijriAndGregorianDate.fromGregorianDate(DateTime.utc(first.gregorianDate.year, first.gregorianDate.month, first.gregorianDate.day + index),null)
  );
}

void main() {
  testWidgets(
    'CalendarPage lays out all the visible days',
    (tester) async {
      await tester.pumpWidget(
        setupTestWidget(
          CalendarPage(
            visibleDays: visibleDays,
            dayBuilder: (context, day) {
              return Text('${day.gregorianDate.day}');
            },
            dowVisible: false,
          ),
        ),
      );

      final expectedCellCount = visibleDays.length;
      expect(find.byType(Text), findsNWidgets(expectedCellCount));
    },
  );

  testWidgets(
    'CalendarPage lays out 7 DOW labels',
    (tester) async {
      await tester.pumpWidget(
        setupTestWidget(
          CalendarPage(
            visibleDays: visibleDays,
            dayBuilder: (context, day) {
              return Text('${day.gregorianDate.day}');
            },
            dowVisible: true,
            dowBuilder: (context, day) {
              return Text('${day.gregorianDate.weekday}');
            },
          ),
        ),
      );

      final expectedCellCount = visibleDays.length;
      final expectedDowLabels = 7;

      expect(
        find.byType(Text),
        findsNWidgets(expectedCellCount + expectedDowLabels),
      );
    },
  );

  testWidgets(
    'Throw AssertionError when CalendarPage is built with dowVisible set to true, but dowBuilder is absent',
    (tester) async {
      expect(() async {
        await tester.pumpWidget(
          setupTestWidget(
            CalendarPage(
              visibleDays: visibleDays,
              dayBuilder: (context, day) {
                return Text('${day.gregorianDate.day}');
              },
              dowVisible: true,
            ),
          ),
        );
      }, throwsAssertionError);
    },
  );
}
