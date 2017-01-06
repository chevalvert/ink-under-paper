import oscP5.*;
import netP5.*;

public class SMTOSC {
  OscP5 oscP5;
  NetAddress address;

  ArrayList<Finger> fingers;

  SMTOSC(PApplet parent, String remote, int port) {
    this.oscP5 = new OscP5(parent, 32000);
    this.address = new NetAddress(remote, port);

    this.fingers = new ArrayList<Finger>();
  }

  public void update() { this.fingers.clear(); }

  public void move(int id, int x, int y) {
    // println(id + "/" + x + "/" + y);
    if (id >= fingers.size()) {
      Finger f = new Finger(id).move(x, y);
      fingers.add(f);
    } else {
      fingers.get(id).move(x, y);
    }
  }

  public Finger[] getFingers() {
    return this.fingers.toArray(new Finger[this.fingers.size()]);
  }

  public class Finger {
    public int id, x, y;
    Finger(int id) { this.id = id; }

    public Finger move(int x, int y) {
      this.x = x;
      this.y = y;
      return this;
    }
  }

}

public void oscEvent(OscMessage message) {
  if (smtosc != null) {
    if (message.checkAddrPattern("/touch")) {
      if (message.checkTypetag("iff")) {
        int id = message.get(0).intValue();
        float x = message.get(1).floatValue();
        float y = message.get(2).floatValue();

        if (SMT_MIRROR_X) x = 1 - x;
        if (SMT_MIRROR_Y) y = 1 - y;

        smtosc.move(id, int(x * width), int(y * height));
        if (DEBUG) println(x + ", " + y);
      }
    }
  }
}