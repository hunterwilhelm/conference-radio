import 'package:conference_radio_flutter/constants/style_list.dart';
import 'package:conference_radio_flutter/routes.dart';
import 'package:conference_radio_flutter/services/talk_repository.dart';
import 'package:conference_radio_flutter/services/service_locator.dart';
import 'package:conference_radio_flutter/ui/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  static const route = Routes.homePage;

  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final repository = getIt<TalkRepository>();
    return Container(
      decoration: StyleList.backgroundGradient,
      child: Scaffold(
        appBar: const CustomAppBar(title: "Library"),
        body: Column(
          children: [],
        ),
      ),
    );
  }
}
