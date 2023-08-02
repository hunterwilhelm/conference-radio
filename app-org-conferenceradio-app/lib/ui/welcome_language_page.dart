import 'package:conference_radio_flutter/constants/asset_names.dart';
import 'package:conference_radio_flutter/constants/style_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../main.dart';

class WelcomeLanguagePage extends StatelessWidget {
  static const route = Routes.welcomeLanguagePage;
  const WelcomeLanguagePage({super.key});

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
                flex: 2,
                child: Center(
                  child: SizedBox(
                    height: 300,
                    child: Column(
                      children: [
                        Expanded(
                          child: TextButton(
                            label: 'English',
                            onClick: () {
                              context.push(Routes.welcomeBeginPage.path);
                            },
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            label: 'Español',
                            onClick: () {},
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            label: 'Português',
                            onClick: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Flexible(child: Container()),
            ],
          ),
        ),
      ),
    );
  }
}

class TextButton extends StatelessWidget {
  final String label;
  final void Function() onClick;
  const TextButton({
    super.key,
    required this.label,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onClick();
      },
      child: SizedBox(
        width: double.infinity,
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 25.67,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.05,
            ),
          ),
        ),
      ),
    );
  }
}
