// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../customization/header_style.dart';
import '../shared/utils.dart' show CalendarFormat, DayBuilder;
import 'custom_icon_button.dart';
import 'format_button.dart';
import '../hijri_and_gregorian.dart';


class CalendarHeader extends StatelessWidget {
  final dynamic locale;
  final HijriAndGregorianDate focusedMonth;
  final CalendarFormat calendarFormat;
  final HeaderStyle headerStyle;
  final VoidCallback onLeftChevronTap;
  final VoidCallback onRightChevronTap;
  final VoidCallback onHeaderTap;
  final VoidCallback onHeaderLongPress;
  final ValueChanged<CalendarFormat> onFormatButtonTap;
  final Map<CalendarFormat, String> availableCalendarFormats;
  final DayBuilder? headerTitleBuilder;
  final bool showHijriDate;
  final bool showGregorianDate;
  final int adjustHijriDateByDays;
  final bool hijriHasPreference;

  const CalendarHeader({
    Key? key,
    this.locale,
    required this.focusedMonth,
    required this.calendarFormat,
    required this.headerStyle,
    required this.onLeftChevronTap,
    required this.onRightChevronTap,
    required this.onHeaderTap,
    required this.onHeaderLongPress,
    required this.onFormatButtonTap,
    required this.availableCalendarFormats,
    this.headerTitleBuilder,
    required this.showHijriDate,
    required this.showGregorianDate,
    required this.adjustHijriDateByDays,
    required this.hijriHasPreference,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hijriText = (showHijriDate==false)?'':focusedMonth.getHijriMonthHeader(_firstDayOfMonth(focusedMonth),_lastDayOfMonth(focusedMonth),hijriHasPreference);
    final text = (showGregorianDate==false)&&(hijriText.isNotEmpty)?'':focusedMonth.getGregorianMonthHeader(locale, _firstDayOfMonth(focusedMonth),_lastDayOfMonth(focusedMonth),hijriHasPreference);

    return Container(
      decoration: headerStyle.decoration,
      margin: headerStyle.headerMargin,
      padding: headerStyle.headerPadding,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          if (headerStyle.leftChevronVisible)
            CustomIconButton(
              icon: headerStyle.leftChevronIcon,
              onTap: onLeftChevronTap,
              margin: headerStyle.leftChevronMargin,
              padding: headerStyle.leftChevronPadding,
            ),
          Expanded(
            child: headerTitleBuilder?.call(context, focusedMonth) ??
                GestureDetector(
                  onTap: onHeaderTap,
                  onLongPress: onHeaderLongPress,
                  child: (text.isNotEmpty && hijriText.isEmpty)? Text(
                    text,
                    style: headerStyle.titleTextStyle,
                    textAlign: headerStyle.titleCentered
                        ? TextAlign.center
                        : TextAlign.start,
                  ):(text.isEmpty && hijriText.isNotEmpty)?Text(
                    hijriText,
                    style: headerStyle.titleTextStyle,
                    textAlign: headerStyle.titleCentered
                    ? TextAlign.center
                        : TextAlign.start,
                  ):Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        hijriHasPreference?hijriText:text,
                        style: headerStyle.titleTextStyle,
                        textAlign: headerStyle.titleCentered
                            ? TextAlign.center
                            : TextAlign.start,
                      ),
                      Text(
                        hijriHasPreference?"( "+text+" )":"( "+hijriText+" )",
                        style: headerStyle.dualTitleTextStyle,
                        textAlign: headerStyle.titleCentered
                            ? TextAlign.center
                            : TextAlign.start,
                      ),
                    ],
                  ),
                ),
          ),
          if (headerStyle.formatButtonVisible &&
              availableCalendarFormats.length > 1)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: FormatButton(
                onTap: onFormatButtonTap,
                availableCalendarFormats: availableCalendarFormats,
                calendarFormat: calendarFormat,
                decoration: headerStyle.formatButtonDecoration,
                padding: headerStyle.formatButtonPadding,
                textStyle: headerStyle.formatButtonTextStyle,
                showsNextFormat: headerStyle.formatButtonShowsNext,
              ),
            ),
          if (headerStyle.rightChevronVisible)
            CustomIconButton(
              icon: headerStyle.rightChevronIcon,
              onTap: onRightChevronTap,
              margin: headerStyle.rightChevronMargin,
              padding: headerStyle.rightChevronPadding,
            ),
        ],
      ),
    );
  }

  HijriAndGregorianDate _firstDayOfMonth(HijriAndGregorianDate month) {
    return month.firstDayOfMonth(hijriHasPreference);
  }

  HijriAndGregorianDate _lastDayOfMonth(HijriAndGregorianDate month) {
    return month.lastDayOfMonth(hijriHasPreference);
  }
}
