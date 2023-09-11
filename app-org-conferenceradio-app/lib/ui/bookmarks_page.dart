import 'package:automatic_animated_list/automatic_animated_list.dart';
import 'package:conference_radio_flutter/constants/style_list.dart';
import 'package:conference_radio_flutter/page_manager.dart';
import 'package:conference_radio_flutter/routes.dart';
import 'package:conference_radio_flutter/services/service_locator.dart';
import 'package:conference_radio_flutter/services/talks_db_service.dart';
import 'package:conference_radio_flutter/translation.dart';
import 'package:conference_radio_flutter/ui/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class BookmarksPage extends HookWidget {
  static const route = Routes.bookmarksPage;

  const BookmarksPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    final bookmarks = useListenable(pageManager.bookmarkListNotifier);
    return Container(
      decoration: StyleList.backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(title: "Library"),
        body: _BookmarksList(bookmarks.value),
      ),
    );
  }
}

class _BookmarksList extends StatelessWidget {
  final List<Bookmark> bookmarks;

  const _BookmarksList(this.bookmarks);
  @override
  Widget build(BuildContext context) {
    final sectionFormatter = DateFormat.yMMMd().format;
    final bookmarksCount = bookmarks.length;
    final labels = [for (final bookmark in bookmarks) sectionFormatter(bookmark.createdDate)];
    final idToNeedsLabelMap =
        Map<int, bool>.fromEntries(([for (int i = 0; i < bookmarksCount; i++) MapEntry(bookmarks[i].talk.talkId, i == 0 || i + 1 != bookmarksCount && labels[i] != labels[i + 1])]));

    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(useMaterial3: theme.platform == TargetPlatform.android),
      child: AutomaticAnimatedList<Bookmark>(
        padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 44),
        items: bookmarks,
        insertDuration: const Duration(milliseconds: 100),
        removeDuration: const Duration(milliseconds: 100),
        keyingFunction: (item) => ValueKey(item.talk.talkId),
        itemBuilder: (BuildContext context, bookmark, Animation<double> animation) {
          return FadeTransition(
            key: ValueKey(bookmark.talk.talkId),
            opacity: animation,
            child: SizeTransition(
              sizeFactor: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
                reverseCurve: Curves.easeIn,
              ),
              child: Column(
                children: [
                  if (idToNeedsLabelMap[bookmark.talk.talkId] == true)
                    DateLabel(
                      text: sectionFormatter(bookmark.createdDate),
                    ),
                  ScaleOnTap(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (BuildContext context) {
                          return BookmarkSheet(bookmark: bookmark);
                        },
                      );
                    },
                    child: TalkCard(
                      bookmark: bookmark,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class BookmarkSheet extends StatelessWidget {
  final Bookmark bookmark;

  const BookmarkSheet({
    super.key,
    required this.bookmark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TalkCard(
              bookmark: bookmark,
              showAllInformation: true,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_rounded),
            title: const Text('Open In Gospel Library'),
            onTap: () {
              final url = Uri.parse(getChurchLinkFromTalk(bookmark.talk));
              launchUrl(url, mode: LaunchMode.externalApplication);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {
              Share.share(getChurchLinkFromTalk(bookmark.talk));
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text('Remove Bookmark'),
            onTap: () {
              getIt<PageManager>().bookmark(false, bookmark.talk.talkId);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class ScaleOnTap extends HookWidget {
  final void Function() onTap;
  final Widget child;

  const ScaleOnTap({
    super.key,
    required this.onTap,
    required this.child,
  });
  @override
  Widget build(BuildContext context) {
    final isPressed = useState(false);
    const Duration tapAnimationDuration = Duration(milliseconds: 100);

    return Listener(
      onPointerDown: (_) {
        isPressed.value = true;
      },
      onPointerUp: (_) {
        isPressed.value = false;
      },
      onPointerCancel: (_) {
        isPressed.value = false;
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: child
            .animate(
              target: isPressed.value ? 1 : 0,
            )
            .scaleXY(end: .95, duration: tapAnimationDuration),
      ),
    );
  }
}

class DateLabel extends StatelessWidget {
  const DateLabel({
    super.key,
    required this.text,
  });
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class TalkCard extends StatelessWidget {
  const TalkCard({
    super.key,
    required this.bookmark,
    this.showAllInformation = false,
  });

  final Bookmark bookmark;
  final bool showAllInformation;

  @override
  Widget build(BuildContext context) {
    final allInformationFormatter = DateFormat.yMMMd().addPattern("'at'").add_jms().format;
    final talk = bookmark.talk;
    monthAndSession() => '${talk.month == 4 ? "Apr" : "Oct"} ${talk.year}: ${sessionTranslations[talk.type] ?? talk.type}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(blurRadius: 10, color: Colors.black12),
          ],
        ),
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(width: 0.50),
            ),
          ),
          padding: const EdgeInsets.only(left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bookmark.talk.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                bookmark.talk.name,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF818181),
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (showAllInformation) ...[
                Text(
                  monthAndSession(),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF818181),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  "Saved on ${allInformationFormatter(bookmark.createdDate)}",
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF818181),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
