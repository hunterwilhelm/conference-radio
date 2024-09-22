import 'package:conference_radio_flutter/ui/filter_page.dart';
import 'package:flutter/foundation.dart';

class FilterNotifier extends ValueNotifier<Filter> {
  FilterNotifier() : super(_initialValue);
  static const _initialValue = Filter(
    dateFilter: DateFilter(YearMonth(2023, 4), YearMonth(2000, 10)),
    filterBySpeaker: "",
    filterBySpeakerEnabled: false,
  );
}

class DateFilterNotifier extends ValueNotifier<DateFilter> {
  DateFilterNotifier() : super(_initialValue);
  static const _initialValue = DateFilter(YearMonth(2023, 4), YearMonth(2000, 10));
}

class Filter {
  const Filter({required this.dateFilter, required this.filterBySpeaker, this.filterBySpeakerEnabled = false});
  final DateFilter dateFilter;
  final String filterBySpeaker;
  final bool filterBySpeakerEnabled;

  Filter copyWith({
    DateFilter? dateFilter,
    String? filterBySpeaker,
    bool? filterBySpeakerEnabled,
  }) {
    return Filter(
      dateFilter: dateFilter ?? this.dateFilter,
      filterBySpeaker: filterBySpeaker ?? this.filterBySpeaker,
      filterBySpeakerEnabled: filterBySpeakerEnabled ?? this.filterBySpeakerEnabled,
    );
  }
}

class DateFilter {
  final bool enabled;
  final YearMonth start;
  final YearMonth end;
  DateFilter asSorted() {
    if (start.isBefore(end)) {
      return this;
    } else {
      return DateFilter(end, start);
    }
  }

  const DateFilter(this.start, this.end, {this.enabled = true});

  @override
  String toString() {
    return "Filter<{start: $start, end: $end, enabled: $enabled}>";
  }

  Map<String, dynamic> toJson() {
    return {
      "start": start.toJson(),
      "end": end.toJson(),
    };
  }

  DateFilter copyWith({
    bool? enabled,
    YearMonth? start,
    YearMonth? end,
  }) {
    return DateFilter(
      start ?? this.start,
      end ?? this.end,
      enabled: enabled ?? this.enabled,
    );
  }
}
