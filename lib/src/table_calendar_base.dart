// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';

import 'shared/utils.dart';
import 'widgets/calendar_core.dart';
import 'package:hijri/hijri_calendar.dart';

class TableCalendarBase extends StatefulWidget {
  final HijriAndGregorianDate firstDay;
  final HijriAndGregorianDate lastDay;
  final HijriAndGregorianDate focusedDay;
  final CalendarFormat calendarFormat;
  final DayBuilder? dowBuilder;
  final FocusedDayBuilder dayBuilder;
  final double? dowHeight;
  final double rowHeight;
  final bool sixWeekMonthsEnforced;
  final bool dowVisible;
  final Decoration? dowDecoration;
  final Decoration? rowDecoration;
  final TableBorder? tableBorder;
  final Duration formatAnimationDuration;
  final Curve formatAnimationCurve;
  final bool pageAnimationEnabled;
  final Duration pageAnimationDuration;
  final Curve pageAnimationCurve;
  final StartingDayOfWeek startingDayOfWeek;
  final AvailableGestures availableGestures;
  final SimpleSwipeConfig simpleSwipeConfig;
  final Map<CalendarFormat, String> availableCalendarFormats;
  final SwipeCallback? onVerticalSwipe;
  final void Function(HijriAndGregorianDate focusedDay)? onPageChanged;
  final void Function(PageController pageController)? onCalendarCreated;
  final bool showHijriDate;
  final bool showGregorianDate;
  final bool hijriHasPreference;
  final int adjustHijriDateByDays;

  TableCalendarBase({
    Key? key,
    required this.firstDay,
    required this.lastDay,
    required this.focusedDay,
    this.calendarFormat = CalendarFormat.month,
    this.dowBuilder,
    required this.dayBuilder,
    this.dowHeight,
    required this.rowHeight,
    this.sixWeekMonthsEnforced = false,
    this.dowVisible = true,
    this.dowDecoration,
    this.rowDecoration,
    this.tableBorder,
    this.formatAnimationDuration = const Duration(milliseconds: 200),
    this.formatAnimationCurve = Curves.linear,
    this.pageAnimationEnabled = true,
    this.pageAnimationDuration = const Duration(milliseconds: 300),
    this.pageAnimationCurve = Curves.easeOut,
    this.startingDayOfWeek = StartingDayOfWeek.sunday,
    this.availableGestures = AvailableGestures.all,
    this.simpleSwipeConfig = const SimpleSwipeConfig(
      verticalThreshold: 25.0,
      swipeDetectionBehavior: SwipeDetectionBehavior.continuousDistinct,
    ),
    this.availableCalendarFormats = const {
      CalendarFormat.month: 'Month',
      CalendarFormat.twoWeeks: '2 weeks',
      CalendarFormat.week: 'Week',
    },
    this.onVerticalSwipe,
    this.onPageChanged,
    this.onCalendarCreated,
    required this.showHijriDate,
    required this.showGregorianDate,
    required this.adjustHijriDateByDays,
    required this.hijriHasPreference,
  })  : assert(!dowVisible || (dowHeight != null && dowBuilder != null)),
        assert(isSameDay(focusedDay, firstDay) || focusedDay.isAfter(firstDay,hijriHasPreference)),
        assert(isSameDay(focusedDay, lastDay) || focusedDay.isBefore(lastDay,hijriHasPreference)),
        super(key: key);

  @override
  _TableCalendarBaseState createState() => _TableCalendarBaseState();
}

class _TableCalendarBaseState extends State<TableCalendarBase> {
  late final ValueNotifier<double> _pageHeight;
  late final PageController _pageController;
  late HijriAndGregorianDate _focusedDay;
  late int _previousIndex;
  late bool _pageCallbackDisabled;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.focusedDay;

    final rowCount = _getRowCount(widget.calendarFormat, _focusedDay);
    _pageHeight = ValueNotifier(_getPageHeight(rowCount));

    final initialPage = _calculateFocusedPage(
        widget.calendarFormat, widget.firstDay, _focusedDay);

    _pageController = PageController(initialPage: initialPage);
    widget.onCalendarCreated?.call(_pageController);

