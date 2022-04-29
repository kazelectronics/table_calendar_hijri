// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart' as intl;
import 'package:table_calendar_hijri/src/widgets/calendar_header.dart';
import 'package:table_calendar_hijri/src/widgets/cell_content.dart';
import 'package:table_calendar_hijri/src/widgets/custom_icon_button.dart';
import 'package:table_calendar_hijri/table_calendar.dart';

import 'common.dart';
import 'package:hijri/hijri_calendar.dart';

final initialFocusedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 15),null);
final today = initialFocusedDay;
final firstDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 5, 15),null);
final lastDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 9, 18),null);

Widget setupTestWidget(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Material(child: child),
  );
}

Widget createTableCalendar({
  HijriAndGregorianDate? focusedDay,
  CalendarFormat calendarFormat = CalendarFormat.month,
  Function(HijriAndGregorianDate)? onPageChanged,
  bool sixWeekMonthsEnforced = false,
}) {
  return setupTestWidget(
    TableCalendar(
      focusedDay: focusedDay ?? initialFocusedDay,
      firstDay: firstDay,
      lastDay: lastDay,
      currentDay: today,
      calendarFormat: calendarFormat,
      onPageChanged: onPageChanged,
      sixWeekMonthsEnforced: sixWeekMonthsEnforced,
    ),
  );
}

ValueKey<String> cellContentKey(DateTime date) {
  return dateToKey(date, prefix: 'CellContent-');
}

