// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:table_calendar_example/pages/basics_example.dart';
import 'package:table_calendar_hijri/table_calendar.dart';

import '../utils.dart';
import 'package:hijri/hijri_calendar.dart';

class TableMultiExample extends StatefulWidget {
  @override
  _TableMultiExampleState createState() => _TableMultiExampleState();
}

class _TableMultiExampleState extends State<TableMultiExample> {
  final ValueNotifier<List<Event>> _selectedEvents = ValueNotifier([]);

  // Using a `LinkedHashSet` is recommended due to equality comparison override
  final Set<HijriAndGregorianDate> _selectedDays = LinkedHashSet<HijriAndGregorianDate>(
    equals: _isSameDay,
    hashCode: getHashCode,
  );

  CalendarFormat _calendarFormat = CalendarFormat.month;
  HijriAndGregorianDate _focusedDay = HijriAndGregorianDate.fromGregorianDate(DateTime.now(),null);

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  static bool _isSameDay(HijriAndGregorianDate? a, HijriAndGregorianDate? b) {
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

  List<Event> _getEventsForDay(HijriAndGregorianDate day) {
    // Implementation example
    return kEvents[day] ?? [];
  }

  List<Event> _getEventsForDays(Set<HijriAndGregorianDate> days) {
    // Implementation example
    // Note that days are in selection order (same applies to events)
    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(HijriAndGregorianDate selectedDay, HijriAndGregorianDate focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      // Update values in a Set
      if (_selectedDays.contains(selectedDay)) {
        _selectedDays.remove(selectedDay);
      } else {
        _selectedDays.add(selectedDay);
      }
    });

    _selectedEvents.value = _getEventsForDays(_selectedDays);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TableCalendar - Multi'),
      ),
      body: Column(
        children: [
          TableCalendar<Event>(
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) {
              // Use values from Set to mark multiple days as selected
              return _selectedDays.contains(day);
            },
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            showHijriDate: true,
            showGregorianDate: true,
            adjustHijriDateByDays: 0,
            hijriHasPreference: true,
          ),
          ElevatedButton(
            child: Text('Clear selection'),
            onPressed: () {
              setState(() {
                _selectedDays.clear();
                _selectedEvents.value = [];
              });
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        onTap: () => print('${value[index]}'),
                        title: Text('${value[index]}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
