
public class Led {
  private int x;
  private int y;
  private int size;
  private int state;

  public Led(int x, int y, int size) {
    this.x = x;
    this.y = y;
    this.size = size;
  }

  void drawLed(OscMessage theOscMessage) {
    state = theOscMessage.get(0).intValue();
  }
  
  void draw(PApplet parent) {
    parent.pushMatrix();
    switch(state) {
      case 1:
        // Green
        parent.fill(0,255,0);
        break;
      case 2:
        // Blue
        parent.fill(0,0,255);
        break;
      case 3:
        // Aqua
        parent.fill(0,255,255);
        break;
      case 4:
        // Red
        parent.fill(255,0,0);
        break;
      case 5:
        // Yellow
        parent.fill(255,255,0);
        break;           
      case 6:
        // Magenta
        parent.fill(255,0,255);
        break;
      case 7:
        // White
        parent.fill(255,255,255);
        break;
      default:
        // Black
        parent.fill(0,0,0);
        break;
    }
    parent.stroke(0);
    parent.translate(0, 0);
    parent.rect(x, y, size, size);
    parent.popMatrix();
  }
}
