// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:table_calendar_hijri/table_calendar.dart';

import 'common.dart';
import 'package:hijri/hijri_calendar.dart';

Widget setupTestWidget(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: child,
  );
}

void main() {
  group('Correct days are displayed for given focusedDay when:', () {
    testWidgets(
      'in month format, starting day is Sunday',
      (tester) async {
        final focusedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 15),null);

        await tester.pumpWidget(
          setupTestWidget(
            TableCalendarBase(
              firstDay: HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 5, 15),null),
              lastDay: HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 8, 18),null),
              focusedDay: focusedDay,
              dayBuilder: (context, day, focusedDay) {
                return Text(
                  '${day.gregorianDate.day}',
                  key: dateToKey(day.gregorianDate),
                );
              },
              rowHeight: 52,
              dowVisible: false,
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.sunday,
            ),
          ),
        );

        final firstVisibleDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 6, 27),null);
        final lastVisibleDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 31),null);

        final focusedDayKey = dateToKey(focusedDay.gregorianDate);
        final firstVisibleDayKey = dateToKey(firstVisibleDay.gregorianDate);
        final lastVisibleDayKey = dateToKey(lastVisibleDay.gregorianDate);

        final startOOBKey =
            dateToKey(firstVisibleDay.gregorianDate.subtract(const Duration(days: 1)));
        final endOOBKey =
            dateToKey(lastVisibleDay.gregorianDate.add(const Duration(days: 1)));

        expect(find.byKey(focusedDayKey), findsOneWidget);
        expect(find.byKey(firstVisibleDayKey), findsOneWidget);
        expect(find.byKey(lastVisibleDayKey), findsOneWidget);

        expect(find.byKey(startOOBKey), findsNothing);
        expect(find.byKey(endOOBKey), findsNothing);
      },
    );

    testWidgets(
      'in two weeks format, starting day is Sunday',
      (tester) async {
        final focusedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 15),null);

        await tester.pumpWidget(
          setupTestWidget(
            TableCalendarBase(
              firstDay: HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 5, 15),null),
              lastDay: HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 8, 18),null),
              focusedDay: focusedDay,
              dayBuilder: (context, day, focusedDay) {
                return Text(
                  '${day.gregorianDate.day}',
                  key: dateToKey(day.gregorianDate),
                );
              },
              rowHeight: 52,
              dowVisible: false,
              calendarFormat: CalendarFormat.twoWeeks,
              startingDayOfWeek: StartingDayOfWeek.sunday,
            ),
          ),
        );

        final firstVisibleDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 4),null);
        final lastVisibleDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 17),null);

        final focusedDayKey = dateToKey(focusedDay.gregorianDate);
        final firstVisibleDayKey = dateToKey(firstVisibleDay.gregorianDate);
        final lastVisibleDayKey = dateToKey(lastVisibleDay.gregorianDate);

        final startOOBKey =
            dateToKey(firstVisibleDay.gregorianDate.subtract(const Duration(days: 1)));
        final endOOBKey =
            dateToKey(lastVisibleDay.gregorianDate.add(const Duration(days: 1)));

        expect(find.byKey(focusedDayKey), findsOneWidget);
        expect(find.byKey(firstVisibleDayKey), findsOneWidget);
        expect(find.byKey(lastVisibleDayKey), findsOneWidget);

        expect(find.byKey(startOOBKey), findsNothing);
        expect(find.byKey(endOOBKey), findsNothing);
      },
    );

    testWidgets(
      'in week format, starting day is Sunday',
      (tester) async {
        final focusedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 15),null);

        await tester.pumpWidget(
          setupTestWidget(
            TableCalendarBase(
              firstDay: HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 5, 15),null),
              lastDay: HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 8, 18),null),
              focusedDay: focusedDay,
              dayBuilder: (context, day, focusedDay) {
                return Text(
                  '${day.gregorianDate.day}',
                  key: dateToKey(day.gregorianDate),
                );
              },
              rowHeight: 52,
              dowVisible: false,
              calendarFormat: CalendarFormat.week,
              startingDayOfWeek: StartingDayOfWeek.sunday,
            ),
          ),
        );

        final firstVisibleDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 11),null);
        final lastVisibleDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 17),null);

        final focusedDayKey = dateToKey(focusedDay.gregorianDate);
        final firstVisibleDayKey = dateToKey(firstVisibleDay.gregorianDate);
        final lastVisibleDayKey = dateToKey(lastVisibleDay.gregorianDate);

        final startOOBKey =
            dateToKey(firstVisibleDay.gregorianDate.subtract(const Duration(days: 1)));
        final endOOBKey =
            dateToKey(lastVisibleDay.gregorianDate.add(const Duration(days: 1)));

        expect(find.byKey(focusedDayKey), findsOneWidget);
        expect(find.byKey(firstVisibleDayKey), findsOneWidget);
        expect(find.byKey(lastVisibleDayKey), findsOneWidget);

        expect(find.byKey(startOOBKey), findsNothing);
        expect(find.byKey(endOOBKey), findsNothing);
      },
    );

    testWidgets(
      'in month format, starting day is Monday',
      (tester) async {
        final focusedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 15),null);

        await tester.pumpWidget(
          setupTestWidget(
            TableCalendarBase(
              firstDay: HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 5, 15),null),
              lastDay: HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 8, 18),null),
              focusedDay: focusedDay,
              dayBuilder: (context, day, focusedDay) {
                return Text(
                  '${day.gregorianDate.day}',
                  key: dateToKey(day.gregorianDate),
                );
              },
              rowHeight: 52,
              dowVisible: false,
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
            ),
          ),
        );

        final firstVisibleDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 6, 28),null);
        final lastVisibleDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 8, 1),null);

        final focusedDayKey = dateToKey(focusedDay.gregorianDate);
        final firstVisibleDayKey = dateToKey(firstVisibleDay.gregorianDate);
        final lastVisibleDayKey = dateToKey(lastVisibleDay.gregorianDate);

        final startOOBKey =
            dateToKey(firstVisibleDay.gregorianDate.subtract(const Duration(days: 1)));
        final endOOBKey =
            dateToKey(lastVisibleDay.gregorianDate.add(const Duration(days: 1)));

        expect(find.byKey(focusedDayKey), findsOneWidget);
        expect(find.byKey(firstVisibleDayKey), findsOneWidget);
        expect(find.byKey(lastVisibleDayKey), findsOneWidget);

        expect(find.byKey(startOOBKey), findsNothing);
        expect(find.byKey(endOOBKey), findsNothing);
      },
    );

    testWidgets(
      'in two weeks format, starting day is Monday',
      (tester) async {
        final focusedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 15),null);

        await tester.pumpWidget(
          setupTestWidget(
            TableCalendarBase(
              firstDay: HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 5, 15),null),
              lastDay: HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 8, 18),null),
              focusedDay: focusedDay,
              dayBuilder: (context, day, focusedDay) {
                return Text(
                  '${day.gregorianDate.day}',
                  key: dateToKey(day.gregorianDate),
                );
              },
              rowHeight: 52,
              dowVisible: false,
              calendarFormat: CalendarFormat.twoWeeks,
              startingDayOfWeek: StartingDayOfWeek.monday,
            ),
          ),
        );

        final firstVisibleDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 5),null);
        final lastVisibleDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 18),null);

        final focusedDayKey = dateToKey(focusedDay.gregorianDate);
        final firstVisibleDayKey = dateToKey(firstVisibleDay.gregorianDate);
        final lastVisibleDayKey = dateToKey(lastVisibleDay.gregorianDate);

        final startOOBKey =
            dateToKey(firstVisibleDay.gregorianDate.subtract(const Duration(days: 1)));
        final endOOBKey =
            dateToKey(lastVisibleDay.gregorianDate.add(const Duration(days: 1)));

        expect(find.byKey(focusedDayKey), findsOneWidget);
        expect(find.byKey(firstVisibleDayKey), findsOneWidget);
        expect(find.byKey(lastVisibleDayKey), findsOneWidget);

        expect(find.byKey(startOOBKey), findsNothing);
        expect(find.byKey(endOOBKey), findsNothing);
      },
    );

    testWidgets(
      'in week format, starting day is Monday',
      (tester) async {
        final focusedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 15),null);

        await tester.pumpWidget(
          setupTestWidget(
            TableCalendarBase(
              firstDay: HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 5, 15),null),
              lastDay: HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 8, 18),null),
              focusedDay: focusedDay,
              dayBuilder: (context, day, focusedDay) {
                return Text(
                  '${day.gregorianDate.day}',
                  key: dateToKey(day.gregorianDate),
                );
              },
              rowHeight: 52,
              dowVisible: false,
              calendarFormat: CalendarFormat.week,
              startingDayOfWeek: StartingDayOfWeek.monday,
            ),
          ),
        );

        final firstVisibleDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 12),null);
        final lastVisibleDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 18),null);

        final focusedDayKey = dateToKey(focusedDay.gregorianDate);
        final firstVisibleDayKey = dateToKey(firstVisibleDay.gregorianDate);
        final lastVisibleDayKey = dateToKey(lastVisibleDay.gregorianDate);

        final startOOBKey =
            dateToKey(firstVisibleDay.gregorianDate.subtract(const Duration(days: 1)));
        final endOOBKey =
            dateToKey(lastVisibleDay.gregorianDate.add(const Duration(days: 1)));

        expect(find.byKey(focusedDayKey), findsOneWidget);
        expect(find.byKey(firstVisibleDayKey), findsOneWidget);
        expect(find.byKey(lastVisibleDayKey), findsOneWidget);

        expect(find.byKey(startOOBKey), findsNothing);
        expect(find.byKey(endOOBKey), findsNothing);
      },
    );
  });

  testWidgets(
    'Callbacks return expected values',
    (tester) async {
      HijriAndGregorianDate focusedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 15),null);
      final nextMonth = focusedDay.gregorianDate.add(const Duration(days: 31)).month;

      bool calendarCreatedFlag = false;
      SwipeDirection? verticalSwipeDirection;

      await tester.pumpWidget(
        setupTestWidget(
          TableCalendarBase(
            firstDay: HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 5, 15),null),
            lastDay: HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 8, 18),null),
            focusedDay: focusedDay,
            dayBuilder: (context, day, focusedDay) {
              return Text(
                '${day.gregorianDate.day}',
                key: dateToKey(day.gregorianDate),
              );
            },
            onCalendarCreated: (pageController) {
              calendarCreatedFlag = true;
            },
            onPageChanged: (focusedDay2) {
              focusedDay = focusedDay2;
            },
            onVerticalSwipe: (direction) {
              verticalSwipeDirection = direction;
            },
            rowHeight: 52,
            dowVisible: false,
          ),
        ),
      );

      expect(calendarCreatedFlag, true);

      // Swipe left
      await tester.drag(
        find.byKey(dateToKey(focusedDay.gregorianDate)),
        const Offset(-500, 0),
      );
      await tester.pumpAndSettle();
      expect(focusedDay.gregorianDate.month, nextMonth);

      // Swipe up
      await tester.drag(
        find.byKey(dateToKey(focusedDay.gregorianDate)),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();
      expect(verticalSwipeDirection, SwipeDirection.up);
    },
  );

  testWidgets(
    'Throw AssertionError when TableCalendarBase is built with dowVisible and dowBuilder, but dowHeight is absent',
    (tester) async {
      expect(() async {
        await tester.pumpWidget(
          setupTestWidget(
            TableCalendarBase(
              firstDay: HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 5, 15),null),
              lastDay: HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 8, 18),null),
              focusedDay: HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 15),null),
              dayBuilder: (context, day, focusedDay) {
                return Text(
                  '${day.gregorianDate.day}',
                  key: dateToKey(day.gregorianDate),
                );
              },
              rowHeight: 52,
              dowVisible: true,
              dowBuilder: (context, day) {
                return Text('${day.gregorianDate.weekday}');
              },
            ),
          ),
        );
      }, throwsAssertionError);
    },
  );
}
