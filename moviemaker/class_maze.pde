public class Maze {
  public ArrayList<Flood> floods;
  public int cols, rows, visits, length;
  public PVector scale;
  public Cell currentCell, start, end;
  public Cell[] cells;
  public boolean done;

  Maze(int cols, int rows) {
    this(cols, rows, int(cols / 2), int(rows / 2));
  }

  Maze(int cols, int rows, int i, int j) {
    this.done = false;
    this.cols = cols;
    this.rows = rows;
    this.scale =  new PVector(width / cols, height / rows);

    this.cells = this.populate();
    this.length = this.cells.length;

    this.start = this.cells[i + j * cols];

    this.currentCell = this.start;
    this.currentCell.visited = true;
    this.visits = 1;

    this.floods = new ArrayList<Flood>();
  }

  // create a 1-dimensionnal array of position-aware cells
  private Cell[] populate() {
    Cell[] cells = new Cell[this.rows * this.cols];
    for (int j = 0; j < this.rows; j++) {
      for (int i = 0; i < this.cols; i++) {
        cells[index(i, j)] = new Cell(i, j);
      }
    }
    return cells;
  }

  // -------------------------------------------------------------------------

  // walk through the maze until completely generated
  public Maze generate() {
    this.done = false;
    while (!this.done) {
      this.done = this.step();
    }
    return this;
  }

  // walk through the maze, and return true if solved
  public boolean step() {
    if (this.currentCell != null) {
      // mark the current cell as visited
      this.currentCell.visited = true;
      this.visits++;
      // find the unvisited neighbors around the current cell
      ArrayList<Cell> neighbors = this.findNeighbors(this.currentCell, true);
      if (neighbors.size() > 0) {
        // dig through the wall to a random unvisited neighbor
        Cell neighbor = this.randomCell(neighbors);
        this.currentCell = this.dig(this.currentCell, neighbor);
      } else {
        // if all neighbors are visited, go hunt a new cell
        ArrayList<Cell> hunted = this.hunt(this.cells);
        // if the hunt is a success, dig between the cell and its visited neighbor
        if (hunted.size() > 0) {
          this.currentCell = this.dig(hunted.get(0), hunted.get(1));
        } else {
          // if the hunt isn't a success, then the maze is done
          this.end = this.currentCell;
          this.currentCell = null;
        }
      }
      return false;
    } else {
      return true;
    }
  }

  // find the first unvisited cell with a visited neihgbor
  private ArrayList<Cell> hunt(Cell[] cells) {
    ArrayList<Cell> result = new ArrayList<Cell>();
    if (cells.length > 0) {
      for (int i = 0; i < cells.length; i++) {
        Cell cell = cells[i];
        if (!cell.visited) {
          ArrayList<Cell> neighbors = this.findNeighbors(cell);
          for (int j = 0; j < neighbors.size(); j++) {
            Cell neighbor = neighbors.get(j);
            if (neighbor.visited) {
              result.add(neighbor);
              result.add(cell);
              break;
            }
          }
        }
      }
    }
    return result;
  }

  // -------------------------------------------------------------------------

  // return a random cell from an array of cells
  // if a bias must be implemented, do it here


  public Cell randomCell(ArrayList<Cell> cells) {
    return cells.get(int(random(cells.size())));
  }

  public Cell randomCell(Cell[] cells) {
    return cells[int(random(cells.length))];
  }

  // convert a (i,j) position to a 1-dimensionnal array index
  public int index(int i, int j) {
    if (i < 0 || i > this.cols - 1 || j < 0 || j > this.rows - 1) return -1;
    else return i + j * this.cols;
  }

  public Cell get(int i, int j) {
    int index = this.index(i, j);
    if (index >= 0) return this.cells[index];
    else return null;
  }

  // -------------------------------------------------------------------------

  // move from source and return target, while carving walls
  private Cell dig(Cell source, Cell target) {
    if (source != null && target != null) {
      int dx = target.x - source.x;
      int dy = target.y - source.y;
      if (dx > 0) {
        source.walls[1] = false;
        target.walls[3] = false;
      } else if (dx < 0) {
        source.walls[3] = false;
        target.walls[1] = false;
      }

      if (dy > 0) {
        source.walls[2] = false;
        target.walls[0] = false;
      } else if (dy < 0) {
        source.walls[0] = false;
        target.walls[2] = false;
      }

    }
    return target;
  }

  // return an array of all neighbors for a given cell
  private ArrayList<Cell> findNeighbors(Cell cell, boolean... _filterVisited) {
    boolean filterVisited = (_filterVisited.length > 0 && _filterVisited[0]);
    ArrayList<Cell> neighbors = new ArrayList<Cell>();
    for (int i = 0; i < 4; i++) {
      switch (i) {
        case 0 :
          if (cell.y - 1 > 0) {
            Cell neighbor = this.cells[this.index(cell.x + 0, cell.y - 1)];
            if (neighbor != null && (!filterVisited || (filterVisited && !neighbor.visited))) neighbors.add(neighbor);
          }
          break;
        case 1 :
          if (cell.x + 1 < this.cols) {
            Cell neighbor = this.cells[this.index(cell.x + 1, cell.y + 0)];
            if (neighbor != null && (!filterVisited || (filterVisited && !neighbor.visited))) neighbors.add(neighbor);
          }
          break;
        case 2 :
          if (cell.y + 1 < this.rows) {
            Cell neighbor = this.cells[this.index(cell.x + 0, cell.y + 1)];
            if (neighbor != null && (!filterVisited || (filterVisited && !neighbor.visited))) neighbors.add(neighbor);
          }
          break;
        case 3 :
          if (cell.x - 1 > 0) {
            Cell neighbor = this.cells[this.index(cell.x - 1, cell.y + 0)];
            if (neighbor != null && (!filterVisited || (filterVisited && !neighbor.visited))) neighbors.add(neighbor);
          }
          break;
      }
    }
    return neighbors;
  }

}