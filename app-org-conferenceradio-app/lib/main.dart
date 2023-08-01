import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:conference_radio_flutter/service/audio_player_service.dart';
import 'package:conference_radio_flutter/service/csv_service.dart';
import 'package:conference_radio_flutter/widgets/position_seek_widget.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void main() {
  AssetsAudioPlayer.setupNotificationsOpenAction((notification) {
    //custom action
    return true; //true : handled, does not notify others listeners
    //false : enable others listeners to handle it
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() async {
    final stopwatch = Stopwatch()..start();

    // Call the asynchronous function
    await checkForUpdatesAndApply();

    // Stop the stopwatch
    stopwatch.stop();

    // Print the elapsed time
    print('Elapsed time: ${stopwatch.elapsed}');

    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _counter % 2 == 0 ? TalkPlayer() : Container(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class TalkPlayer extends StatefulWidget {
  const TalkPlayer({super.key});

  @override
  State<TalkPlayer> createState() => _TalkPlayerState();
}

class _TalkPlayerState extends State<TalkPlayer> {
  AudioPlayerService? audioPlayerService;
  @override
  void initState() {
    AudioPlayerService.init().then((value) {
      setState(() {
        audioPlayerService = value;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    print("dispose");
    audioPlayerService?.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    print("reassemble");
    audioPlayerService?.dispose();
    super.reassemble(); // must call
  }

  @override
  Widget build(BuildContext context) {
    final audioPlayer_ = audioPlayerService;
    if (audioPlayer_ == null) {
      return const CircularProgressIndicator();
    }
    return _TalkPlayer(audioService: audioPlayer_);
  }
}

class _TalkPlayer extends HookWidget {
  final AudioPlayerService audioService;
  const _TalkPlayer({required this.audioService});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListenableBuilder(
          listenable: audioService,
          builder: (context, child) {
            final talk = audioService.currentTalk;
            var textStyle = TextStyle(
              color: Colors.black,
              fontSize: 25.67,
              fontFamily: 'REM',
              fontWeight: FontWeight.w600,
              letterSpacing: 2.05,
            );
            return Container(
              width: 274,
              height: 274,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: Colors.white.withOpacity(0.7300000190734863),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0x4C818181)),
                  borderRadius: BorderRadius.circular(46),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    '${talk?.month == 4 ? "April" : "October"}\n${talk?.year}',
                    textAlign: TextAlign.center,
                    style: textStyle,
                  ),
                  Container(
                    width: 124,
                    decoration: const ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 0.50,
                          strokeAlign: BorderSide.strokeAlignCenter,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '${talk?.type}',
                    textAlign: TextAlign.center,
                    style: textStyle,
                  ),
                ],
              ),
            );
          },
        ),
        ListenableBuilder(
          listenable: audioService,
          builder: (context, child) {
            final talk = audioService.currentTalk;
            return Column(
              children: [
                Text(talk?.title ?? ""),
                Text(talk?.name ?? ""),
              ],
            );
          },
        ),
        StreamBuilder<RealtimePlayingInfos>(
          stream: audioService.audioPlayer.realtimePlayingInfos,
          builder: (context, snapshot) {
            return PositionSeekWidget(
              // currentPosition: snapshot.data?.currentPosition ?? Duration.zero,
              // duration: snapshot.data?.duration ?? Duration.zero,
              currentPosition: snapshot.data?.currentPosition ?? Duration.zero,
              duration: snapshot.data?.duration ?? Duration.zero,
              seekTo: (to) {
                audioService.audioPlayer.seek(to);
              },
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(FluentIcons.arrow_shuffle_48_regular),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(FluentIcons.previous_16_regular),
              onPressed: () {
                audioService.play(indexDelta: -1);
              },
            ),
            PlayerBuilder.isPlaying(
              player: audioService.audioPlayer,
              builder: (context, isPlaying) {
                return IconButton(
                  onPressed: () {
                    if (!isPlaying) {
                      audioService.play();
                    } else {
                      audioService.pause();
                    }
                  },
                  icon: isPlaying ? const Icon(FluentIcons.pause_16_regular) : const Icon(FluentIcons.play_16_regular),
                );
              },
            ),
            IconButton(
              icon: const Icon(FluentIcons.next_16_regular),
              onPressed: () {
                audioService.play(indexDelta: 1);
              },
            ),
            IconButton(
              icon: Transform.translate(
                offset: Offset(0, -2),
                child: const Icon(FluentIcons.timer_24_regular),
              ),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}
