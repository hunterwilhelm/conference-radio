import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

import '../constants/style_list.dart';
import '../main.dart';
import '../notifiers/play_button_notifier.dart';
import '../notifiers/progress_notifier.dart';
import '../notifiers/repeat_button_notifier.dart';
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

const sessionTranslations = {
  "saturday-morning": "Saturday Morning Session",
  "saturday-afternoon": "Saturday Afternoon Session",
  "saturday-evening": "Saturday Evening Session",
  "sunday-morning": "Sunday Morning Session",
  "sunday-afternoon": "Sunday Afternoon Session",
  "priesthood": "Priesthood Session",
  "welfare": "General Welfare Session",
  "midweek": "A Midweek Session",
  "women's": "Women's Session",
  "young-women": "General Young Women Meeting",
  "broadcast": "Special Broadcast",
  "fireside": "Fireside",
};

enum SampleItem { itemOne, itemTwo, itemThree }

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
            onPressed: () {},
            icon: const Icon(FluentIcons.library_16_filled),
            color: StyleList.bottomRowSecondaryButtonColor,
          ),
          ValueListenableBuilder<Talk?>(
            valueListenable: pageManager.currentTalkNotifier,
            builder: (_, talk, __) {
              return const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'PLAYING FROM\n',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.88,
                      ),
                    ),
                    TextSpan(
                      text: '04/2010 to 04/2023',
                      style: TextStyle(
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
          PopupMenuButton(
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                FluentIcons.settings_16_filled,
                color: StyleList.bottomRowSecondaryButtonColor,
              ),
            ),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(FluentIcons.globe_12_regular),
                    SizedBox(width: 10),
                    Text('Language'),
                  ],
                ),
              ),
              const PopupMenuItem(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(FluentIcons.options_16_regular),
                    SizedBox(width: 10),
                    Text('Filter'),
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
              final monthAndYear = '${talk.month == 4 ? "April" : "October"}\n${talk.year}';
              final session = (sessionTranslations[talk.type] ?? talk.type).replaceAll(" ", "\n");
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
                  text: talk?.title ?? "Loading...",
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
                    text: talk?.name ?? "Loading...",
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
        SleepTimerButton(),
      ],
    );
  }
}

class SleepTimerButton extends StatelessWidget {
  const SleepTimerButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<RepeatState>(
      valueListenable: pageManager.repeatButtonNotifier,
      builder: (context, value, child) {
        Icon icon;
        switch (value) {
          case RepeatState.off:
            icon = const Icon(
              FluentIcons.timer_12_regular,
              size: 30,
              color: StyleList.bottomRowSecondaryButtonColor,
            );
            break;
          case RepeatState.repeatSong:
            icon = const Icon(Icons.repeat_one);
            break;
          case RepeatState.repeatPlaylist:
            icon = const Icon(Icons.repeat);
            break;
        }
        return IconButton(
          icon: icon,
          onPressed: pageManager.repeat,
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
    return ValueListenableBuilder<bool>(
      valueListenable: pageManager.isFirstSongNotifier,
      builder: (_, isFirst, __) {
        return IconButton(
          color: StyleList.bottomRowSecondaryButtonColor,
          icon: const Icon(
            FluentIcons.arrow_previous_12_filled,
            color: StyleList.bottomRowSecondaryButtonColor,
            size: 30,
          ),
          onPressed: (isFirst) ? null : pageManager.previous,
        );
      },
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<ButtonState>(
      valueListenable: pageManager.playButtonNotifier,
      builder: (_, value, __) {
        switch (value) {
          case ButtonState.loading:
            return Container(
              margin: const EdgeInsets.all(8.0),
              width: 80.0,
              height: 80.0,
              child: const CircularProgressIndicator(),
            );
          case ButtonState.paused:
            return IconButton(
              icon: const Icon(
                FluentIcons.play_circle_20_filled,
                color: StyleList.buttonColor,
              ),
              iconSize: 80.0,
              onPressed: pageManager.play,
            );
          case ButtonState.playing:
            return IconButton(
              icon: const Icon(
                FluentIcons.pause_circle_20_filled,
                color: StyleList.buttonColor,
              ),
              iconSize: 80.0,
              onPressed: pageManager.pause,
            );
        }
      },
    );
  }
}

class NextSongButton extends StatelessWidget {
  const NextSongButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<bool>(
      valueListenable: pageManager.isLastSongNotifier,
      builder: (_, isLast, __) {
        return IconButton(
          icon: const Icon(
            FluentIcons.arrow_next_12_filled,
            size: 30,
            color: StyleList.bottomRowSecondaryButtonColor,
          ),
          onPressed: (isLast) ? null : pageManager.next,
        );
      },
    );
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