import 'dart:async';

import 'package:GenGoal/components/player.dart';
import 'package:GenGoal/eco_conscience.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';

class GoToNextMap extends PositionComponent
    with HasGameRef<GenGoal>, CollisionCallbacks {
  final String nextMapName;
  final double nextSpawnX;
  final double? nextSpawnY;
  final double? mapResMultiplier;

  GoToNextMap(
      {super.position,
      super.size,
      required this.nextMapName,
      required this.nextSpawnX,
      this.nextSpawnY,
      this.mapResMultiplier});

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(collisionType: CollisionType.passive));
    return super.onLoad();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      if (game.playSounds) FlameAudio.play('teleport.wav', volume: game.volume);
      other.loadNextMap(nextMapName, nextSpawnX,
          nextSpawnY: nextSpawnY, mapResMultiplier: mapResMultiplier);
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}
