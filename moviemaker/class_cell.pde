public class Cell {
  public int x, y, floodID;
  public int lifespan = CELL_LIFESPAN_START;

  public boolean visited;
  public boolean[] walls;
  public Cell source;

  Cell(int x, int y) {
    this.x = x;
    this.y = y;
    this.visited = false;
    this.floodID = -1;

    boolean[] walls = {true, true, true, true};
    this.walls = walls;
  }

  public Cell clone() {
    Cell c = new Cell(this.x, this.y);
    c.visited = true;
    c.floodID = this.floodID;
    c.walls = this.walls;
    c.source = this.source;
    return c;
  }
}