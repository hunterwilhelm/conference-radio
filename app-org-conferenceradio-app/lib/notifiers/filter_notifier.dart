import 'package:conference_radio_flutter/ui/filter_page.dart';
import 'package:flutter/foundation.dart';

class FilterNotifier extends ValueNotifier<Filter> {
  FilterNotifier() : super(_initialValue);
  static const _initialValue = Filter(YearMonth(2023, 4), YearMonth(2000, 5));
}

class Filter {
  final YearMonth start;
  final YearMonth end;
  Filter asSorted() {
    if (start.date.compareTo(end.date) > 0) {
      return this;
    } else {
      return Filter(end, start);
    }
  }

  const Filter(this.start, this.end);
}
