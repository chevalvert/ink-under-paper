public class Cell {
  public int x, y, floodID;
  public int lifespan = 0;

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

  public void die () { this.die(CELL_LIFESPAN_DECREMENT); }
  public void die (int amt) {
    if (this.lifespan > 0) this.lifespan += amt;
  }

  public void grow () {
    if (this.lifespan < CELL_LIFESPAN_MAX) this.lifespan += CELL_LIFESPAN_INCREMENT;
  }
}