void main() {
  group('TableCalendar correctly displays:', () {
    testWidgets(
      'visible day cells for given focusedDay',
      (tester) async {
        await tester.pumpWidget(createTableCalendar());

        final firstVisibleDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 6, 27),null);
        final lastVisibleDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 31),null);

        final focusedDayKey = cellContentKey(initialFocusedDay.gregorianDate);
        final firstVisibleDayKey = cellContentKey(firstVisibleDay.gregorianDate);
        final lastVisibleDayKey = cellContentKey(lastVisibleDay.gregorianDate);

        final startOOBKey =
            cellContentKey(firstVisibleDay.gregorianDate.subtract(const Duration(days: 1)));
        final endOOBKey =
            cellContentKey(lastVisibleDay.gregorianDate.add(const Duration(days: 1)));

        expect(find.byKey(focusedDayKey), findsOneWidget);
        expect(find.byKey(firstVisibleDayKey), findsOneWidget);
        expect(find.byKey(lastVisibleDayKey), findsOneWidget);

        expect(find.byKey(startOOBKey), findsNothing);
        expect(find.byKey(endOOBKey), findsNothing);
      },
    );

    testWidgets(
      'visible day cells after swipe right when in week format',
      (tester) async {
        HijriAndGregorianDate? updatedFocusedDay;

        await tester.pumpWidget(
          createTableCalendar(
            calendarFormat: CalendarFormat.week,
            onPageChanged: (focusedDay) {
              updatedFocusedDay = focusedDay;
            },
          ),
        );

        await tester.drag(
          find.byType(CellContent).first,
          const Offset(500, 0),
        );
        await tester.pumpAndSettle();

        expect(updatedFocusedDay, isNotNull);

        final firstVisibleDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 4),null);
        final lastVisibleDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 10),null);

        final focusedDayKey = cellContentKey(updatedFocusedDay!.gregorianDate);
        final firstVisibleDayKey = cellContentKey(firstVisibleDay.gregorianDate);
        final lastVisibleDayKey = cellContentKey(lastVisibleDay.gregorianDate);

        final startOOBKey =
            cellContentKey(firstVisibleDay.gregorianDate.subtract(const Duration(days: 1)));
        final endOOBKey =
            cellContentKey(lastVisibleDay.gregorianDate.add(const Duration(days: 1)));

        expect(find.byKey(focusedDayKey), findsOneWidget);
        expect(find.byKey(firstVisibleDayKey), findsOneWidget);
        expect(find.byKey(lastVisibleDayKey), findsOneWidget);

        expect(find.byKey(startOOBKey), findsNothing);
        expect(find.byKey(endOOBKey), findsNothing);
      },
    );

    testWidgets(
      'visible day cells after swipe left when in week format',
      (tester) async {
        HijriAndGregorianDate? updatedFocusedDay;

        await tester.pumpWidget(
          createTableCalendar(
            calendarFormat: CalendarFormat.week,
            onPageChanged: (focusedDay) {
              updatedFocusedDay = focusedDay;
            },
          ),
        );

        await tester.drag(
          find.byType(CellContent).first,
          const Offset(-500, 0),
        );
        await tester.pumpAndSettle();

        expect(updatedFocusedDay, isNotNull);

        final firstVisibleDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 18),null);
        final lastVisibleDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 24),null);

        final focusedDayKey = cellContentKey(updatedFocusedDay!.gregorianDate);
        final firstVisibleDayKey = cellContentKey(firstVisibleDay.gregorianDate);
        final lastVisibleDayKey = cellContentKey(lastVisibleDay.gregorianDate);

        final startOOBKey =
            cellContentKey(firstVisibleDay.gregorianDate.subtract(const Duration(days: 1)));
        final endOOBKey =
            cellContentKey(lastVisibleDay.gregorianDate.add(const Duration(days: 1)));

        expect(find.byKey(focusedDayKey), findsOneWidget);
        expect(find.byKey(firstVisibleDayKey), findsOneWidget);
        expect(find.byKey(lastVisibleDayKey), findsOneWidget);

        expect(find.byKey(startOOBKey), findsNothing);
        expect(find.byKey(endOOBKey), findsNothing);
      },
    );

    testWidgets(
      'visible day cells after swipe right when in two weeks format',
      (tester) async {
        HijriAndGregorianDate? updatedFocusedDay;

        await tester.pumpWidget(
          createTableCalendar(
            calendarFormat: CalendarFormat.twoWeeks,
            onPageChanged: (focusedDay) {
              updatedFocusedDay = focusedDay;
            },
          ),
        );

        await tester.drag(
          find.byType(CellContent).first,
          const Offset(500, 0),
        );
        await tester.pumpAndSettle();

        expect(updatedFocusedDay, isNotNull);

        final firstVisibleDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 6, 20),null);
        final lastVisibleDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 3),null);

        final focusedDayKey = cellContentKey(updatedFocusedDay!.gregorianDate);
        final firstVisibleDayKey = cellContentKey(firstVisibleDay.gregorianDate);
        final lastVisibleDayKey = cellContentKey(lastVisibleDay.gregorianDate);

        final startOOBKey =
            cellContentKey(firstVisibleDay.gregorianDate.subtract(const Duration(days: 1)));
        final endOOBKey =
            cellContentKey(lastVisibleDay.gregorianDate.add(const Duration(days: 1)));

        expect(find.byKey(focusedDayKey), findsOneWidget);
        expect(find.byKey(firstVisibleDayKey), findsOneWidget);
        expect(find.byKey(lastVisibleDayKey), findsOneWidget);

        expect(find.byKey(startOOBKey), findsNothing);
        expect(find.byKey(endOOBKey), findsNothing);
      },
    );

    testWidgets(
      'visible day cells after swipe left when in two weeks format',
      (tester) async {
        HijriAndGregorianDate? updatedFocusedDay;

        await tester.pumpWidget(
          createTableCalendar(
            calendarFormat: CalendarFormat.twoWeeks,
            onPageChanged: (focusedDay) {
              updatedFocusedDay = focusedDay;
            },
          ),
        );

        await tester.drag(
          find.byType(CellContent).first,
          const Offset(-500, 0),
        );
        await tester.pumpAndSettle();

        expect(updatedFocusedDay, isNotNull);

        final firstVisibleDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 18),null);
        final lastVisibleDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 31),null);

        final focusedDayKey = cellContentKey(updatedFocusedDay!.gregorianDate);
        final firstVisibleDayKey = cellContentKey(firstVisibleDay.gregorianDate);
        final lastVisibleDayKey = cellContentKey(lastVisibleDay.gregorianDate);

        final startOOBKey =
            cellContentKey(firstVisibleDay.gregorianDate.subtract(const Duration(days: 1)));
        final endOOBKey =
            cellContentKey(lastVisibleDay.gregorianDate.add(const Duration(days: 1)));

        expect(find.byKey(focusedDayKey), findsOneWidget);
        expect(find.byKey(firstVisibleDayKey), findsOneWidget);
        expect(find.byKey(lastVisibleDayKey), findsOneWidget);

        expect(find.byKey(startOOBKey), findsNothing);
        expect(find.byKey(endOOBKey), findsNothing);
      },
    );

    testWidgets(
      '7 day cells in week format',
      (tester) async {
        await tester.pumpWidget(
          createTableCalendar(
            calendarFormat: CalendarFormat.week,
          ),
        );

        var dayCells = tester.widgetList(find.byType(CellContent));
        expect(dayCells.length, 7);
      },
    );

    testWidgets(
      '14 day cells in two weeks format',
      (tester) async {
        await tester.pumpWidget(
          createTableCalendar(
            calendarFormat: CalendarFormat.twoWeeks,
          ),
        );

        var dayCells = tester.widgetList(find.byType(CellContent));
        expect(dayCells.length, 14);
      },
    );

    testWidgets(
      '35 day cells in month format for July 2021',
      (tester) async {
        await tester.pumpWidget(
          createTableCalendar(
            calendarFormat: CalendarFormat.month,
          ),
        );

        var dayCells = tester.widgetList(find.byType(CellContent));
        expect(dayCells.length, 35);
      },
    );

    testWidgets(
      '42 day cells in month format for July 2021, when sixWeekMonthsEnforced is set to true',
      (tester) async {
        await tester.pumpWidget(
          createTableCalendar(
            calendarFormat: CalendarFormat.month,
            sixWeekMonthsEnforced: true,
          ),
        );

        var dayCells = tester.widgetList(find.byType(CellContent));
        expect(dayCells.length, 42);
      },
    );

    testWidgets(
      'CalendarHeader with updated month and year when focusedDay is changed',
      (tester) async {
        await tester.pumpWidget(createTableCalendar());

        String headerText = intl.DateFormat.yMMMM().format(initialFocusedDay.gregorianDate);
        expect(find.byType(CalendarHeader), findsOneWidget);
        expect(find.text(headerText), findsOneWidget);

        final updatedFocusedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 8, 4),null);

        await tester.pumpWidget(
          createTableCalendar(focusedDay: updatedFocusedDay),
        );

        headerText = intl.DateFormat.yMMMM().format(updatedFocusedDay.gregorianDate);
        expect(find.byType(CalendarHeader), findsOneWidget);
        expect(find.text(headerText), findsOneWidget);
      },
    );

    testWidgets(
      'CalendarHeader with updated month and year when TableCalendar is swiped left',
      (tester) async {
        HijriAndGregorianDate? updatedFocusedDay;

        await tester.pumpWidget(
          createTableCalendar(
            onPageChanged: (focusedDay) {
              updatedFocusedDay = focusedDay;
            },
          ),
        );

        String headerText = intl.DateFormat.yMMMM().format(initialFocusedDay.gregorianDate);
        expect(find.byType(CalendarHeader), findsOneWidget);
        expect(find.text(headerText), findsOneWidget);

        await tester.drag(
          find.byType(CellContent).first,
          const Offset(-500, 0),
        );
        await tester.pumpAndSettle();

        expect(updatedFocusedDay, isNotNull);
        expect(updatedFocusedDay!.gregorianDate.month, initialFocusedDay.gregorianDate.month + 1);

        headerText = intl.DateFormat.yMMMM().format(updatedFocusedDay!.gregorianDate);
        expect(find.byType(CalendarHeader), findsOneWidget);
        expect(find.text(headerText), findsOneWidget);

        updatedFocusedDay = null;

        await tester.drag(
          find.byType(CellContent).first,
          const Offset(-500, 0),
        );
        await tester.pumpAndSettle();

        expect(updatedFocusedDay, isNotNull);
        expect(updatedFocusedDay!.gregorianDate.month, initialFocusedDay.gregorianDate.month + 2);

        headerText = intl.DateFormat.yMMMM().format(updatedFocusedDay!.gregorianDate);
        expect(find.byType(CalendarHeader), findsOneWidget);
        expect(find.text(headerText), findsOneWidget);
      },
    );

    testWidgets(
      'CalendarHeader with updated month and year when TableCalendar is swiped right',
      (tester) async {
        HijriAndGregorianDate? updatedFocusedDay;

        await tester.pumpWidget(
          createTableCalendar(
            onPageChanged: (focusedDay) {
              updatedFocusedDay = focusedDay;
            },
          ),
        );

        String headerText = intl.DateFormat.yMMMM().format(initialFocusedDay.gregorianDate);
        expect(find.byType(CalendarHeader), findsOneWidget);
        expect(find.text(headerText), findsOneWidget);

        await tester.drag(
          find.byType(CellContent).first,
          const Offset(500, 0),
        );
        await tester.pumpAndSettle();

        expect(updatedFocusedDay, isNotNull);
        expect(updatedFocusedDay!.gregorianDate.month, initialFocusedDay.gregorianDate.month - 1);

        headerText = intl.DateFormat.yMMMM().format(updatedFocusedDay!.gregorianDate);
        expect(find.byType(CalendarHeader), findsOneWidget);
        expect(find.text(headerText), findsOneWidget);

        updatedFocusedDay = null;

        await tester.drag(
          find.byType(CellContent).first,
          const Offset(500, 0),
        );
        await tester.pumpAndSettle();

        expect(updatedFocusedDay, isNotNull);
        expect(updatedFocusedDay!.gregorianDate.month, initialFocusedDay.gregorianDate.month - 2);

        headerText = intl.DateFormat.yMMMM().format(updatedFocusedDay!.gregorianDate);
        expect(find.byType(CalendarHeader), findsOneWidget);
        expect(find.text(headerText), findsOneWidget);
      },
    );

    testWidgets(
      '3 event markers are visible when 3 events are assigned to a given day',
      (tester) async {
        final eventDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 20),null);

        await tester.pumpWidget(setupTestWidget(
          TableCalendar(
            focusedDay: initialFocusedDay,
            firstDay: firstDay,
            lastDay: lastDay,
            currentDay: today,
            eventLoader: (day) {
              if (day.gregorianDate.day == eventDay.gregorianDate.day && day.gregorianDate.month == eventDay.gregorianDate.month) {
                return ['Event 1', 'Event 2', 'Event 3'];
              }

              return [];
            },
          ),
        ));

        final eventDayKey = cellContentKey(eventDay.gregorianDate);
        final eventDayCellContent = find.byKey(eventDayKey);

        final eventDayStack = find.ancestor(
          of: eventDayCellContent,
          matching: find.byType(Stack),
        );

        final eventMarkers = tester.widgetList(
          find.descendant(
            of: eventDayStack,
            matching: find.byWidgetPredicate(
              (Widget marker) => marker is Container && marker.child == null,
            ),
          ),
        );

        expect(eventMarkers.length, 3);
      },
    );

    testWidgets(
      'currentDay correctly marks given day as today',
      (tester) async {
        await tester.pumpWidget(setupTestWidget(
          TableCalendar(
            focusedDay: initialFocusedDay,
            firstDay: firstDay,
            lastDay: lastDay,
            currentDay: today,
          ),
        ));

        final currentDayKey = cellContentKey(today.gregorianDate);
        final currentDayCellContent =
            tester.widget(find.byKey(currentDayKey)) as CellContent;

        expect(currentDayCellContent.isToday, true);
      },
    );

    testWidgets(
      'if currentDay is absent, DateTime.now() is marked as today',
      (tester) async {
        final now = HijriAndGregorianDate.fromGregorianDate(DateTime.now(),null);
        final firstDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(now.gregorianDate.year, now.gregorianDate.month - 3, now.gregorianDate.day),null);
        final lastDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(now.gregorianDate.year, now.gregorianDate.month + 3, now.gregorianDate.day),null);

        await tester.pumpWidget(setupTestWidget(
          TableCalendar(
            focusedDay: now,
            firstDay: firstDay,
            lastDay: lastDay,
          ),
        ));

        final currentDayKey = cellContentKey(now.gregorianDate);
        final currentDayCellContent =
            tester.widget(find.byKey(currentDayKey)) as CellContent;

        expect(currentDayCellContent.isToday, true);
      },
    );

    testWidgets(
      'selectedDayPredicate correctly marks given day as selected',
      (tester) async {
        final selectedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 20),null);

        await tester.pumpWidget(setupTestWidget(
          TableCalendar(
            focusedDay: initialFocusedDay,
            firstDay: firstDay,
            lastDay: lastDay,
            currentDay: today,
            selectedDayPredicate: (day) {
              return isSameDay(day, selectedDay);
            },
          ),
        ));

        final selectedDayKey = cellContentKey(selectedDay.gregorianDate);
        final selectedDayCellContent =
            tester.widget(find.byKey(selectedDayKey)) as CellContent;

        expect(selectedDayCellContent.isSelected, true);
      },
    );

    testWidgets(
      'holidayPredicate correctly marks given day as holiday',
      (tester) async {
        final holiday = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 20),null);

        await tester.pumpWidget(setupTestWidget(
          TableCalendar(
            focusedDay: initialFocusedDay,
            firstDay: firstDay,
            lastDay: lastDay,
            currentDay: today,
            holidayPredicate: (day) {
              return isSameDay(day, holiday);
            },
          ),
        ));

        final holidayKey = cellContentKey(holiday.gregorianDate);
        final holidayCellContent =
            tester.widget(find.byKey(holidayKey)) as CellContent;

        expect(holidayCellContent.isHoliday, true);
      },
    );
  });

  group('CalendarHeader chevrons test:', () {
    testWidgets(
      'tapping on a left chevron navigates to previous calendar page',
      (tester) async {
        await tester.pumpWidget(createTableCalendar());

        expect(find.text('July 2021'), findsOneWidget);

        final leftChevron = find.widgetWithIcon(
          CustomIconButton,
          Icons.chevron_left,
        );

        await tester.tap(leftChevron);
        await tester.pumpAndSettle();

        expect(find.text('June 2021'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping on a right chevron navigates to next calendar page',
      (tester) async {
        await tester.pumpWidget(createTableCalendar());

        expect(find.text('July 2021'), findsOneWidget);

        final rightChevron = find.widgetWithIcon(
          CustomIconButton,
          Icons.chevron_right,
        );

        await tester.tap(rightChevron);
        await tester.pumpAndSettle();

        expect(find.text('August 2021'), findsOneWidget);
      },
    );
  });

  group('Scrolling boundaries are set up properly:', () {
    testWidgets('starting scroll boundary works correctly', (tester) async {
      final focusedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 6, 15),null);

      await tester.pumpWidget(createTableCalendar(focusedDay: focusedDay));

      expect(find.byType(TableCalendar), findsOneWidget);
      expect(find.text('June 2021'), findsOneWidget);

      await tester.drag(find.byType(CellContent).first, const Offset(500, 0));
      await tester.pumpAndSettle();
      expect(find.text('May 2021'), findsOneWidget);

      await tester.drag(find.byType(CellContent).first, const Offset(500, 0));
      await tester.pumpAndSettle();
      expect(find.text('May 2021'), findsOneWidget);
    });

    testWidgets('ending scroll boundary works correctly', (tester) async {
      final focusedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 8, 15),null);

      await tester.pumpWidget(createTableCalendar(focusedDay: focusedDay));

      expect(find.byType(TableCalendar), findsOneWidget);
      expect(find.text('August 2021'), findsOneWidget);

      await tester.drag(find.byType(CellContent).first, const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(find.text('September 2021'), findsOneWidget);

      await tester.drag(find.byType(CellContent).first, const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(find.text('September 2021'), findsOneWidget);
    });
  });

  group('onFormatChanged callback returns correct values:', () {
    testWidgets('when initial format is month', (tester) async {
      CalendarFormat calendarFormat = CalendarFormat.month;

      await tester.pumpWidget(setupTestWidget(
        TableCalendar(
          focusedDay: today,
          firstDay: firstDay,
          lastDay: lastDay,
          currentDay: today,
          calendarFormat: calendarFormat,
          onFormatChanged: (format) {
            calendarFormat = format;
          },
        ),
      ));

      await tester.drag(find.byType(CellContent).first, const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(calendarFormat, CalendarFormat.twoWeeks);

      await tester.drag(find.byType(CellContent).first, const Offset(0, 500));
      await tester.pumpAndSettle();
      expect(calendarFormat, CalendarFormat.month);
    });

    testWidgets('when initial format is two weeks', (tester) async {
      CalendarFormat calendarFormat = CalendarFormat.twoWeeks;

      await tester.pumpWidget(setupTestWidget(
        TableCalendar(
          focusedDay: today,
          firstDay: firstDay,
          lastDay: lastDay,
          currentDay: today,
          calendarFormat: calendarFormat,
          onFormatChanged: (format) {
            calendarFormat = format;
          },
        ),
      ));

      await tester.drag(find.byType(CellContent).first, const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(calendarFormat, CalendarFormat.week);

      await tester.drag(find.byType(CellContent).first, const Offset(0, 500));
      await tester.pumpAndSettle();
      expect(calendarFormat, CalendarFormat.month);
    });

    testWidgets('when initial format is week', (tester) async {
      CalendarFormat calendarFormat = CalendarFormat.week;

      await tester.pumpWidget(setupTestWidget(
        TableCalendar(
          focusedDay: today,
          firstDay: firstDay,
          lastDay: lastDay,
          currentDay: today,
          calendarFormat: calendarFormat,
          onFormatChanged: (format) {
            calendarFormat = format;
          },
        ),
      ));

      await tester.drag(find.byType(CellContent).first, const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(calendarFormat, CalendarFormat.week);

      await tester.drag(find.byType(CellContent).first, const Offset(0, 500));
      await tester.pumpAndSettle();
      expect(calendarFormat, CalendarFormat.twoWeeks);
    });
  });

  group('onDaySelected callback test:', () {
    testWidgets(
      'selects correct day when tapped',
      (tester) async {
        HijriAndGregorianDate? selectedDay;

        await tester.pumpWidget(setupTestWidget(
          TableCalendar(
            focusedDay: initialFocusedDay,
            firstDay: firstDay,
            lastDay: lastDay,
            currentDay: today,
            onDaySelected: (selected, focused) {
              selectedDay = selected;
            },
          ),
        ));

        expect(selectedDay, isNull);

        final tappedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 18),null);
        final tappedDayKey = cellContentKey(tappedDay.gregorianDate);

        await tester.tap(find.byKey(tappedDayKey));
        await tester.pumpAndSettle();
        expect(selectedDay, tappedDay);
      },
    );

    testWidgets(
      'focuses correct day when tapped',
      (tester) async {
        HijriAndGregorianDate? focusedDay;

        await tester.pumpWidget(setupTestWidget(
          TableCalendar(
            focusedDay: initialFocusedDay,
            firstDay: firstDay,
            lastDay: lastDay,
            currentDay: today,
            onDaySelected: (selected, focused) {
              focusedDay = focused;
            },
          ),
        ));

        expect(focusedDay, isNull);

        final tappedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 18),null);
        final tappedDayKey = cellContentKey(tappedDay.gregorianDate);

        await tester.tap(find.byKey(tappedDayKey));
        await tester.pumpAndSettle();
        expect(focusedDay, tappedDay);
      },
    );

    testWidgets(
      'properly selects and focuses on outside cell tap - previous month (when in month format)',
      (tester) async {
        HijriAndGregorianDate? selectedDay;
        HijriAndGregorianDate? focusedDay;

        await tester.pumpWidget(setupTestWidget(
          TableCalendar(
            focusedDay: initialFocusedDay,
            firstDay: firstDay,
            lastDay: lastDay,
            currentDay: today,
            onDaySelected: (selected, focused) {
              selectedDay = selected;
              focusedDay = focused;
            },
          ),
        ));

        expect(selectedDay, isNull);
        expect(focusedDay, isNull);

        final tappedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 6, 30),null);
        final tappedDayKey = cellContentKey(tappedDay.gregorianDate);

        final expectedFocusedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 1),null);

        await tester.tap(find.byKey(tappedDayKey));
        await tester.pumpAndSettle();
        expect(selectedDay, tappedDay);
        expect(focusedDay, expectedFocusedDay);
      },
    );

    testWidgets(
      'properly selects and focuses on outside cell tap - next month (when in month format)',
      (tester) async {
        HijriAndGregorianDate? selectedDay;
        HijriAndGregorianDate? focusedDay;

        await tester.pumpWidget(setupTestWidget(
          TableCalendar(
            focusedDay: HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 8, 16),null),
            firstDay: firstDay,
            lastDay: lastDay,
            currentDay: HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 8, 16),null),
            onDaySelected: (selected, focused) {
              selectedDay = selected;
              focusedDay = focused;
            },
          ),
        ));

        expect(selectedDay, isNull);
        expect(focusedDay, isNull);

        final tappedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 9, 1),null);
        final tappedDayKey = cellContentKey(tappedDay.gregorianDate);

        final expectedFocusedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 8, 31),null);

        await tester.tap(find.byKey(tappedDayKey));
        await tester.pumpAndSettle();
        expect(selectedDay, tappedDay);
        expect(focusedDay, expectedFocusedDay);
      },
    );
  });

  group('onDayLongPressed callback test:', () {
    testWidgets(
      'selects correct day when long pressed',
      (tester) async {
        HijriAndGregorianDate? selectedDay;

        await tester.pumpWidget(setupTestWidget(
          TableCalendar(
            focusedDay: initialFocusedDay,
            firstDay: firstDay,
            lastDay: lastDay,
            currentDay: today,
            onDayLongPressed: (selected, focused) {
              selectedDay = selected;
            },
          ),
        ));

        expect(selectedDay, isNull);

        final longPressedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 18),null);
        final longPressedDayKey = cellContentKey(longPressedDay.gregorianDate);

        await tester.longPress(find.byKey(longPressedDayKey));
        await tester.pumpAndSettle();
        expect(selectedDay, longPressedDay);
      },
    );

    testWidgets(
      'focuses correct day when long pressed',
      (tester) async {
        HijriAndGregorianDate? focusedDay;

        await tester.pumpWidget(setupTestWidget(
          TableCalendar(
            focusedDay: initialFocusedDay,
            firstDay: firstDay,
            lastDay: lastDay,
            currentDay: today,
            onDayLongPressed: (selected, focused) {
              focusedDay = focused;
            },
          ),
        ));

        expect(focusedDay, isNull);

        final longPressedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 18),null);
        final longPressedDayKey = cellContentKey(longPressedDay.gregorianDate);

        await tester.longPress(find.byKey(longPressedDayKey));
        await tester.pumpAndSettle();
        expect(focusedDay, longPressedDay);
      },
    );

    testWidgets(
      'properly selects and focuses on outside cell long press - previous month (when in month format)',
      (tester) async {
        HijriAndGregorianDate? selectedDay;
        HijriAndGregorianDate? focusedDay;

        await tester.pumpWidget(setupTestWidget(
          TableCalendar(
            focusedDay: initialFocusedDay,
            firstDay: firstDay,
            lastDay: lastDay,
            currentDay: today,
            onDayLongPressed: (selected, focused) {
              selectedDay = selected;
              focusedDay = focused;
            },
          ),
        ));

        expect(selectedDay, isNull);
        expect(focusedDay, isNull);

        final longPressedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 6, 30),null);
        final longPressedDayKey = cellContentKey(longPressedDay.gregorianDate);

        final expectedFocusedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 1),null);

        await tester.longPress(find.byKey(longPressedDayKey));
        await tester.pumpAndSettle();
        expect(selectedDay, longPressedDay);
        expect(focusedDay, expectedFocusedDay);
      },
    );

    testWidgets(
      'properly selects and focuses on outside cell long press - next month (when in month format)',
      (tester) async {
        HijriAndGregorianDate? selectedDay;
        HijriAndGregorianDate? focusedDay;

        await tester.pumpWidget(setupTestWidget(
          TableCalendar(
            focusedDay: HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 8, 16),null),
            firstDay: firstDay,
            lastDay: lastDay,
            currentDay: HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 8, 16),null),
            onDayLongPressed: (selected, focused) {
              selectedDay = selected;
              focusedDay = focused;
            },
          ),
        ));

        expect(selectedDay, isNull);
        expect(focusedDay, isNull);

        final longPressedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 9, 1),null);
        final longPressedDayKey = cellContentKey(longPressedDay.gregorianDate);

        final expectedFocusedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 8, 31),null);

        await tester.longPress(find.byKey(longPressedDayKey));
        await tester.pumpAndSettle();
        expect(selectedDay, longPressedDay);
        expect(focusedDay, expectedFocusedDay);
      },
    );
  });

  group('onRangeSelection callback test:', () {
    testWidgets(
      'proper values are returned when second tapped day is after the first one',
      (tester) async {
        HijriAndGregorianDate? rangeStart;
        HijriAndGregorianDate? rangeEnd;
        HijriAndGregorianDate? focusedDay;

        await tester.pumpWidget(setupTestWidget(
          TableCalendar(
            focusedDay: initialFocusedDay,
            firstDay: firstDay,
            lastDay: lastDay,
            currentDay: today,
            rangeSelectionMode: RangeSelectionMode.enforced,
            onRangeSelected: (start, end, focused) {
              rangeStart = start;
              rangeEnd = end;
              focusedDay = focused;
            },
          ),
        ));

        expect(rangeStart, isNull);
        expect(rangeEnd, isNull);
        expect(focusedDay, isNull);

        final firstTappedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 8),null);
        final secondTappedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 21),null);

        final firstTappedDayKey = cellContentKey(firstTappedDay.gregorianDate);
        final secondTappedDayKey = cellContentKey(secondTappedDay.gregorianDate);

        final expectedFocusedDay = secondTappedDay;

        await tester.tap(find.byKey(firstTappedDayKey));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(secondTappedDayKey));
        await tester.pumpAndSettle();
        expect(rangeStart, firstTappedDay);
        expect(rangeEnd, secondTappedDay);
        expect(focusedDay, expectedFocusedDay);
      },
    );

    testWidgets(
      'proper values are returned when second tapped day is before the first one',
      (tester) async {
        HijriAndGregorianDate? rangeStart;
        HijriAndGregorianDate? rangeEnd;
        HijriAndGregorianDate? focusedDay;

        await tester.pumpWidget(setupTestWidget(
          TableCalendar(
            focusedDay: initialFocusedDay,
            firstDay: firstDay,
            lastDay: lastDay,
            currentDay: today,
            rangeSelectionMode: RangeSelectionMode.enforced,
            onRangeSelected: (start, end, focused) {
              rangeStart = start;
              rangeEnd = end;
              focusedDay = focused;
            },
          ),
        ));

        expect(rangeStart, isNull);
        expect(rangeEnd, isNull);
        expect(focusedDay, isNull);

        final firstTappedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 14),null);
        final secondTappedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 7),null);

        final firstTappedDayKey = cellContentKey(firstTappedDay.gregorianDate);
        final secondTappedDayKey = cellContentKey(secondTappedDay.gregorianDate);

        final expectedFocusedDay = secondTappedDay;

        await tester.tap(find.byKey(firstTappedDayKey));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(secondTappedDayKey));
        await tester.pumpAndSettle();
        expect(rangeStart, secondTappedDay);
        expect(rangeEnd, firstTappedDay);
        expect(focusedDay, expectedFocusedDay);
      },
    );

    testWidgets(
      'long press toggles rangeSelectionMode when onDayLongPress callback is null - initial mode is toggledOff',
      (tester) async {
        HijriAndGregorianDate? rangeStart;
        HijriAndGregorianDate? rangeEnd;
        HijriAndGregorianDate? focusedDay;
        HijriAndGregorianDate? selectedDay;

        await tester.pumpWidget(setupTestWidget(
          TableCalendar(
            focusedDay: initialFocusedDay,
            firstDay: firstDay,
            lastDay: lastDay,
            currentDay: today,
            rangeSelectionMode: RangeSelectionMode.toggledOff,
            onDaySelected: (selected, focused) {
              selectedDay = selected;
              focusedDay = focused;
            },
            onRangeSelected: (start, end, focused) {
              rangeStart = start;
              rangeEnd = end;
              focusedDay = focused;
            },
            onDayLongPressed: null,
          ),
        ));

        expect(rangeStart, isNull);
        expect(rangeEnd, isNull);
        expect(focusedDay, isNull);
        expect(selectedDay, isNull);

        final firstTappedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 8),null);
        final secondTappedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 21),null);

        final firstTappedDayKey = cellContentKey(firstTappedDay.gregorianDate);
        final secondTappedDayKey = cellContentKey(secondTappedDay.gregorianDate);

        final expectedFocusedDay = secondTappedDay;

        await tester.longPress(find.byKey(firstTappedDayKey));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(firstTappedDayKey));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(secondTappedDayKey));
        await tester.pumpAndSettle();
        expect(rangeStart, firstTappedDay);
        expect(rangeEnd, secondTappedDay);
        expect(focusedDay, expectedFocusedDay);
        expect(selectedDay, isNull);
      },
    );

    testWidgets(
      'long press toggles rangeSelectionMode when onDayLongPress callback is null - initial mode is toggledOn',
      (tester) async {
        HijriAndGregorianDate? rangeStart;
        HijriAndGregorianDate? rangeEnd;
        HijriAndGregorianDate? focusedDay;
        HijriAndGregorianDate? selectedDay;

        await tester.pumpWidget(setupTestWidget(
          TableCalendar(
            focusedDay: initialFocusedDay,
            firstDay: firstDay,
            lastDay: lastDay,
            currentDay: today,
            rangeSelectionMode: RangeSelectionMode.toggledOn,
            onDaySelected: (selected, focused) {
              selectedDay = selected;
              focusedDay = focused;
            },
            onRangeSelected: (start, end, focused) {
              rangeStart = start;
              rangeEnd = end;
              focusedDay = focused;
            },
            onDayLongPressed: null,
          ),
        ));

        expect(rangeStart, isNull);
        expect(rangeEnd, isNull);
        expect(focusedDay, isNull);
        expect(selectedDay, isNull);

        final firstTappedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 8),null);
        final secondTappedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 21),null);

        final firstTappedDayKey = cellContentKey(firstTappedDay.gregorianDate);
        final secondTappedDayKey = cellContentKey(secondTappedDay.gregorianDate);

        final expectedFocusedDay = secondTappedDay;

        await tester.longPress(find.byKey(firstTappedDayKey));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(firstTappedDayKey));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(secondTappedDayKey));
        await tester.pumpAndSettle();
        expect(rangeStart, isNull);
        expect(rangeEnd, isNull);
        expect(focusedDay, expectedFocusedDay);
        expect(selectedDay, secondTappedDay);
      },
    );

    testWidgets(
      'rangeSelectionMode.enforced disables onDaySelected callback',
      (tester) async {
        HijriAndGregorianDate? rangeStart;
        HijriAndGregorianDate? rangeEnd;
        HijriAndGregorianDate? focusedDay;
        HijriAndGregorianDate? selectedDay;

        await tester.pumpWidget(setupTestWidget(
          TableCalendar(
            focusedDay: initialFocusedDay,
            firstDay: firstDay,
            lastDay: lastDay,
            currentDay: today,
            rangeSelectionMode: RangeSelectionMode.enforced,
            onDaySelected: (selected, focused) {
              selectedDay = selected;
              focusedDay = focused;
            },
            onRangeSelected: (start, end, focused) {
              rangeStart = start;
              rangeEnd = end;
              focusedDay = focused;
            },
            onDayLongPressed: null,
          ),
        ));

        expect(rangeStart, isNull);
        expect(rangeEnd, isNull);
        expect(focusedDay, isNull);
        expect(selectedDay, isNull);

        final firstTappedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 8),null);
        final secondTappedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 21),null);

        final firstTappedDayKey = cellContentKey(firstTappedDay.gregorianDate);
        final secondTappedDayKey = cellContentKey(secondTappedDay.gregorianDate);

        final expectedFocusedDay = secondTappedDay;

        await tester.longPress(find.byKey(firstTappedDayKey));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(firstTappedDayKey));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(secondTappedDayKey));
        await tester.pumpAndSettle();
        expect(rangeStart, firstTappedDay);
        expect(rangeEnd, secondTappedDay);
        expect(focusedDay, expectedFocusedDay);
        expect(selectedDay, isNull);
      },
    );

    testWidgets(
      'rangeSelectionMode.disabled enforces onDaySelected callback',
      (tester) async {
        HijriAndGregorianDate? rangeStart;
        HijriAndGregorianDate? rangeEnd;
        HijriAndGregorianDate? focusedDay;
        HijriAndGregorianDate? selectedDay;

        await tester.pumpWidget(setupTestWidget(
          TableCalendar(
            focusedDay: initialFocusedDay,
            firstDay: firstDay,
            lastDay: lastDay,
            currentDay: today,
            rangeSelectionMode: RangeSelectionMode.disabled,
            onDaySelected: (selected, focused) {
              selectedDay = selected;
              focusedDay = focused;
            },
            onRangeSelected: (start, end, focused) {
              rangeStart = start;
              rangeEnd = end;
              focusedDay = focused;
            },
            onDayLongPressed: null,
          ),
        ));

        expect(rangeStart, isNull);
        expect(rangeEnd, isNull);
        expect(focusedDay, isNull);
        expect(selectedDay, isNull);

        final firstTappedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 8),null);
        final secondTappedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 21),null);

        final firstTappedDayKey = cellContentKey(firstTappedDay.gregorianDate);
        final secondTappedDayKey = cellContentKey(secondTappedDay.gregorianDate);

        final expectedFocusedDay = secondTappedDay;

        await tester.longPress(find.byKey(firstTappedDayKey));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(firstTappedDayKey));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(secondTappedDayKey));
        await tester.pumpAndSettle();
        expect(rangeStart, isNull);
        expect(rangeEnd, isNull);
        expect(focusedDay, expectedFocusedDay);
        expect(selectedDay, secondTappedDay);
      },
    );
  });

  group('Range selection test:', () {
    testWidgets(
      'range selection has correct start and end point',
      (tester) async {
        final rangeStart = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 8),null);
        final rangeEnd = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 21),null);

        await tester.pumpWidget(setupTestWidget(
          TableCalendar(
            focusedDay: initialFocusedDay,
            firstDay: firstDay,
            lastDay: lastDay,
            currentDay: today,
            rangeStartDay: rangeStart,
            rangeEndDay: rangeEnd,
          ),
        ));

        final rangeStartKey = cellContentKey(rangeStart.gregorianDate);
        final rangeStartCellContent =
            tester.widget(find.byKey(rangeStartKey)) as CellContent;

        expect(rangeStartCellContent.isRangeStart, true);
        expect(rangeStartCellContent.isRangeEnd, false);
        expect(rangeStartCellContent.isWithinRange, true);

        final rangeEndKey = cellContentKey(rangeEnd.gregorianDate);
        final rangeEndCellContent =
            tester.widget(find.byKey(rangeEndKey)) as CellContent;

        expect(rangeEndCellContent.isRangeStart, false);
        expect(rangeEndCellContent.isRangeEnd, true);
        expect(rangeEndCellContent.isWithinRange, true);
      },
    );

    testWidgets(
      'days within range selection are marked as inWithinRange',
      (tester) async {
        final rangeStart = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 8),null);
        final rangeEnd = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 13),null);

        await tester.pumpWidget(setupTestWidget(
          TableCalendar(
            focusedDay: initialFocusedDay,
            firstDay: firstDay,
            lastDay: lastDay,
            currentDay: today,
            rangeStartDay: rangeStart,
            rangeEndDay: rangeEnd,
          ),
        ));

        final dayCount = rangeEnd.gregorianDate.difference(rangeStart.gregorianDate).inDays - 1;
        expect(dayCount, 4);

        for (int i = 1; i <= dayCount; i++) {
          final testDay = rangeStart.gregorianDate.add(Duration(days: i));

          expect(testDay.isAfter(rangeStart.gregorianDate), true);
          expect(testDay.isBefore(rangeEnd.gregorianDate), true);

          final testDayKey = cellContentKey(testDay);
          final testDayCellContent =
              tester.widget(find.byKey(testDayKey)) as CellContent;

          expect(testDayCellContent.isWithinRange, true);
        }
      },
    );

    testWidgets(
      'days outside range selection are not marked as inWithinRange',
      (tester) async {
        final rangeStart = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 8),null);
        final rangeEnd = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(2021, 7, 13),null);

        await tester.pumpWidget(setupTestWidget(
          TableCalendar(
            focusedDay: initialFocusedDay,
            firstDay: firstDay,
            lastDay: lastDay,
            currentDay: today,
            rangeStartDay: rangeStart,
            rangeEndDay: rangeEnd,
          ),
        ));

        final oobStart = rangeStart.gregorianDate.subtract(const Duration(days: 1));
        final oobEnd = rangeEnd.gregorianDate.add(const Duration(days: 1));

        final oobStartKey = cellContentKey(oobStart);
        final oobStartCellContent =
            tester.widget(find.byKey(oobStartKey)) as CellContent;

        final oobEndKey = cellContentKey(oobEnd);
        final oobEndCellContent =
            tester.widget(find.byKey(oobEndKey)) as CellContent;

        expect(oobStartCellContent.isWithinRange, false);
        expect(oobEndCellContent.isWithinRange, false);
      },
    );
  });
}
