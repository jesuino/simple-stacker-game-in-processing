SquaresStackGame game;



int FRAME_RATE = 100;


void setup() {
  size(700, 550);
  frameRate(FRAME_RATE);
  game = new SquaresStackGame(400, 400);
}

void draw() {
  background(220, 220, 220);
  game.update();
  game.display();
}

