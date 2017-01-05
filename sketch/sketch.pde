// global options, see README for details
boolean FULLSCREEN = false;
boolean DEBUG = false;

color COLOR_ALIVE = color(0, 0, 0, 255);
color COLOR_DEAD  = color(255, 200, 200, 0);

int CELL_LIFESPAN_MAX = 255;
int CELL_LIFESPAN_DEATH = 200;
int CELL_LIFESPAN_START = 100;
int CELL_LIFESPAN_INCREMENT = +5;
int CELL_LIFESPAN_DECREMENT = -1;

float GROW_RATE_MIN = 0.3;
float GROW_RATE_MAX = 1.0;

// -------------------------------------------------------------------------

Maze maze;
PGraphics frame;
SMTOSC smtosc;

void settings() {
  if (FULLSCREEN) fullScreen(OPENGL);
  else size(displayWidth - 100, displayHeight - 50, OPENGL);
}

void setup() {
  if (!DEBUG) noCursor();

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
  frame.background(255, 0, 0);
  frame.endDraw();
}

void draw() {
  if (!maze.done) {
    if (!FULLSCREEN) surface.setTitle(int(map(maze.visits, 0, maze.cells.length, 0, 100)) + "%");

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
    if (!FULLSCREEN) surface.setTitle(int(frameRate) + "fps");
    background(255);

    // reset floods active states
    for (Flood f : maze.floods) {
      if (f != null) f.active = false;
    }

    // touch event
    for (SMTOSC.Finger f : smtosc.getFingers()) touch(f.x, f.y, true);
    smtosc.update();

    // DEBUG
    if (DEBUG && mousePressed) touch(mouseX, mouseY, true);

    // display flooded maze cells
    frame.loadPixels();
    int w = frame.width;
    for (Cell c : maze.cells) {
      // display only flooded cell
      if (c.floodID >= 0) {

        // update cell lifespan
        Flood parent = maze.floods.get(c.floodID);
        if (parent != null) {
          if (parent.active) {
            if (c.lifespan < CELL_LIFESPAN_MAX * 2) c.lifespan += CELL_LIFESPAN_INCREMENT;
          } else c.lifespan += CELL_LIFESPAN_DECREMENT;

          if (c.lifespan < 0) {
            parent.size--;
            c.floodID = -1;
          }
        }

        float t = norm(c.lifespan, 0, CELL_LIFESPAN_MAX);
        // println(t);
        frame.pixels[c.x + c.y * w] = lerpColor(COLOR_DEAD, COLOR_ALIVE, t);
      }

    }
    frame.updatePixels();
    image(frame.get(), 0, 0, width, height);

  }
}

void touch(float x, float y, boolean dynamic) {
  int i = int(map(x, 0, width, 0, maze.cols));
  int j = int(map(y, 0, height, 0, maze.rows));

  // get hovered cell
  Cell hover = maze.get(i, j);
  if (hover != null) {
    int floodID = hover.floodID;

    // if hovered cell isn't a flood, create a new one
    if (floodID < 0) {
      Flood f = new Flood(maze, maze.floods.size(), i, j);
      maze.floods.add(f);
      f.grow(GROW_RATE_MAX);
    } else if (dynamic) {
      // if hovered cell is in a flood, grow it
      Flood f = maze.floods.get(floodID);
      if (f != null && !f.active) {
        f.active = true;
        if (f.done) f.cheat();
        else {
          // the flood grow faster if smaller
          float growRate = map(f.size, 0, maze.cells.length, GROW_RATE_MAX, GROW_RATE_MIN);
          f.grow(growRate);
        }
      }
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