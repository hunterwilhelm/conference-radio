import 'dart:math';

import 'package:conference_radio_flutter/constants/style_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class PlayPauseButton extends HookWidget {
  final bool isPaused;
  final bool isLoading;
  final void Function() onTap;

  const PlayPauseButton({
    super.key,
    required this.isPaused,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(duration: const Duration(milliseconds: 100));
    final randomRotation = useMemoized(() => Random().nextDouble() * pi * 2, [isLoading]);
    useEffect(() {
      if (isLoading) {
        return;
      }
      try {
        if (isPaused) {
          controller.reverse();
        } else {
          controller.forward();
        }
      } catch (e) {
        debugPrint("Play Pause Button animation warning");
      }
      return;
    }, [isPaused, isLoading]);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: isLoading ? null : onTap,
      child: ClipOval(
        child: Container(
          color: isLoading ? Colors.grey : StyleList.buttonColor,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: AnimatedIcon(
                  icon: AnimatedIcons.play_pause,
                  color: Colors.white,
                  progress: controller,
                  size: 45.0,
                ),
              ),
              if (isLoading)
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Transform.rotate(
                      angle: randomRotation,
                      child: const CircularProgressIndicator(
                        strokeWidth: 4.0,
                        strokeCap: StrokeCap.round,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
