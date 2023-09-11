import 'package:conference_radio_flutter/constants/style_list.dart';
import 'package:conference_radio_flutter/routes.dart';
import 'package:conference_radio_flutter/services/talk_repository.dart';
import 'package:conference_radio_flutter/services/service_locator.dart';
import 'package:conference_radio_flutter/services/talks_db_service.dart';
import 'package:conference_radio_flutter/ui/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class BookmarksPage extends HookWidget {
  static const route = Routes.bookmarksPage;

  const BookmarksPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final talkRepository = getIt<TalkRepository>();
    final bookmarksSnapshot = useFuture(useMemoized(() => talkRepository.getBookmarkedTalks(), []));
    print(bookmarksSnapshot.hasError);
    final bookmarks = bookmarksSnapshot.data;

    print(bookmarks);
    return Container(
      decoration: StyleList.backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(title: "Library"),
        body: bookmarks == null ? Container() : _BookmarksList(bookmarks),
      ),
    );
  }
}

class _BookmarksList extends StatelessWidget {
  final List<Bookmark> bookmarks;

  const _BookmarksList(this.bookmarks);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final bookmark in bookmarks) Text(bookmark.talk.title),
      ],
    );
  }
}
