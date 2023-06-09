import 'dart:async';

import 'package:brick_break_game/items/ball.dart';
import 'package:brick_break_game/items/brick.dart';
import 'package:brick_break_game/items/player.dart';
import 'package:brick_break_game/screens/coverscreen.dart';
import 'package:brick_break_game/screens/gameoverscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum Direction { UP, DOWN, LEFT, RIGHT }

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Ball variables
  double ballX = 0;
  double ballY = 0;
  double ballXincrements = 0.01;
  double ballYincrements = 0.01;
  var ballYDirection = Direction.DOWN;
  var ballXDirection = Direction.LEFT;

  // Player variables
  double playerX = -0.2;
  double playerWidth = 0.2;
  late Timer timer;

  // Brick variables
  static double firstBrickX = -1 + wallGap;
  static double firstBrickY = -0.9;
  static double brickWidth = 0.4;
  static double brickHeight = 0.05;
  static double brickGap = 0.1;
  static double numberOfBricksInRow = 3;
  static double wallGap =
      0.5 * (2 - numberOfBricksInRow * brickWidth - (numberOfBricksInRow - 1) * brickGap);
  bool brickBroken = false;

 List<List<dynamic>> myBricks = [
  //[x, y, brickBroken]
  [firstBrickX + 0 * (brickWidth + brickGap), firstBrickY, false],
  [firstBrickX + 1 * (brickWidth + brickGap), firstBrickY, false],
  [firstBrickX + 2 * (brickWidth + brickGap), firstBrickY, false],
  // Additional bricks
  [firstBrickX + 0 * (brickWidth + brickGap), firstBrickY + brickHeight + brickGap, false],
  [firstBrickX + 1 * (brickWidth + brickGap), firstBrickY + brickHeight + brickGap, false],
  [firstBrickX + 2 * (brickWidth + brickGap), firstBrickY + brickHeight + brickGap, false],
];

  // Game settings
  bool hasGameStarted = false;
  bool isGameOver = false;

  int score = 0;

  // Start game
  void startGame() {
    hasGameStarted = true;
    timer = Timer.periodic(Duration(milliseconds: 5), (timer) {
      // Update direction
      updateDirection();
      // Move ball
      moveBall();

      // Check if player is dead
      if (isPlayerDead()) {
        timer.cancel();
        setState(() {
          isGameOver = true;
        });
      }
      // Check if brick is broken
      checkForBrickBroken();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void checkForBrickBroken() {
  // Check for when ball is inside the brick (aka hits brick)
  for (int i = 0; i < myBricks.length; i++) {
    if (ballX >= myBricks[i][0] &&
        ballX <= myBricks[i][0] + brickWidth &&
        ballY <= myBricks[i][1] + brickHeight &&
        !myBricks[i][2]) {
      setState(() {
        myBricks[i][2] = true;
        score++; // Increase score when a brick is broken

        // Update ball direction based on the side of the brick hit
        // ...

        // Check if all bricks are broken
        if (score == myBricks.length) {
          // Show total score instead of "Game Over" screen
          timer.cancel();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Builder(
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Congre you win'),
                    content: Text('Total Score: $score'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                          resetGame();
                        },
                        child: Text('Play Again'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        }
      });
    }
  }
}


  // Return the side with the smallest distance
  String findMin(double a, double b, double c, double d) {
    List<double> myList = [a, b, c, d];
    double currentMin = a;
    for (int i = 0; i < myList.length; i++) {
      if (myList[i] < currentMin) {
        currentMin = myList[i];
      }
    }
    if ((currentMin - a).abs() < 0.01) {
      return 'left';
    } else if ((currentMin - b).abs() < 0.01) {
      return 'right';
    } else if ((currentMin - c).abs() < 0.01) {
      return 'top';
    } else if ((currentMin - d).abs() < 0.01) {
      return 'bottom';
    }
    return '';
  }

  bool isPlayerDead() {
  // Player dies if ball reaches the bottom of the screen
  if (ballY >= 1) {
    return true;
  }
  return false;
}


 void moveBall() {
  setState(() {
    // Move vertically
    if (ballYDirection == Direction.DOWN) {
      ballY += ballYincrements;
    } else if (ballYDirection == Direction.UP) {
      ballY -= ballYincrements;
    }

    // Move horizontally
    if (ballXDirection == Direction.LEFT) {
      ballX -= ballXincrements;
      if (ballX < playerX - ballXincrements) {
        // Check if the ball is within the range of the player's height
        if (ballY >= 0.9 && ballY <= 1) {
          // Reverse the horizontal direction if the ball hits the left side of the player
          ballXDirection = Direction.RIGHT;
        }
      }
    } else if (ballXDirection == Direction.RIGHT) {
      ballX += ballXincrements;
      if (ballX > playerX + playerWidth - ballXincrements) {
        // Check if the ball is within the range of the player's height
        if (ballY >= 0.9 && ballY <= 1) {
          // Reverse the horizontal direction if the ball hits the right side of the player
          ballXDirection = Direction.LEFT;
        }
      }
    }
  });
}




  void updateDirection() {
  setState(() {
    // Ball goes up when it hits the player
    if (ballY >= 0.9 && ballY <= 1 && ballX >= playerX && ballX <= playerX + playerWidth) {
      ballYDirection = Direction.UP;
    }
    // Ball goes down when it hits the top of the screen
    else if (ballY <= -1) {
      ballYDirection = Direction.DOWN;
    }
    // Ball goes left when it hits the right wall
    if (ballX >= 1) {
      ballXDirection = Direction.LEFT;
    }
    // Ball goes right when it hits the left wall
    else if (ballX <= -1) {
      ballXDirection = Direction.RIGHT;
    }
    // Check if the ball hits the left side of the player
    else if (ballX <= playerX && ballY >= 0.9 && ballY <= 1) {
      ballXDirection = Direction.LEFT;
    }
  });
}

  void moveLeft() {
    setState(() {
      // Only move left if moving left doesn't move the player off the screen
      if (!(playerX - 0.2 <= -1.2)) {
        playerX -= 0.2;
      }
    });
  }

  void moveRight() {
    setState(() {
      // Only move right if moving right doesn't move the player off the screen
      if (!(playerX + 0.2 >= 1)) {
        playerX += 0.2;
      }
    });
  }

  // Reset game back to initial values when user hits play again
 void resetGame() {
  setState(() {
    playerX = -0.2;
    ballX = 0;
    ballY = 0;
    isGameOver = false;
    hasGameStarted = false;
    myBricks = [
      //[x, y, brickBroken]
      [firstBrickX + 0 * (brickWidth + brickGap), firstBrickY, false],
      [firstBrickX + 1 * (brickWidth + brickGap), firstBrickY, false],
      [firstBrickX + 2 * (brickWidth + brickGap), firstBrickY, false],
      [firstBrickX + 0 * (brickWidth + brickGap), firstBrickY + brickHeight + brickGap, false],
      [firstBrickX + 1 * (brickWidth + brickGap), firstBrickY + brickHeight + brickGap, false],
      [firstBrickX + 2 * (brickWidth + brickGap), firstBrickY + brickHeight + brickGap, false],
    ];
    score = 0; // Reset score
  });
}

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          moveLeft();
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          moveRight();
        }
      },
      child: GestureDetector(
        onTap: startGame,
        child: Scaffold(
          backgroundColor: Colors.deepPurple[100],
          body: Center(
            child: Stack(
              children: [
                // Tap to play
                if (!hasGameStarted)
                  CoverScreen(hasGameStarted: hasGameStarted,),
                // Game over screen
                if (isGameOver)
                  GameOverScreen(
                    function: resetGame, isGameOver: isGameOver,
                  ),
                // Ball
                MyBall(
                  ballX: ballX,
                  ballY: ballY,
                ), // Pass ballX and ballY to MyBall widget
                // Player
                MyPlayer(
                  playerX: playerX,
                  playerWidth: playerWidth,
                ),
                // Bricks
                for (var brick in myBricks)
                  if (!brick[2])
                    MyBrick(
                      brickX: brick[0],
                      brickY: brick[1],
                      brickWidth: brickWidth,
                      brickHeight: brickHeight, brickBroken: brickBroken,
                    ),
                // Score display
                Positioned(
                  top: 10,
                  right: 10,
                  child: Text(
                    'Score: $score',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_left),
                        onPressed: moveLeft,
                      ),
                      SizedBox(width: 20),
                      IconButton(
                        icon: Icon(Icons.arrow_right),
                        onPressed: moveRight,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
