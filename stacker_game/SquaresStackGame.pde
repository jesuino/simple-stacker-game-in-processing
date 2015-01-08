class SquaresStackGame {

  /*
    The number of points that can be awarded
   */
  int MAX_POINTS = 15;
  int MIN_POINTS = 5;

  /*
    Indicates when the player lose the game
   */
  boolean gameOver = false;

  /*
    The total of points
   */
  int score = 0;

  /*
     The size of the game playing area 
   */
  float MAX_W;
  float MAX_H;
  
  int INITIAL_COL = 3;
  int INITIAL_LINES = 2;

  /*
    Initial number of lines and columns which will change according to the game level
   */
  int _LINES = INITIAL_LINES;
  int _COLUMNS = INITIAL_COL; 

  /*
    The size of each rectangle, which will change according to the number of lines and columns
   */
  float _W;
  float _H;

  /*
    The higest level which someone could reach
   */
  int MAX_LEVEL = 20;

  /*
    Level which will be increased as soon as the user reaches the top
   */
  int level = 1;

  float initialX = 0;
  float initialY = 0;

  /*
     The current line which the rectangle will be moving 
   */
  int MOVING_LINE;

  /*
    The direction of the rectangle movement
   */
  int direction = 1;

  /*
    The matrix of our "squares"(actually rectangles) which size is dinamic
   */
  boolean[][] squares;

  // a workaround to avoid mistakely select multiple times 
  boolean holding = false;

  SquaresStackGame(float w, float h) {
    MAX_W = w;
    MAX_H = h;
    updateMatrix();
  }

  void update() {
    holding = keyPressed && holding;
    if (gameOver) {
      if (keyPressed  && ! holding) {
        restartGame();
        holding = true;
      }
    } 

    int curPos;
    // udpdate the square's position
    // we will not always move the square, the pos update will be faster according to how close user gets to the top
    int levelIncrease = level;
    levelIncrease +=  1 + _LINES - MOVING_LINE;    
    levelIncrease = constrain(levelIncrease, 0, MAX_LEVEL);
    int rate = (int)map(levelIncrease, 1, MAX_LEVEL, FRAME_RATE, FRAME_RATE / 20);
    boolean updatePos = frameCount % rate == 0;
    for (curPos = 0; curPos < _COLUMNS && updatePos; curPos++) { 
      if (squares[curPos][MOVING_LINE]) {       
        if (curPos == 0) {
          direction = 1;
        } else if (curPos == _COLUMNS - 1) {
          direction = -1;
        }
        // update the square matrix
        squares[curPos][MOVING_LINE] = false;
        if (_COLUMNS != 1)
          squares[curPos + direction][MOVING_LINE] = true;
        break;
      }
    }
    // if user press a key, move to the line above
    if (keyPressed && ! holding) {
      checkStack();
      if (MOVING_LINE == 0) {
        level++;
        updateMatrix();
      } else {
        MOVING_LINE--;
        squares[(int)random(_COLUMNS-1)][MOVING_LINE] = true;
      }
      holding = true;
    }
  }

  void drawSquares() {
    for (int x = 0; x < _COLUMNS; x++) {
      for (int y = 0; y < _LINES; y++) {
        if (squares[x][y]) {
          fill(255, 0, 0);
          rect(initialX + x * _W, initialY + y *_H, _W, _H);
          if (y != _LINES - 1 && y != MOVING_LINE) {
            int leftColumn = x == 0 ? -1 : x - 1; 
            int rightColumn = (x == _COLUMNS - 1) ? -1 : x + 1;
            int line = y + 1;
            if (leftColumn != -1 || rightColumn != -1) {
              fill(255, 0, 0, 50);
              rect(initialX + x * _W, initialY + line *_H, _W, _H);
            }
          }
        }
      }
    }
  }

  void display() {
    drawGrid();
    drawSquares();
    drawTexts();
  }

  void drawGrid() {
    stroke(180);
    for (int x = 0; x < _COLUMNS; x++) {
      for (int y = 0; y < _LINES; y++) {
        fill(255);
        rect(initialX + x * _W, initialY + y * _H, _W, _H);
      }
    }
  }

  void drawTexts() {
    if (gameOver) {
      fill(0);
      textSize(70);
      text("Game Over!", initialX, height / 2 );
      textSize(20);   
      fill(0, 0, 200);      
      text("Press any key to continue", initialX, height / 2 + 40);
    }
    fill(0, 200, 0);
    textSize(40);
    text("Level: " + level + "\nScore: " + score, initialX + 10, initialY + MAX_H + 50);
  }

  void updateMatrix() {
    _LINES = level * 2;
    _COLUMNS += level%3 == 0 ? 1: 0;
    squares = new boolean[_COLUMNS][_LINES];
    squares[0][_LINES -1] = true;
    MOVING_LINE = _LINES-1;
    _W = MAX_W / _COLUMNS;
    _H = MAX_H / _LINES;
    initialX = width / 2 -  (_COLUMNS * _W / 2);
    initialY =  10;
  }

  void checkStack() {
    // no need to check at the first line
    if (MOVING_LINE == _LINES-1) {
      return;
    }
    for (int i = 0; i < _COLUMNS; i++) {
      if (squares[i][MOVING_LINE]) {
        int lineToCheck = MOVING_LINE + 1;
        int leftColumn = i == 0 ? -1 : i - 1; 
        int rightColumn = (i == _COLUMNS - 1) ? -1 : i + 1;
        // perfect stack, highest score
        if (squares[i][lineToCheck]) {
          score += MAX_POINTS;
        } else if ((leftColumn != -1 && squares[leftColumn][lineToCheck]) || 
          (rightColumn != -1 && squares[rightColumn][lineToCheck])) {
          score += MIN_POINTS;
        } else {
          gameOver = true;
        }
      }
    }
  }

  void restartGame() {
    level = 1;
    score = 0;
    updateMatrix();
    gameOver = false;
    _COLUMNS = INITIAL_COL; 
    _LINES = INITIAL_LINES; 
  }
  
}
