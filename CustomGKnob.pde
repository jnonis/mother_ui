
class CustomGKnob extends GKnob {
 
  public CustomGKnob(PApplet theApplet, float p0, float p1, float p2, float p3, float gripAmount) {
    super(theApplet, p0, p1, p2, p3, gripAmount);
  }
  
  protected float getAngleFromUser(float px, float py){
    float degs = 0;
    switch(mode){
      case CTRL_ANGULAR:
        degs = calcRealAngleFromXY(ox, oy);
        break;
      case CTRL_HORIZONTAL:
        degs = sensitivity * (px - startMouseX);
        break;
      case CTRL_VERTICAL:
        degs = sensitivity * (startMouseY - py);
        break;
    }
    return degs;
  }
}
