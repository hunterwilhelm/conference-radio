import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:conference_radio_flutter/routes.dart';
import 'package:conference_radio_flutter/services/launch_service.dart';
import 'package:conference_radio_flutter/ui/bookmarks_page.dart';
import 'package:conference_radio_flutter/ui/widgets/play_pause_button.dart';
import 'package:conference_radio_flutter/utils/locales.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:marquee/marquee.dart';

import '../constants/style_list.dart';
import '../notifiers/filter_notifier.dart';
import '../notifiers/play_button_notifier.dart';
import '../notifiers/progress_notifier.dart';
import '../page_manager.dart';
import '../services/service_locator.dart';
import '../services/talks_db_service.dart';

class HomePage extends StatelessWidget {
  static const route = Routes.homePage;

  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: StyleList.backgroundGradient,
      child: const Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TopBar(),
              AlbumCover(),
              TalkDescription(),
              ActionButtons(),
              Column(
                children: [
                  AudioProgressBar(),
                  AudioControlButtons(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              context.push(BookmarksPage.route.path);
            },
            icon: const Icon(FluentIcons.library_16_filled),
            color: StyleList.bottomRowSecondaryButtonColor,
          ),
          GestureDetector(
            onTap: () {
              context.push(Routes.filterPage.path);
            },
            child: Container(
              color: Colors.transparent,
              child: ValueListenableBuilder<Filter>(
                valueListenable: pageManager.filterNotifier,
                builder: (_, filter, __) {
                  return Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${tr(context).playingFrom}\n',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.88,
                          ),
                        ),
                        TextSpan(
                          text: '${filter.start.shortLabel} ${tr(context).toInContextOfDateToDate} ${filter.end.shortLabel}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.12,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ),
          ),
          PopupMenuButton(
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                FluentIcons.settings_16_filled,
                color: StyleList.bottomRowSecondaryButtonColor,
              ),
            ),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                onTap: () {
                  context.push(Routes.languagePage.path);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Icon(FluentIcons.globe_12_regular),
                    const SizedBox(width: 10),
                    Text(tr(context).pageTitleLanguage),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () {
                  context.push(Routes.filterPage.path);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Icon(FluentIcons.options_16_regular),
                    const SizedBox(width: 10),
                    Text(tr(context).pageTitleFilter),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () {
                  LaunchService.openEmailForBugReport();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Icon(FluentIcons.bug_16_regular),
                    const SizedBox(width: 10),
                    Text(tr(context).contextMenuOptionReportBug),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () {
                  LaunchService.openEmailForFeatureRequest();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Icon(FluentIcons.lightbulb_16_regular),
                    const SizedBox(width: 10),
                    Text(tr(context).contextMenuOptionRequestFeature),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class AlbumCover extends StatelessWidget {
  const AlbumCover({super.key});
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return Padding(
      padding: const EdgeInsets.all(26.0),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: ShapeDecoration(
            color: Colors.white.withOpacity(0.7300000190734863),
            shape: SmoothRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0x4C818181)),
              borderRadius: SmoothBorderRadius(
                cornerRadius: 46,
                cornerSmoothing: 0.64,
              ),
            ),
          ),
          child: ValueListenableBuilder<Talk?>(
            valueListenable: pageManager.currentTalkNotifier,
            builder: (_, talk, __) {
              if (talk == null) {
                return const CircularProgressIndicator();
              }
              final monthAndYear = '${talk.month == 4 ? tr(context).aprilLong : tr(context).octoberLong}\n${talk.year}';
              final session = (trSession(context, talk.type, "\n"));
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    monthAndYear,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 25.67,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.05,
                    ),
                  ),
                  Container(
                    width: 124,
                    height: 1,
                    decoration: const ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          strokeAlign: BorderSide.strokeAlignCenter,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    session,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 25.67,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.05,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class TalkDescription extends StatelessWidget {
  const TalkDescription({super.key});

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<Talk?>(
        valueListenable: pageManager.currentTalkNotifier,
        builder: (_, talk, __) {
          return Column(
            children: [
              SizedBox(
                height: 35,
                child: MarqueeWhenOverflowed(
                  text: talk?.title ?? tr(context).loading,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.52,
                  ),
                ),
              ),
              SizedBox(
                height: 35,
                child: Align(
                  alignment: Alignment.center,
                  child: MarqueeWhenOverflowed(
                    text: talk?.name ?? tr(context).loading,
                    style: const TextStyle(
                      color: Color(0xFF6F6F6F),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.15,
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }
}

class ActionButtons extends HookWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<Talk?>(
        valueListenable: pageManager.currentTalkNotifier,
        builder: (context, talk, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.menu_book_rounded),
                onPressed: talk == null
                    ? null
                    : () {
                        LaunchService.openTalkInGospelLibrary(talk);
                      },
              ),
              IconButton(
                icon: Icon(Icons.adaptive.share),
                onPressed: talk == null
                    ? null
                    : () {
                        LaunchService.shareTalk(talk);
                      },
              ),
            ],
          );
        });
  }
}

class MarqueeWhenOverflowed extends StatelessWidget {
  final TextStyle style;
  final String text;

  const MarqueeWhenOverflowed({super.key, required this.style, required this.text});
  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      maxLines: 1,
      textAlign: TextAlign.left,
      minFontSize: style.fontSize ?? 30,
      style: style,
      overflowReplacement: Marquee(
        text: text,
        style: style,
        scrollAxis: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.center,
        blankSpace: 100.0,
        velocity: 50.0,
        pauseAfterRound: const Duration(seconds: 1),
        accelerationDuration: const Duration(seconds: 0),
        showFadingOnlyWhenScrolling: true,
        fadingEdgeEndFraction: .1,
        fadingEdgeStartFraction: .1,
      ),
    );
  }
}

class AudioProgressBar extends StatelessWidget {
  const AudioProgressBar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: pageManager.progressNotifier,
      builder: (_, value, __) {
        return ProgressBar(
          progress: value.current,
          buffered: value.buffered,
          total: value.total,
          onSeek: pageManager.seek,
        );
      },
    );
  }
}

class AudioControlButtons extends StatelessWidget {
  const AudioControlButtons({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ShuffleButton(),
        PreviousSongButton(),
        PlayButton(),
        NextSongButton(),
        BookmarkButton(),
      ],
    );
  }
}

class BookmarkButton extends StatelessWidget {
  const BookmarkButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder(
      valueListenable: getIt<PageManager>().currentBookmarkNotifier,
      builder: (context, isBookmarked, child) {
        return IconButton(
          iconSize: 30,
          icon: isBookmarked
              ? const Icon(
                  FluentIcons.bookmark_16_filled,
                  color: Color(0xFF0085FF),
                )
              : const Icon(
                  FluentIcons.bookmark_16_regular,
                  color: Colors.black,
                ),
          onPressed: () {
            pageManager.bookmark(!isBookmarked);
          },
        );
      },
    );
  }
}

class PreviousSongButton extends StatelessWidget {
  const PreviousSongButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return StreamBuilder(
        stream: pageManager.hasPreviousStream,
        builder: (context, snapshot) {
          final hasPrevious = snapshot.data ?? true;
          return IconButton(
            color: StyleList.bottomRowSecondaryButtonColor,
            icon: Icon(
              FluentIcons.arrow_previous_12_filled,
              color: hasPrevious ? StyleList.bottomRowSecondaryButtonColor : StyleList.bottomRowSecondaryButtonColorInactive,
              size: 30,
            ),
            onPressed: pageManager.previous,
          );
        });
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder(
      valueListenable: pageManager.playButtonNotifier,
      builder: (context, value, child) {
        final isPaused = value == ButtonState.paused;
        return Hero(
          tag: 'playPauseButton',
          child: PlayPauseButton(
            isLoading: value == ButtonState.loading,
            isPaused: isPaused,
            onTap: isPaused ? pageManager.play : pageManager.pause,
          ),
        );
      },
    );
  }
}

class NextSongButton extends StatelessWidget {
  const NextSongButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return StreamBuilder<bool>(
        stream: pageManager.hasNextStream,
        builder: (context, snapshot) {
          final hasNext = snapshot.data ?? true;
          return IconButton(
            icon: Icon(
              FluentIcons.arrow_next_12_filled,
              size: 30,
              color: hasNext ? StyleList.bottomRowSecondaryButtonColor : StyleList.bottomRowSecondaryButtonColorInactive,
            ),
            onPressed: () {
              pageManager.next();
            },
          );
        });
  }
}

class ShuffleButton extends StatelessWidget {
  const ShuffleButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<bool>(
      valueListenable: pageManager.isShuffleModeEnabledNotifier,
      builder: (context, isEnabled, child) {
        return IconButton(
          iconSize: 35,
          icon: (isEnabled)
              ? const Icon(
                  FluentIcons.arrow_shuffle_16_filled,
                  color: StyleList.bottomRowSecondaryButtonColor,
                )
              : const Icon(
                  FluentIcons.arrow_shuffle_off_16_filled,
                  color: StyleList.bottomRowSecondaryButtonColor,
                ),
          onPressed: pageManager.shuffle,
        );
      },
    );
  }
}
