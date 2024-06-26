import 'package:conference_radio_flutter/constants/style_list.dart';
import 'package:conference_radio_flutter/page_manager.dart';
import 'package:conference_radio_flutter/routes.dart';
import 'package:conference_radio_flutter/services/service_locator.dart';
import 'package:conference_radio_flutter/ui/widgets/play_pause_button.dart';
import 'package:conference_radio_flutter/utils/locales.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/asset_names.dart';

class WelcomeBeginPage extends StatelessWidget {
  static const route = Routes.welcomeBeginPage;
  const WelcomeBeginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final goRouter = GoRouter.of(context);
    return Container(
      decoration: StyleList.backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 47),
                child: SvgPicture.asset(
                  SvgAssetNames.whiteLogo,
                  height: 112,
                ),
              ),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      children: [
                        Text(
                          tr(context).welcomeToConferenceRadio,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 25.67,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.05,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 38),
                        SizedBox(
                          width: 194,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: tr(context).enjoyTalks,
                                  style: const TextStyle(
                                    color: Color(0xFF595959),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    height: 1.47,
                                    letterSpacing: 1.36,
                                  ),
                                ),
                                TextSpan(
                                  text: tr(context).onShuffle,
                                  style: const TextStyle(
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
                        Text(
                          tr(context).pressPlayToBegin,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
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
                        Hero(
                          tag: 'playPauseButton',
                          child: PlayPauseButton(
                            isLoading: false,
                            isPaused: true,
                            onTap: () async {
                              SharedPreferences.getInstance().then((sharedPreferences) {
                                sharedPreferences.setBool("welcome_screen_dismissed", true);
                              });

                              final pageManager = getIt<PageManager>();
                              pageManager.play();

                              goRouter.go(Routes.homePage.path);
                            },
                          ),
                        ),
                      ],
                    ),
                    Container(),
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