    _previousIndex = initialPage;
    _pageCallbackDisabled = false;
  }

  @override
  void didUpdateWidget(TableCalendarBase oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_focusedDay != widget.focusedDay ||
        widget.calendarFormat != oldWidget.calendarFormat ||
        widget.startingDayOfWeek != oldWidget.startingDayOfWeek) {
      final shouldAnimate = _focusedDay != widget.focusedDay;

      _focusedDay = widget.focusedDay;
      _updatePage(shouldAnimate: shouldAnimate);
    }

    if (widget.rowHeight != oldWidget.rowHeight ||
        widget.dowHeight != oldWidget.dowHeight ||
        widget.dowVisible != oldWidget.dowVisible ||
        widget.sixWeekMonthsEnforced != oldWidget.sixWeekMonthsEnforced) {
      final rowCount = _getRowCount(widget.calendarFormat, _focusedDay);
      _pageHeight.value = _getPageHeight(rowCount);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pageHeight.dispose();
    super.dispose();
  }

  bool get _canScrollHorizontally =>
      widget.availableGestures == AvailableGestures.all ||
      widget.availableGestures == AvailableGestures.horizontalSwipe;

  bool get _canScrollVertically =>
      widget.availableGestures == AvailableGestures.all ||
      widget.availableGestures == AvailableGestures.verticalSwipe;

  void _updatePage({bool shouldAnimate = false}) {
    final currentIndex = _calculateFocusedPage(
        widget.calendarFormat, widget.firstDay, _focusedDay);

    final endIndex = _calculateFocusedPage(
        widget.calendarFormat, widget.firstDay, widget.lastDay);

    if (currentIndex != _previousIndex ||
        currentIndex == 0 ||
        currentIndex == endIndex) {
      _pageCallbackDisabled = true;
    }

    if (shouldAnimate && widget.pageAnimationEnabled) {
      if ((currentIndex - _previousIndex).abs() > 1) {
        final jumpIndex =
            currentIndex > _previousIndex ? currentIndex - 1 : currentIndex + 1;

        _pageController.jumpToPage(jumpIndex);
      }

      _pageController.animateToPage(
        currentIndex,
        duration: widget.pageAnimationDuration,
        curve: widget.pageAnimationCurve,
      );
    } else {
      _pageController.jumpToPage(currentIndex);
    }

    _previousIndex = currentIndex;
    final rowCount = _getRowCount(widget.calendarFormat, _focusedDay);
    _pageHeight.value = _getPageHeight(rowCount);

    _pageCallbackDisabled = false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SimpleGestureDetector(
          onVerticalSwipe: _canScrollVertically ? widget.onVerticalSwipe : null,
          swipeConfig: widget.simpleSwipeConfig,
          child: ValueListenableBuilder<double>(
            valueListenable: _pageHeight,
            builder: (context, value, child) {
              final height =
                  constraints.hasBoundedHeight ? constraints.maxHeight : value;

              return AnimatedSize(
                duration: widget.formatAnimationDuration,
                curve: widget.formatAnimationCurve,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: height,
                  child: child,
                ),
              );
            },
            child: CalendarCore(
              constraints: constraints,
              pageController: _pageController,
              scrollPhysics: _canScrollHorizontally
                  ? PageScrollPhysics()
                  : NeverScrollableScrollPhysics(),
              firstDay: widget.firstDay,
              lastDay: widget.lastDay,
              startingDayOfWeek: widget.startingDayOfWeek,
              calendarFormat: widget.calendarFormat,
              previousIndex: _previousIndex,
              focusedDay: _focusedDay,
              sixWeekMonthsEnforced: widget.sixWeekMonthsEnforced,
              dowVisible: widget.dowVisible,
              dowHeight: widget.dowHeight,
              rowHeight: widget.rowHeight,
              dowDecoration: widget.dowDecoration,
              rowDecoration: widget.rowDecoration,
              tableBorder: widget.tableBorder,
              onPageChanged: (index, focusedMonth) {
                if (!_pageCallbackDisabled) {
                  if (!isSameDay(_focusedDay, focusedMonth)) {
                    _focusedDay = focusedMonth;
                  }

                  if (widget.calendarFormat == CalendarFormat.month &&
                      !widget.sixWeekMonthsEnforced &&
                      !constraints.hasBoundedHeight) {
                    final rowCount = _getRowCount(
                      widget.calendarFormat,
                      focusedMonth,
                    );
                    _pageHeight.value = _getPageHeight(rowCount);
                  }

                  _previousIndex = index;
                  widget.onPageChanged?.call(focusedMonth);
                }

                _pageCallbackDisabled = false;
              },
              dowBuilder: widget.dowBuilder,
              dayBuilder: widget.dayBuilder,
              showHijriDate: widget.showHijriDate,
              showGregorianDate: widget.showGregorianDate,
              adjustHijriDateByDays: widget.adjustHijriDateByDays,
              hijriHasPreference: widget.hijriHasPreference,
            ),
          ),
        );
      },
    );
  }

  double _getPageHeight(int rowCount) {
    final dowHeight = widget.dowVisible ? widget.dowHeight! : 0.0;
    return dowHeight + rowCount * widget.rowHeight;
  }

  int _calculateFocusedPage(
      CalendarFormat format, HijriAndGregorianDate startDay, HijriAndGregorianDate focusedDay) {
    switch (format) {
      case CalendarFormat.month:
        return _getMonthCount(startDay, focusedDay);
      case CalendarFormat.twoWeeks:
        return _getTwoWeekCount(startDay, focusedDay);
      case CalendarFormat.week:
        return _getWeekCount(startDay, focusedDay);
      default:
        return _getMonthCount(startDay, focusedDay);
    }
  }

  int _getMonthCount(HijriAndGregorianDate first, HijriAndGregorianDate last) {
    return first.getMonthCount(last, widget.hijriHasPreference);
  }

  int _getWeekCount(HijriAndGregorianDate first, HijriAndGregorianDate last) {
    return last.differenceInDays(_firstDayOfWeek(first),widget.hijriHasPreference) ~/ 7;
  }

  int _getTwoWeekCount(HijriAndGregorianDate first, HijriAndGregorianDate last) {
    return last.differenceInDays(_firstDayOfWeek(first),widget.hijriHasPreference) ~/ 14;
  }

  int _getRowCount(CalendarFormat format, HijriAndGregorianDate focusedDay) {
    if (format == CalendarFormat.twoWeeks) {
      return 2;
    } else if (format == CalendarFormat.week) {
      return 1;
    } else if (widget.sixWeekMonthsEnforced) {
      return 6;
    }

    final first = _firstDayOfMonth(focusedDay);
    final daysBefore = _getDaysBefore(first);
    final firstToDisplay = first.subtract(Duration(days: daysBefore),widget.hijriHasPreference);

    final last = _lastDayOfMonth(focusedDay);
    final daysAfter = _getDaysAfter(last);
    final lastToDisplay = last.add(Duration(days: daysAfter),widget.hijriHasPreference);

    return (lastToDisplay.differenceInDays(firstToDisplay,widget.hijriHasPreference) + 1) ~/ 7;
  }

  int _getDaysBefore(HijriAndGregorianDate firstDay) {
    return (firstDay.weekday() + 7 - getWeekdayNumber(widget.startingDayOfWeek)) %
        7;
  }

  int _getDaysAfter(HijriAndGregorianDate lastDay) {
    int invertedStartingWeekday =
        8 - getWeekdayNumber(widget.startingDayOfWeek);

    int daysAfter = 7 - ((lastDay.weekday() + invertedStartingWeekday) % 7);
    if (daysAfter == 7) {
      daysAfter = 0;
    }

    return daysAfter;
  }

  HijriAndGregorianDate _firstDayOfWeek(HijriAndGregorianDate week) {
    final daysBefore = _getDaysBefore(week);
    return week.subtract(Duration(days: daysBefore), widget.hijriHasPreference);
  }

  HijriAndGregorianDate _firstDayOfMonth(HijriAndGregorianDate month) {
    return month.firstDayOfMonth(widget.hijriHasPreference);
  }

  HijriAndGregorianDate _lastDayOfMonth(HijriAndGregorianDate month) {
    return month.lastDayOfMonth(widget.hijriHasPreference);
  }
}
