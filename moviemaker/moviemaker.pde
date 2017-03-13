// global options, see README for details
boolean FULLSCREEN = true;
boolean DEBUG = false;

color COLOR_ALIVE = color(0, 0, 0, 255);
color COLOR_DEAD  = color(255, 200, 200, 0);

int CELL_RESOLUTION = 4;
int CELL_LIFESPAN_MAX = 255;
int CELL_LIFESPAN_DEATH = 200;
int CELL_LIFESPAN_START = 100;
int CELL_LIFESPAN_INCREMENT = +5;
int CELL_LIFESPAN_DECREMENT = -1;

float GROW_RATE_THRESHOLD = 0.3;
float GROW_RATE_MIN = 0.3;
float GROW_RATE_MAX = 1.0;

// -------------------------------------------------------------------------

Maze maze;
PGraphics frame;

void settings() {
  size(268 * 2, 63 * 2, OPENGL);
}

PVector[] pos;

void setup() {
  // maze generation
  int cols = int(width / CELL_RESOLUTION);
  int rows = int(height / CELL_RESOLUTION);
  maze = new Maze(cols, rows, int(cols / 2), 0);

  pos = new PVector[5];
  for (int i = 0; i < pos.length; i++) pos[i] = new PVector(random(width), random(height));

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
    background(255);

    // reset floods active states
    for (Flood f : maze.floods) {
      if (f != null) f.active = false;
    }

    // touch event
    // if (mousePressed) touch(mouseX, mouseY, true);
    // for (PVector p : pos) touch(p.x, p.y, true);
    // touch(width / 2, 1, true);
    // touch(width / 2, height / 2, true);
    touch(1, height - 1, true);
    touch(width - 1, 1, true);

    // touch(1, 1, true);
    // touch(width - 1, 1, true);
    // touch(132, 1, true);

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

    saveFrame("export/frame-#####.tif");
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
          float maxSize = maze.cells.length * GROW_RATE_THRESHOLD;
          float growRate = map(min(f.size, maxSize), 0, maxSize, GROW_RATE_MAX, GROW_RATE_MIN);
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