import 'package:conference_radio_flutter/constants/style_list.dart';
import 'package:conference_radio_flutter/main.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../constants/asset_names.dart';

class WelcomeBeginPage extends HookWidget {
  static const route = Routes.welcomeBeginPage;
  const WelcomeBeginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: StyleList.backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 47),
                child: Hero(
                  tag: "logo",
                  child: SvgPicture.asset(
                    SvgAssetNames.whiteLogo,
                    height: 112,
                  ),
                ),
              ),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Column(
                      children: [
                        Text(
                          "Welcome to\nConference Radio",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 25.67,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.05,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 38),
                        SizedBox(
                          width: 194,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Enjoy talks from General Conference ',
                                  style: TextStyle(
                                    color: Color(0xFF595959),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    height: 1.47,
                                    letterSpacing: 1.36,
                                  ),
                                ),
                                TextSpan(
                                  text: 'on shuffle',
                                  style: TextStyle(
                                    color: Color(0xFF595959),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                    height: 1.47,
                                    letterSpacing: 1.36,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          'Press Play To Begin',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF595959),
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            height: 1.47,
                            letterSpacing: 1.36,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        IconButton(
                          iconSize: 80,
                          onPressed: () {
                            context.go(Routes.homePage.path);
                          },
                          icon: const Icon(
                            FluentIcons.play_circle_24_filled,
                            color: Color(0xFF0085FF),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 30),
                      child: Text(
                        'Opt out of anonymous analytics',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF595959),
                          fontSize: 15,
                          fontFamily: 'REM',
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          letterSpacing: 1.20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}