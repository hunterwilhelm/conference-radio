import 'package:conference_radio_flutter/constants/style_list.dart';
import 'package:conference_radio_flutter/notifiers/filter_notifier.dart';
import 'package:conference_radio_flutter/routes.dart';
import 'package:conference_radio_flutter/ui/widgets/custom_app_bar.dart';
import 'package:conference_radio_flutter/utils/locales.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:quiver/strings.dart';

import '../page_manager.dart';
import '../services/service_locator.dart';

class FilterPage extends HookWidget {
  static const route = Routes.filterPage;
  const FilterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    final availableTalkCount = useListenable(pageManager.talkCountAvailableNotifier).value;
    return Container(
      decoration: StyleList.backgroundGradient,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(title: tr(context).pageTitleFilter),
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  tr(context).nTalksAvailable(availableTalkCount),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 2.05,
                  ),
                ),
                _SpeakerFilter(
                  key: ValueKey(availableTalkCount),
                ),
                const _DateFilters(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeakerFilter extends HookWidget {
  const _SpeakerFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    final speakers = useListenable(pageManager.filteredSpeakersNotifier).value..sort((a, b) => b.count - a.count);
    final filter = useListenable(pageManager.filterNotifier).value;
    final focusNode = useFocusNode();
    final controller = useTextEditingController(text: filter.filterBySpeaker);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(tr(context).filterBySpeaker, style: _titleStyle),
            Switch.adaptive(
              value: filter.filterBySpeakerEnabled,
              onChanged: (value) {
                if (isBlank(pageManager.filterNotifier.value.filterBySpeaker) && value) {
                  focusNode.requestFocus();
                } else {
                  pageManager.updateFilterSpeakerEnabled(value);
                }
              },
            ),
          ],
        ),
        TypeAheadField(
          focusNode: focusNode,
          controller: controller,
          hideOnSelect: true,
          builder: (context, controller, focusNode) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: tr(context).searchForSpeakerPlaceholder,
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          controller.text = "";
                          pageManager.updateFilterSpeaker("");
                          pageManager.updateFilterSpeakerEnabled(false);
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
              ),
              onTapOutside: (_) {
                focusNode.unfocus();
              },
            );
          },
          itemBuilder: (context, item) {
            return ListTile(
              title: Text(
                "${item.name} (${item.count})",
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  letterSpacing: .8,
                  color: Colors.black,
                ),
              ),
            );
          },
          emptyBuilder: (context) {
            return ListTile(
              title: Text(
                tr(context).speakerNoResultsHelpMessage,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  letterSpacing: .8,
                  color: Color.fromARGB(255, 61, 61, 61),
                ),
              ),
            );
          },
          onSelected: (value) {
            controller.text = value.name;
            focusNode.unfocus();
            pageManager.updateFilterSpeaker(value.name);
            pageManager.updateFilterSpeakerEnabled(true);
          },
          suggestionsCallback: (pattern) {
            return speakers.where((element) => element.name.toLowerCase().contains(pattern.toLowerCase())).toList();
          },
        )
      ],
    );
  }
}

const _titleStyle = TextStyle(
  color: Colors.black,
  fontSize: 22,
  fontWeight: FontWeight.w600,
  letterSpacing: 2.05,
);

class _DateFilters extends HookWidget {
  const _DateFilters();

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    final filter = useListenable(pageManager.filterNotifier).value;

    const textStyle = TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.w400,
      letterSpacing: 2.05,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(tr(context).filterBetweenDates, style: _titleStyle),
            Switch.adaptive(
              value: filter.dateFilter.enabled,
              onChanged: (value) {
                pageManager.updateDateFilterEnabled(value);
              },
            ),
          ],
        ),
        Text(
          tr(context).fromInContextOfFromDateToDate,
          textAlign: TextAlign.center,
          style: textStyle,
        ),
        ValueListenableBuilder<Filter>(
            valueListenable: pageManager.filterNotifier,
            builder: (_, filter, __) {
              return _TextButton(
                label: "${filter.dateFilter.start.longLabel(context)}",
                onClick: () {
                  _PickConference.show(context, filter.dateFilter.start, (newYearMonth) {
                    pageManager.updateFilterStart(newYearMonth);
                  });
                },
              );
            }),
        Text(
          tr(context).toInContextOfFromDateToDate,
          textAlign: TextAlign.center,
          style: textStyle,
        ),
        ValueListenableBuilder<Filter>(
            valueListenable: pageManager.filterNotifier,
            builder: (_, filter, __) {
              return _TextButton(
                label: "${filter.dateFilter.end.longLabel(context)}",
                onClick: () {
                  _PickConference.show(context, filter.dateFilter.end, (newYearMonth) {
                    pageManager.updateFilterEnd(newYearMonth);
                  });
                },
              );
            }),
      ],
    );
  }
}

class _TextButton extends StatelessWidget {
  final String label;
  final void Function() onClick;
  const _TextButton({
    required this.label,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onClick();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 2.05,
                ),
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: Colors.black,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _PickConference extends HookWidget {
  const _PickConference({
    required this.defaultYearMonth,
    required this.onSubmit,
  });

  final void Function(YearMonth value) onSubmit;
  final YearMonth defaultYearMonth;

  static void show(
    BuildContext context,
    YearMonth defaultYearMonth,
    void Function(YearMonth value) onSubmit,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _PickConference(
          onSubmit: onSubmit,
          defaultYearMonth: defaultYearMonth,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = useState<YearMonth>(defaultYearMonth);
    final pageManager = getIt<PageManager>();
    final maxRange = pageManager.maxRangeNotifier.value;
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

  Map<String, dynamic> toJson() {
    return {
      "month": month,
      "year": year,
    };
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
