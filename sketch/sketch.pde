// cell.lifeSpan
// cell.lifeSpan--
// color(cell.lifeSpan);
// if (cell.lifeSpan <= 0) cell.floodID = -1;

Maze maze;
PGraphics frame;
SMTOSC smtosc;

void settings() {
  size(1920, 1080, OPENGL);
  // fullScreen(OPENGL);
}

void setup() {
  smtosc = new SMTOSC(this, "127.0.0.1", 12000);

  // maze generation
  int cols = int(width / 10);
  int rows = int(height / 10);
  maze = new Maze(cols, rows, int(cols / 2), 0);

  // ultra fast offscren pixels update
  // @SEE https://github.com/processing/processing/wiki/Advanced-OpenGL#textures
  hint(DISABLE_TEXTURE_MIPMAPS);
  ((PGraphicsOpenGL)g).textureSampling(3);
  frame = createGraphics(cols, rows, OPENGL);
  frame.beginDraw();
  frame.background(0);
  frame.endDraw();

  background(0);
}

void draw() {
  if (!maze.done) {

    surface.setTitle(int(map(maze.visits, 0, maze.cells.length, 0, 100)) + "%");

    // maze generation
    for (int i = 0; i < 100; i++) maze.done = maze.step();

    // display visited maze cells
    frame.loadPixels();
    int w = frame.width;
    for (Cell c : maze.cells) {
      if (c.visited) frame.pixels[c.x + c.y * w] = #FFFFFF;
    }
    frame.updatePixels();
    image(frame.get(), 0, 0, width, height);

  } else {

    surface.setTitle(int(frameRate) + "fps");

    for (SMTOSC.Finger f : smtosc.getFingers()) touch(f.x, f.y, true);
    smtosc.update();

    // display flooded maze cells
    frame.loadPixels();
    int w = frame.width;
    for (Cell c : maze.cells) {
      if (c.floodID >= 0) frame.pixels[c.x + c.y * w] = color((c.floodID % 2) * 127, 10);
    }
    frame.updatePixels();
    image(frame.get(), 0, 0, width, height);

  }
}

void touch(float x, float y, boolean dynamic) {
  int i = int(map(x, 0, width, 0, maze.cols));
  int j = int(map(y, 0, height, 0, maze.rows));

  Cell hover = maze.get(i, j);

  if (hover != null) {
    int floodID = hover.floodID;
    if (floodID < 0) {
      Flood f = new Flood(maze, maze.floods.size(), i, j);
      maze.floods.add(f);
      f.step();
    } else if (dynamic) {
      Flood f = maze.floods.get(floodID);
      if (f != null) {
        if (f.done) f.cheat();
        else f.step();
      }
    }
  }
}

void mouseDragged() {
  if (maze.done) {
    for (float t = 0; t < 1; t += 0.1) {
      PVector pos = PVector.lerp(new PVector(pmouseX, pmouseY), new PVector(mouseX, mouseY), t);
      touch(pos.x, pos.y, false);
    }
  }
}

void keyPressed() {
  if (key == 'R') setup();
  if (key == 'r') clear();
}

void clear() {
  background(255);
  frame.beginDraw();
  frame.background(255);
  frame.endDraw();
  for (Cell c : maze.cells) c.floodID = -1;
  maze.floods.clear();
}