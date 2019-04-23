import controlP5.*;
import oscP5.*;
import netP5.*;
import g4p_controls.*;
import java.util.Queue;
import java.util.Arrays;
import java.util.Comparator;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.lang.Process;

static final boolean DEV = true;
static final String ROOT = "/home/pi/pd/organelle/Organelle_Patches";

// GPIO
static final int CONTROL_MODE_KNOBS = 0;
static final int CONTROL_MODE_MENU = 1;
GPIOControl control;
int controlMode = CONTROL_MODE_KNOBS;

// GUI
Oled oled;
Led led;

// OSC
OscP5 oscP5;
NetAddress myRemoteLocation;

/** Status. */
boolean patchList = true;
boolean showInfoBar = true;
boolean enablePatchSub = false;
boolean patchLoaded = false;
boolean lineMode = true;

File[] patches;
int patchIndex = 0;
int patchSelected = 0;
int patchLoadedIndex = -1;

long openPressedTime = 0;

void setup() {
  //size(320,480);
  fullScreen();
  frameRate(15);
  noCursor();
  
  /* start oscP5, listening for incoming messages at port 4001 */
  oscP5 = new OscP5(this,4001);
  myRemoteLocation = new NetAddress("127.0.0.1",4000);
  
  background(237, 237, 237);
  //fill(0, 130, 130);
  //noStroke();
  //rect(0, 212, 480, 320);
  //rect(384, 0, 480, 212);
  
  // Init GPIO control
  control = new GPIOControl();
  control.attachEncoderListener(this, "handleEncoders");
  control.attachButtonListener(this, "handleButtons");
  
  //createNewGUI();
  oled = new Oled();
  led = new Led(192, 136, 46);
  createGUI();
  up.fireAllEvents(true);
  down.fireAllEvents(true);
  select.fireAllEvents(true);
  open_button.fireAllEvents(true);
  load.fireAllEvents(true);
  save_button.fireAllEvents(true);
  aux.fireAllEvents(true);
  fs.fireAllEvents(true);
  volume.setValue(1023);
  
  patches = listFile(ROOT);
  drawPatches();
  patchLoadedIndex = -1;
}

void draw() {
  oled.draw(this);
  led.draw(this);
}

void execPd() {
  String cmd = "/home/pi/audio-sw/pd-mother-rpi/run-rpi.sh";
  //String cmd = "/home/pi/pd/organelle/orac-2.0/orac/run.sh";
  String param = "";
  if (!DEV) {
    param = "-nogui ";
  }
  Process p = exec(cmd, param);
  try {
    p.waitFor();
  } catch (InterruptedException e) { }
}

void execPd(String patch) {
  //String cmd = "/home/pi/pd/organelle/orac-2.0/orac/run.sh";
  //String cmd = "/home/pi/pd/organelle/More_Patches/orac/run.sh";
  String cmd = "/home/pi/audio-sw/pd-mother-rpi/run-patch-rpi.sh";
  String param = patch;
  if (!DEV) {
    param = "-nogui " + param ;
  }
  Process p = exec(cmd, param);
  try {
    p.waitFor();
  } catch (InterruptedException e) { }
}

/* Incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  //meesages.add(theOscMessage);
  handleOscEvent(theOscMessage);
  redraw();
}

void handleEncoders(int i, final int value) {
  println("Encoder " + i + ": " + value);
  switch(i) {
    case 0:
      if (controlMode == CONTROL_MODE_KNOBS) {
        knob1.setValue(knob1.getValue() + value);
      } else {
        if (value > 0) {
          handleDown();
        } else if (value < 0) {
          handleUp();
        }
      }
      break;
    case 1:
      knob2.setValue(knob2.getValue() + value);
      break;
    case 2:
      knob3.setValue(knob3.getValue() + value);
      break;
    case 3:
      knob4.setValue(knob4.getValue() + value);
      break;
  }
  redraw();
}

void handleButtons(int i, final int value) {
  switch(i) {
    case 0:
      if (controlMode == CONTROL_MODE_MENU) {
        handleSelect(value);
      } else if (value == 0) {
        controlMode = CONTROL_MODE_MENU;
      }
      break;
    case 1:
    case 2:
      break;
    case 3:
      if (value == 1) {
        controlMode = CONTROL_MODE_KNOBS;
      }
      break;
    case 4:
      sendAux(value * 100);
      break;
    case 5:
      sendFs(value * 100);
      break;
  }
}

void handleUp() {
  if (patchList) {
    previousPatch();
  } else if (enablePatchSub) {
    sendEncoderTurn(0);
  } else {
    println("up");
    patchListMode();
  }
}

void handleDown() {
  if (patchList) {
    nextPatch();
  } else if (enablePatchSub) {
    sendEncoderTurn(1);
  } else {
    println("down");
    patchListMode();
  }
}

boolean selectPressed = false;

void handleSelect(int state) {
  if (patchList) {
    println("select patchList");
    if (selectPressed && state == 0) {
      println("select patchList CLICKED");
      selectPatch();
    }
  } else if (enablePatchSub) {
    println("select enablePatchSub");
    if (state == 1) {
      sendEncoderButton(1);
    } else if (state == 0) {
      sendEncoderButton(0);
    }
  } else {
    if (selectPressed && state == 0) {
      println("select");
      patchListMode();
    }
  }
  if (state == 1) {
    selectPressed = true;
  }
}
