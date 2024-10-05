import 'package:GenGoal/components/story_progress.dart';
import 'package:GenGoal/eco_conscience.dart';
import 'package:GenGoal/providers/game_progress_provider.dart';
import 'package:GenGoal/providers/locale_provider.dart';
import 'package:GenGoal/providers/start_menu_provider.dart';
import 'package:GenGoal/widgets/about_overlay.dart';
import 'package:GenGoal/widgets/button_controls_overlay.dart';
import 'package:GenGoal/widgets/custom_toast_overlay.dart';
import 'package:GenGoal/widgets/feedback_toast_overlay.dart';
import 'package:GenGoal/widgets/game_over_overlay.dart';
import 'package:GenGoal/widgets/lesson_overlay.dart';
import 'package:GenGoal/widgets/npc_dialog_overlay.dart';
import 'package:GenGoal/widgets/pause_button_overlay.dart';
import 'package:GenGoal/widgets/pause_menu_overlay.dart';
import 'package:GenGoal/widgets/player_selection_overlay.dart';
import 'package:GenGoal/widgets/restart_warning_overlay.dart';
import 'package:GenGoal/widgets/start_screen_overlay.dart';
import 'package:GenGoal/widgets/story_arc_overlay.dart';
import 'package:GenGoal/widgets/tap_to_start_overlay.dart';
import 'package:GenGoal/widgets/utils.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/restart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  StoryProgress.init();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const GameApp());
}

class GameApp extends StatelessWidget {
  const GameApp({Key? key}) : super(key: key);

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => StartMenuProvider()),
          ChangeNotifierProvider(create: (_) => GameProgressProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => RestartProvider()),
        ],
        child: Consumer<RestartProvider>(builder: (context, ref, child) {
          /// restart game
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                useMaterial3: true,
                textTheme: GoogleFonts.vt323TextTheme().apply(),
              ),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              navigatorObservers: <NavigatorObserver>[observer],
              home: Scaffold(
                resizeToAvoidBottomInset: false,
                body: GameWidget(
                    game: GenGoal(),
                    focusNode: gameFocus,
                    loadingBuilder: (_) => const Center(
                            child: Text(
                          "Loading...",
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        )),
                    overlayBuilderMap: {
                      PlayState.startScreen.name: (context, GenGoal game) =>
                          StartScreenOverlay(game: game),
                      PlayState.showingToast.name: (context, GenGoal game) =>
                          CustomToastOverlay(game: game),
                      PlayState.storyPlaying.name: (context, GenGoal game) =>
                          StoryArcOverlay(game: game),
                      PlayState.lessonPlaying.name: (context, GenGoal game) =>
                          LessonOverlay(game: game),
                      PlayState.gameOver.name: (context, GenGoal game) =>
                          GameOverOverlay(game: game),
                      'buttonControls': (context, GenGoal game) =>
                          ButtonControlsOverlay(game: game),
                      'pauseButton': (context, GenGoal game) =>
                          PauseButtonOverlay(game: game),
                      'pauseMenu': (context, GenGoal game) =>
                          PauseMenuOverlay(game: game),
                      'playerSelection': (context, GenGoal game) =>
                          PlayerSelectionOverlay(game: game),
                      'npcDialog': (context, GenGoal game) =>
                          NpcDialogOverlay(game: game),
                      'restartWarning': (context, GenGoal game) =>
                          RestartWarningOverlay(game: game),
                      'about': (context, GenGoal game) =>
                          AboutOverlay(game: game),
                      'feedBackToast': (context, GenGoal game) =>
                          FeedBackToastOverlay(game: game),
                      'tapToStart': (context, GenGoal game) =>
                          TapToStartOverlay(game: game),
                    }),
              ));
        }));
  }
}
