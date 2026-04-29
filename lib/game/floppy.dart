
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';

import 'package:flame/collisions.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

enum GameState { ready, playing, gameOver }

class FlappyGame extends FlameGame with HasCollisionDetection {
  late Bird bird;
  late PipeManager pipeManager;
  late TextComponent scoreText;
  late SpriteComponent background;

  GameState state = GameState.ready;
  int score = 0;

  @override
  Future<void> onLoad() async {
    // Load background image
    final bgSprite = await loadSprite('0.png');
    background = SpriteComponent()
      ..sprite = bgSprite
      ..size = size; // fill screen
    add(background);

    // Load audio
    await FlameAudio.audioCache.loadAll(['Tintin.mp3', 'Tintin.mp3']);
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('Tintin.mp3', volume: 0.5);
    // Load bird and pipes
    bird = Bird();
    pipeManager = PipeManager();

    scoreText = TextComponent(
      text: '0',
      position: Vector2(size.x / 2, 50),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 40,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    add(bird);
    add(pipeManager);
    add(scoreText);
  }

  // Button jump function
  void jump() {
    if (state == GameState.ready) {
      state = GameState.playing;
      bird.jump();
    } else if (state == GameState.playing) {
      bird.jump();
    } else if (state == GameState.gameOver) {
      restart();
    }
  }

  void addScore() {
    score++;
    scoreText.text = score.toString();

    // Show +1 effect
    add(ScoreEffect("+1", bird.position + Vector2(20, 0), Colors.green));
  }

  void gameOver() {
    if (state == GameState.gameOver) return;
    state = GameState.gameOver;
    bird.velocityY = 0;
    FlameAudio.bgm.stop();
  }

  void restart() {
    score = 0;
    scoreText.text = '0';
    bird.reset();
    pipeManager.reset();
    state = GameState.ready;
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('bgm.mp3', volume: 0.5);
  }
}



class Bird extends SpriteComponent
    with CollisionCallbacks, HasGameRef<FlappyGame> {
  double velocityY = 0;
  final double gravity = 800;
  final double jumpForce = -350;

  late Sprite normalSprite;
  late Sprite winnerSprite;
  late Sprite loserSprite;

  @override
  Future<void> onLoad() async {
    size = Vector2(60, 45); //
    position = Vector2(100, gameRef.size.y / 2);

    normalSprite = await gameRef.loadSprite('bird.png');
    winnerSprite = await gameRef.loadSprite('blue.png');
    loserSprite = await gameRef.loadSprite('green.png');

    sprite = normalSprite;

    add(RectangleHitbox());
  }

  void updateSprite() {
    if (gameRef.state == GameState.gameOver) {
      sprite = loserSprite;
    } else if (gameRef.state == GameState.playing && gameRef.score >= 10) {
      sprite = winnerSprite;
    } else {
      sprite = normalSprite;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    updateSprite();

    if (gameRef.state != GameState.playing) return;

    velocityY += gravity * dt;
    position.y += velocityY * dt;

    if (position.y < 0) {
      position.y = 0;
      velocityY = 0;
    }
    if (position.y + size.y > gameRef.size.y) {
      position.y = gameRef.size.y - size.y;
      gameRef.gameOver();
    }
  }

  void jump() {
    velocityY = jumpForce;
    FlameAudio.play('jump.wav');
  }

  void reset() {
    position.y = gameRef.size.y / 2;
    velocityY = 0;
    sprite = normalSprite;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Pipe) {
      gameRef.add(ScoreEffect("-1", position + Vector2(20, 0), Colors.red));
      gameRef.gameOver();
    }
  }
}

class ScoreEffect extends TextComponent with HasGameRef<FlappyGame> {
  double lifetime = 0.8;

  ScoreEffect(String text, Vector2 position, Color color)
    : super(
        text: text,
        position: position.clone(),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: 30,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  @override
  void update(double dt) {
    super.update(dt);
    position.y -= 60 * dt; 
    lifetime -= dt;
    if (lifetime <= 0) removeFromParent();
  }
}


class Pipe extends RectangleComponent
    with CollisionCallbacks, HasGameRef<FlappyGame> {
  bool passed = false;

  Pipe({required Vector2 position, required Vector2 size})
    : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    paint = Paint()..color = Colors.green;
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.state != GameState.playing) return;

    position.x -= 200 * dt;

    if (!passed && position.x + size.x < gameRef.bird.position.x) {
      passed = true;
      gameRef.addScore();
    }

    if (position.x + size.x < 0) removeFromParent();
  }
}

class PipeManager extends Component with HasGameRef<FlappyGame> {
  final double spawnInterval = 2.0;
  double timer = 0;
  final double gap = 160;

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.state != GameState.playing) return;

    timer += dt;
    if (timer > spawnInterval) {
      timer = 0;
      spawnPipe();
    }
  }

  void spawnPipe() {
    final rand = Random();
    final screenHeight = gameRef.size.y;

    final maxHeight = screenHeight - gap - 100;
    final topHeight = rand.nextDouble() * maxHeight + 50;

    final topPipe = Pipe(
      position: Vector2(gameRef.size.x, 0),
      size: Vector2(60, topHeight),
    );

    final bottomPipe = Pipe(
      position: Vector2(gameRef.size.x, topHeight + gap),
      size: Vector2(60, screenHeight - (topHeight + gap)),
    );

    gameRef.add(topPipe);
    gameRef.add(bottomPipe);
  }

  void reset() {
    timer = 0;
    gameRef.children.whereType<Pipe>().forEach(
      (pipe) => pipe.removeFromParent(),
    );
  }
}
