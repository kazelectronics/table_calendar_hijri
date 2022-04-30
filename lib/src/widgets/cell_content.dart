// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../customization/calendar_builders.dart';
import '../customization/calendar_style.dart';

import '../hijri_and_gregorian.dart';

class CellContent extends StatelessWidget {
  final HijriAndGregorianDate day;
  final HijriAndGregorianDate focusedDay;
  final dynamic locale;
  final bool isTodayHighlighted;
  final bool isToday;
  final bool isSelected;
  final bool isRangeStart;
  final bool isRangeEnd;
  final bool isWithinRange;
  final bool isOutside;
  final bool isDisabled;
  final bool isHoliday;
  final bool isWeekend;
  final CalendarStyle calendarStyle;
  final CalendarBuilders calendarBuilders;
  final bool showHijriDate;
  final bool showGregorianDate;
  final int adjustHijriDateByDays;
  final bool hijriHasPreference;

  const CellContent({
    Key? key,
    required this.day,
    required this.focusedDay,
    required this.calendarStyle,
    required this.calendarBuilders,
    required this.isTodayHighlighted,
    required this.isToday,
    required this.isSelected,
    required this.isRangeStart,
    required this.isRangeEnd,
    required this.isWithinRange,
    required this.isOutside,
    required this.isDisabled,
    required this.isHoliday,
    required this.isWeekend,
    this.locale,
    required this.showHijriDate,
    required this.showGregorianDate,
    required this.adjustHijriDateByDays,
    required this.hijriHasPreference,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dowLabel = DateFormat.EEEE(locale).format(day.gregorianDate);
    final dayLabel = DateFormat.yMMMMd(locale).format(day.gregorianDate);
    final semanticsLabel = '$dowLabel, $dayLabel';

    Widget? cell =
        calendarBuilders.prioritizedBuilder?.call(context, day, focusedDay);

    if (cell != null) {
      return Semantics(
        label: semanticsLabel,
        excludeSemantics: true,
        child: cell,
      );
    }

    final hijriText = (showHijriDate==false)?'':hijriHasPreference?day.hijriDate.toFormat("dd"):"(" + day.hijriDate.toFormat("dd") + ")";
    final text = (showGregorianDate==false)&&(hijriText.isNotEmpty)?'':hijriHasPreference&&(hijriText.isNotEmpty)?"("+'${day.gregorianDate.day}'+")":'${day.gregorianDate.day}';

    final margin = calendarStyle.cellMargin;
    final padding = calendarStyle.cellPadding;
    final alignment = calendarStyle.cellAlignment;
    final duration = const Duration(milliseconds: 250);

    if (isDisabled) {
      cell = calendarBuilders.disabledBuilder?.call(context, day, focusedDay) ??
          AnimatedContainer(
            duration: duration,
            margin: margin,
            padding: padding,
            decoration: calendarStyle.disabledDecoration,
            alignment: alignment,
            child: (hijriText.isEmpty)? Text(text, style: calendarStyle.disabledTextStyle):(text.isEmpty)? Text
              (hijriText, style: calendarStyle.disabledTextStyle):Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(hijriHasPreference?hijriText:text, style: calendarStyle.disabledTextStyle,),
                Text(hijriHasPreference?text:hijriText, style: calendarStyle.disabledDualTextStyle, ),
              ],
            ),
          );
    } else if (isSelected) {
      cell = calendarBuilders.selectedBuilder?.call(context, day, focusedDay) ??
          AnimatedContainer(
            duration: duration,
            margin: margin,
            padding: padding,
            decoration: calendarStyle.selectedDecoration,
            alignment: alignment,
            child: (hijriText.isEmpty)? Text(text, style: calendarStyle.selectedTextStyle):(text.isEmpty)? Text
              (hijriText, style: calendarStyle.selectedTextStyle):Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(hijriHasPreference?hijriText:text, style: calendarStyle.selectedTextStyle,),
                Text(hijriHasPreference?text:hijriText, style: calendarStyle.selectedDualTextStyle, ),
              ],
            ),
          );
    } else if (isRangeStart) {
      cell =
          calendarBuilders.rangeStartBuilder?.call(context, day, focusedDay) ??
              AnimatedContainer(
                duration: duration,
                margin: margin,
                padding: padding,
                decoration: calendarStyle.rangeStartDecoration,
                alignment: alignment,
                child: (hijriText.isEmpty)? Text(text, style: calendarStyle.rangeStartTextStyle):(text.isEmpty)? Text
                  (hijriText, style: calendarStyle.rangeStartTextStyle):Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(hijriHasPreference?hijriText:text, style: calendarStyle.rangeStartTextStyle,),
                    Text(hijriHasPreference?text:hijriText, style: calendarStyle.rangeStartDualTextStyle, ),
                  ],
                ),
              );
    } else if (isRangeEnd) {
      cell = calendarBuilders.rangeEndBuilder?.call(context, day, focusedDay) ??
          AnimatedContainer(
            duration: duration,
            margin: margin,
            padding: padding,
            decoration: calendarStyle.rangeEndDecoration,
            alignment: alignment,
            child: (hijriText.isEmpty)? Text(text, style: calendarStyle.rangeEndTextStyle):(text.isEmpty)? Text
              (hijriText, style: calendarStyle.rangeEndTextStyle):Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(hijriHasPreference?hijriText:text, style: calendarStyle.rangeEndTextStyle,),
                Text(hijriHasPreference?text:hijriText, style: calendarStyle.rangeEndDualTextStyle, ),
              ],
            ),
          );
    } else if (isToday && isTodayHighlighted) {
      cell = calendarBuilders.todayBuilder?.call(context, day, focusedDay) ??
          AnimatedContainer(
            duration: duration,
            margin: margin,
            padding: padding,
            decoration: calendarStyle.todayDecoration,
            alignment: alignment,
            child: (hijriText.isEmpty)? Text(text, style: calendarStyle.todayTextStyle):(text.isEmpty)? Text
              (hijriText, style: calendarStyle.todayTextStyle):Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(hijriHasPreference?hijriText:text, style: calendarStyle.todayTextStyle,),
                Text(hijriHasPreference?text:hijriText, style: calendarStyle.todayDualTextStyle, ),
              ],
            ),
          );
    } else if (isHoliday) {
      cell = calendarBuilders.holidayBuilder?.call(context, day, focusedDay) ??
          AnimatedContainer(
            duration: duration,
            margin: margin,
            padding: padding,
            decoration: calendarStyle.holidayDecoration,
            alignment: alignment,
            child: (hijriText.isEmpty)? Text(text, style: calendarStyle.holidayTextStyle):(text.isEmpty)? Text
              (hijriText, style: calendarStyle.holidayTextStyle):Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(hijriHasPreference?hijriText:text, style: calendarStyle.holidayTextStyle,),
                Text(hijriHasPreference?text:hijriText, style: calendarStyle.holidayDualTextStyle, ),
              ],
            ),
          );
    } else if (isWithinRange) {
      cell =
          calendarBuilders.withinRangeBuilder?.call(context, day, focusedDay) ??
              AnimatedContainer(
                duration: duration,
                margin: margin,
                padding: padding,
                decoration: calendarStyle.withinRangeDecoration,
                alignment: alignment,
                child: (hijriText.isEmpty)? Text(text, style: calendarStyle.withinRangeTextStyle):(text.isEmpty)? Text
                  (hijriText, style: calendarStyle.withinRangeTextStyle):Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(hijriHasPreference?hijriText:text, style: calendarStyle.withinRangeTextStyle,),
                    Text(hijriHasPreference?text:hijriText, style: calendarStyle.withinRangeDualTextStyle, ),
                  ],
                ),
              );
    } else if (isOutside) {
      cell = calendarBuilders.outsideBuilder?.call(context, day, focusedDay) ??
          AnimatedContainer(
            duration: duration,
            margin: margin,
            padding: padding,
            decoration: calendarStyle.outsideDecoration,
            alignment: alignment,
            child: (hijriText.isEmpty)? Text(text, style: calendarStyle.outsideTextStyle):(text.isEmpty)? Text
              (hijriText, style: calendarStyle.outsideTextStyle):Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(hijriHasPreference?hijriText:text, style: calendarStyle.outsideTextStyle,),
                Text(hijriHasPreference?text:hijriText, style: calendarStyle.outsideDualTextStyle, ),
              ],
            ),
          );
    } else {
      cell = calendarBuilders.defaultBuilder?.call(context, day, focusedDay) ??
          AnimatedContainer(
            duration: duration,
            margin: margin,
            padding: padding,
            decoration: isWeekend
                ? calendarStyle.weekendDecoration
                : calendarStyle.defaultDecoration,
            alignment: alignment,
            child: (hijriText.isEmpty)? Text(
                text,
                style: isWeekend
                    ? calendarStyle.weekendTextStyle
                    : calendarStyle.defaultTextStyle,
              ):(text.isEmpty)? Text(
                hijriText,
                style: isWeekend
                    ? calendarStyle.weekendTextStyle
                    : calendarStyle.defaultTextStyle,
              ):Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  hijriHasPreference?hijriText:text,
                  style: isWeekend
                      ? calendarStyle.weekendTextStyle
                      : calendarStyle.defaultTextStyle,
                ),
                Text(
                  hijriHasPreference?text:hijriText,
                  style: isWeekend
                      ? calendarStyle.weekendDualTextStyle
                      : calendarStyle.defaultDualTextStyle,
                ),
              ],
            ),
          );
    }

    return Semantics(
      label: semanticsLabel,
      excludeSemantics: true,
      child: cell,
    );
  }
}
