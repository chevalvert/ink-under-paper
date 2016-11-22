Maze maze;
PGraphics frame;
SMTOSC smtosc;

void settings() {
  // size(800, 800, OPENGL);
  fullScreen(OPENGL);
}

void setup() {
  smtosc = new SMTOSC(this, "127.0.0.1", 12000);

  // maze generation
  int cols = int(width / 5);
  int rows = int(height / 5);
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

    // reset floods active states
    for (Flood f : maze.floods) {
      if (f != null) f.active = false;
    }

    for (SMTOSC.Finger f : smtosc.getFingers()) touch(f.x, f.y, true);
    smtosc.update();

    // if (mousePressed) touch(mouseX, mouseY, true);

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
            if (c.lifespan < 1000) c.lifespan += 5;
          } else c.lifespan -= 1;

          if (c.lifespan < 10) c.floodID = -1;
        }

        frame.pixels[c.x + c.y * w] = color(255 - c.lifespan, 10);
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
      f.step();
    } else if (dynamic) {
      // if hovered cell is in a flood, grow it
      Flood f = maze.floods.get(floodID);
      if (f != null) {
        f.active = true;
        if (f.done) f.cheat();
        else f.step();
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