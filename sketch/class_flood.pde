class Flood {
  public int ID, size;
  private Maze maze;
  private ArrayList<Cell> cells;
  public boolean done, active;
  public float growCounter;

  Flood(Maze maze, int id) {
    this(maze, id, 0, 0);
  }

  Flood(Maze maze, int id, int i, int j) {
    this.ID = id;
    this.done = false;
    this.maze = maze;
    this.cells = new ArrayList<Cell>();
    this.active = false;
    this.cells.add(this.maze.get(i, j));
    this.growCounter = 1;
    this.size = 0;
  }

  // increase the flood boundary by one iteration
  public boolean step() {
    ArrayList<Cell> tmp = new ArrayList<Cell>();

    for (int i = 0; i < this.cells.size(); i++) {
      Cell cell = this.cells.get(i);

      if (cell.floodID < 0) {
        cell.floodID = this.ID;
        cell.lifespan = CELL_LIFESPAN_START;
        int assimilatedFloodID = addNeighbors(cell, tmp);
        if (assimilatedFloodID >= 0) {
          ArrayList<Cell> assimilatedCells = this.assimilate(assimilatedFloodID);
          if (assimilatedCells != null) tmp.addAll(assimilatedCells);
        }
      }
    }

    if (this.cells.size() == 0) {
      this.size = 0;
      return this.done = true;
    } else {
      this.cells = tmp;
      this.size += tmp.size();
      return false;
    }
  }

  // grow the flood by a growRate between 0 and 1
  public boolean grow(float growRate) {
    this.growCounter += growRate;

    if (this.growCounter >= 1) {
      this.growCounter = 0;
      return this.step();
    } else return false;
  }

  // cheat by digging a new wall in the flood boundary
  private boolean cheat() {
    for (Cell c : this.maze.cells) {
      if (c.floodID == this.ID) {
        Cell n = null;
        for (int i = 0; i < 4; i++) {
          switch (i) {
            case 0 : n = this.maze.get(c.x, c.y - 1); break;
            case 1 : n = this.maze.get(c.x + 1, c.y); break;
            case 2 : n = this.maze.get(c.x, c.y + 1); break;
            case 3 : n = this.maze.get(c.x - 1, c.y); break;
          }

          if (n != null && n.floodID < 0) {
            for (int w = 0; w < 4; w++) n.walls[w] = false;
            this.cells.add(n);
            this.done = false;
            return true;
          }
        }
      }
    }

    return false;
  }

  // add all non-floodID, non-null neighbors of a cell to the ArrayList
  // return the ID of the first flood connected
  private int addNeighbors(Cell cell, ArrayList<Cell> arr) {
    for (int i = 0; i < 4; i++) {
      Cell n = null;
      switch (i) {
        case 0 : n = this.maze.get(cell.x, cell.y - 1); break;
        case 1 : n = this.maze.get(cell.x + 1, cell.y); break;
        case 2 : n = this.maze.get(cell.x, cell.y + 1); break;
        case 3 : n = this.maze.get(cell.x - 1, cell.y); break;
      }

      if (n != null) {
        if (n.floodID < 0) {
          if (!cell.walls[i]) arr.add(n);
        } else if (n.floodID != this.ID && n.lifespan > CELL_LIFESPAN_DEATH) return n.floodID;
      }
    }
    return -1;
  }

  // get all cells from a specific floodID, and assimilate them to this flood
  // return all the new assimilated cells
  private ArrayList<Cell> assimilate(int id) {
    Flood f = this.maze.floods.get(id);
    if (f != null) {
      for (Cell c : this.maze.cells) {
        if (c.floodID == id) c.floodID = this.ID;
      }
      this.maze.floods.set(id, null);
      return f.cells;
    } else return null;
  }
}