import 'package:conference_radio_flutter/constants/style_list.dart';
import 'package:conference_radio_flutter/notifiers/filter_notifier.dart';
import 'package:conference_radio_flutter/routes.dart';
import 'package:conference_radio_flutter/ui/widgets/custom_app_bar.dart';
import 'package:conference_radio_flutter/utils/locales.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../page_manager.dart';
import '../services/service_locator.dart';

class FilterPage extends StatelessWidget {
  static const route = Routes.filterPage;
  const FilterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return Container(
      decoration: StyleList.backgroundGradient,
      child: Scaffold(
        appBar: CustomAppBar(title: tr(context).pageTitleFilter),
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SizedBox(
              height: 300,
              child: Column(
                children: [
                  ValueListenableBuilder<Filter>(
                      valueListenable: pageManager.filterNotifier,
                      builder: (_, filter, __) {
                        return Expanded(
                          child: TextButton(
                            label: "- ${filter.start.longLabel(context)} -",
                            onClick: () {
                              showOptions(context, filter.start, (newYearMonth) {
                                pageManager.updateFilterStart(newYearMonth);
                              });
                            },
                          ),
                        );
                      }),
                  const Text(
                    'to',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25.67,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 2.05,
                    ),
                  ),
                  ValueListenableBuilder<Filter>(
                      valueListenable: pageManager.filterNotifier,
                      builder: (_, filter, __) {
                        return Expanded(
                          child: TextButton(
                            label: "- ${filter.end.longLabel(context)} -",
                            onClick: () {
                              showOptions(context, filter.end, (newYearMonth) {
                                pageManager.updateFilterEnd(newYearMonth);
                              });
                            },
                          ),
                        );
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TextButton extends StatelessWidget {
  final String label;
  final void Function() onClick;
  const TextButton({
    super.key,
    required this.label,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onClick();
      },
      child: SizedBox(
        width: double.infinity,
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 25.67,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.05,
            ),
          ),
        ),
      ),
    );
  }
}

void showOptions(
  BuildContext context,
  YearMonth defaultYearMonth,
  void Function(YearMonth value) onSubmit,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return PickConference(
        onSubmit: onSubmit,
        defaultYearMonth: defaultYearMonth,
      );
    },
  );
}

class PickConference extends HookWidget {
  final void Function(YearMonth value) onSubmit;

  final YearMonth defaultYearMonth;
  const PickConference({
    super.key,
    required this.defaultYearMonth,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final selected = useState<YearMonth>(defaultYearMonth);
    final maxRange = getIt<PageManager>().maxRangeNotifier.value;
    final options = useMemoized(() => generateMonthsBetween(
          start: maxRange.start,
          end: maxRange.end,
        ).toList());
    final defaultIndex = options.indexWhere((element) => element == defaultYearMonth);
    return AlertDialog(
      title: Text(tr(context).pickConference),
      content: SizedBox(
        height: 200,
        child: CupertinoPicker(
          itemExtent: 50,
          scrollController: FixedExtentScrollController(initialItem: defaultIndex),
          children: [
            for (final option in options)
              _OptionItem(
                option.longLabel(context),
              ),
          ],
          onSelectedItemChanged: (index) {
            selected.value = options[index];
          },
        ),
      ),
      actions: <Widget>[
        Center(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                onSubmit(selected.value);
                Navigator.of(context).pop();
              },
              child: Text(tr(context).select),
            ),
          ),
        ),
      ],
    );
  }
}

class YearMonth {
  longLabel(BuildContext context) => "${month == 4 ? tr(context).aprilLong : tr(context).octoberLong}, $year";
  String get shortLabel => "$month/$year";
  DateTime get date => DateTime(year, month);
  final int year;
  final int month;

  @override
  bool operator ==(Object other) => identical(this, other) || other is YearMonth && runtimeType == other.runtimeType && year == other.year && month == other.month;

  @override
  int get hashCode => year.hashCode ^ month.hashCode;

  const YearMonth(this.year, this.month);

  YearMonth next() {
    if (month == 10) {
      return YearMonth(year + 1, 4);
    }
    return YearMonth(year, 10);
  }

  YearMonth previous() {
    if (month == 10) {
      return YearMonth(year, 4);
    }
    return YearMonth(year - 1, 10);
  }

  bool isBefore(YearMonth end) => date.isBefore(end.date);
  bool isAfter(YearMonth end) => date.isAfter(end.date);

  @override
  String toString() {
    return "MonthYear<{$month, $year}>";
  }
}

Iterable<YearMonth> generateMonthsBetween({
  required YearMonth start,
  required YearMonth end,
}) sync* {
  if ((start.month != 4 && start.month != 10) || (end.month != 4 && end.month != 10)) {
    throw ArgumentError("Invalid month value. Month should be either 4 or 10.");
  }
  if (end.isBefore(start)) {
    throw ArgumentError("Start cannot be before end");
  }

  for (YearMonth current = end; start.isBefore(current) || start == current; current = current.previous()) {
    yield current;
  }
}

class _OptionItem extends StatelessWidget {
  final String option;
  const _OptionItem(this.option);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        option,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
