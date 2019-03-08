

ControlP5 cp5;

public void createNewGUI() {
  cp5 = new ControlP5(this);
  
  /*
  cp5.addSlider("knob1")
      .setPosition(30,290)
      .setSize(48,128)
      .setRange(0,1023)
      ;
      */
      
  addCustomKnob("knobpepe")
      .setRange(0,1023)
      .setValue(0)
      .setPosition(200,290)
      .setRadius(30)
      .setDragDirection(Knob.VERTICAL)
      ;
}

void knob1(float value) {
  println("a slider event. setting background to "+value);
}

Knob addCustomKnob(String name) {
  Knob myController = new CustomKnob(cp5, name);
  //cp5.register(null, "", myController);
  myController.registerProperty( "value" );
  return myController;
}

class CustomKnob extends Knob {
  public CustomKnob(ControlP5 cp5 , String name) {
    super(cp5, name);
  }
  
  public Knob updateInternalEvents( PApplet theApplet ) {
    if ( isMousePressed && !cp5.isAltDown( ) ) {
      if ( isActive ) {
        controlP5.ControlWindow.Pointer pointer = _myControlWindow.getPointer();
        float c = ( _myDragDirection == HORIZONTAL ) ? pointer.getX() - pointer.getPreviousX() : pointer.getPreviousY() - pointer.getY();
        currentValue += ( c ) / resolution;
        if ( isConstrained ) {
          currentValue = PApplet.constrain( currentValue , 0 , 1 );
        }
        setInternalValue( currentValue );
      }
    }
    return this;
  }
}
