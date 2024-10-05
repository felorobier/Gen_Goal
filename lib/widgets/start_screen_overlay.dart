import 'package:GenGoal/eco_conscience.dart';
import 'package:GenGoal/providers/game_progress_provider.dart';
import 'package:GenGoal/providers/locale_provider.dart';
import 'package:GenGoal/providers/start_menu_provider.dart';
import 'package:GenGoal/widgets/utils.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StartScreenOverlay extends StatefulWidget {
  const StartScreenOverlay({super.key, required this.game});

  final GenGoal game; // Updated class reference

  @override
  State<StartScreenOverlay> createState() => _StartScreenOverlayState();
}

class _StartScreenOverlayState extends State<StartScreenOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  // late AppLocalizations _local;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double heightDiff = calculateBlackAreaHeight(context);
    final locale = context.watch<LocaleProvider>().locale;
    // _local = locale.languageCode == 'ja'
    //     ? AppLocalizationsJa()
    //     : AppLocalizationsEn();

    return FadeTransition(
      opacity: _opacityAnimation,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: heightDiff / 2),
        child: Center(
          child: Consumer<StartMenuProvider>(
            builder:
                (BuildContext context, StartMenuProvider value, Widget? child) {
              final provider = context.read<GameProgressProvider>();
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Container(
                  key: ValueKey<bool>(value.showMenu),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                  child: Column(
                    children: [
                      gradientText("Gen Goal"),
                      Expanded(
                        child: value.showMenu
                            ? Container(
                                decoration: BoxDecoration(),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                child: Column(
                                  children: [
                                    if (provider.doesSaveExist())
                                      textButton("Resume", context, () async {
                                        await playClickSound(widget.game);
                                        provider.loadProgress();
                                        widget.game.overlays
                                            .remove(PlayState.startScreen.name);
                                        widget.game.startGamePlay(provider);
                                      }),
                                    textButton("New Game", context, () async {
                                      await playClickSound(widget.game);
                                      if (widget.game.playSounds &&
                                          !FlameAudio.bgm.isPlaying) {
                                        FlameAudio.bgm.play(
                                            'Three-Red-Hearts-Penguin-Town.mp3',
                                            volume: widget.game.volume * 0.5);
                                      }

                                      /// reset progress - start fresh
                                      provider.resetProgress();

                                      /// player selection
                                      widget.game.overlays
                                          .remove(PlayState.startScreen.name);
                                      widget.game.overlays
                                          .add('playerSelection');
                                    }),
                                    textButton(
                                        '${"sounds"} ${widget.game.playSounds ? "on" : "off"}',
                                        context, () async {
                                      await playClickSound(widget.game);
                                      widget.game.playSounds =
                                          !widget.game.playSounds;
                                      if (widget.game.playSounds) {
                                        FlameAudio.bgm.play(
                                            'Three-Red-Hearts-Penguin-Town.mp3',
                                            volume: widget.game.volume * 1);
                                      } else {
                                        FlameAudio.bgm.stop();
                                      }
                                      setState(() {});
                                    }),
                                    // textButton(
                                    //     '${"language"} ${_local.localeName == 'en' ? 'Japanese' : 'English'}',
                                    //     context, () async {
                                    //   await playClickSound(widget.game);
                                    //   context
                                    //       .read<LocaleProvider>()
                                    //       .switchLocale();
                                    // }),
                                    textButton("about", context, () async {
                                      await playClickSound(widget.game);
                                      widget.game.overlays.add('about');
                                    }),
                                    textButton("exit", context, () async {
                                      await playClickSound(widget.game);
                                      openLink(
                                          "https://devpost.com/software/GenGoal");
                                    }),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
