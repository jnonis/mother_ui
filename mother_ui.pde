import controlP5.*;
import oscP5.*;
import netP5.*;
import g4p_controls.*;
import java.util.Queue;
import java.util.Arrays;
import java.util.Comparator;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.lang.Process;

static final String ROOT = "/home/pi/pd/organelle/Organelle_Patches";
static final int SCALE = 2; //480 / 128;

OscP5 oscP5;
NetAddress myRemoteLocation;
Queue<OscMessage> meesages;

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

boolean disableKnob1Callback = false;
boolean disableKnob2Callback = false;
boolean disableKnob3Callback = false;
boolean disableKnob4Callback = false;
boolean disableVolumeCallback = false;
boolean disableExprCallback = false;

void setup() {
  //size(320,480);
  fullScreen();
  
  meesages = new ConcurrentLinkedQueue();
  /* start oscP5, listening for incoming messages at port 4001 */
  oscP5 = new OscP5(this,4001);
  myRemoteLocation = new NetAddress("127.0.0.1",4000);
  
  background(237, 237, 237);
  //fill(0, 130, 130);
  //noStroke();
  //rect(0, 212, 480, 320);
  //rect(384, 0, 480, 212);
  
  // Led
  fill(0);
  noStroke();
  rect(192, 136, 48, 48);
  
  //createNewGUI();
  createGUI();
  up.fireAllEvents(true);
  down.fireAllEvents(true);
  select.fireAllEvents(true);
  load.fireAllEvents(true);
  save_button.fireAllEvents(true);
  aux.fireAllEvents(true);
  fs.fireAllEvents(true);
  volume.setValue(1023);
  
  execPd();
  
  patches = listFile(ROOT);
  drawPatches();
}

void draw() {
  int count = 0;
  while (!meesages.isEmpty() && count < 15) {
    OscMessage theOscMessage = meesages.poll();
    if (theOscMessage != null) {
      handleOscEvent(theOscMessage);
      count++;
    }
  }
}

void execPd() {
  Process p = exec("/home/pi/audio-sw/pd-mother-rpi/run-rpi.sh");
  try {
    p.waitFor();
  } catch (InterruptedException e) { }
}

void killPd() {
  Process p = exec("killall pd");
  try {
    p.waitFor();
  } catch (InterruptedException e) { }
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  meesages.add(theOscMessage);
  redraw();
}

void handleOscEvent(OscMessage theOscMessage) {
  // /enablepatchsub
  // /patchLoaded
  // ---
  // /gohome
  if (!theOscMessage.checkAddrPattern("/oled/vumeter")) {
    //println(" addrpattern: "+theOscMessage.addrPattern());
  }
  
  if(theOscMessage.checkAddrPattern("/oled/vumeter")) {
    if (!patchList) {
      drawVumeter(theOscMessage);
    }
  } else if(theOscMessage.addrPattern().startsWith("/oled/line/")) {
    drawLine(theOscMessage);
  } else if(theOscMessage.checkAddrPattern("/oled/invertline")) {
    drawInvertLine(theOscMessage);
  } else if(theOscMessage.checkAddrPattern("/led")) {
    drawLed(theOscMessage);
  } else if(theOscMessage.checkAddrPattern("/oled/gClear")) {
    drawGClear();
  } else if(theOscMessage.checkAddrPattern("/oled/gSetPixel")) {
    drawGSetPixel(theOscMessage);
  } else if(theOscMessage.checkAddrPattern("/oled/gLine")) {
    drawGLine(theOscMessage);
  } else if(theOscMessage.checkAddrPattern("/oled/gInvertArea")) {
    drawGInvertArea(theOscMessage);
  } else if(theOscMessage.checkAddrPattern("/oled/gFlip")) {
    // TODO
  } else if(theOscMessage.checkAddrPattern("/oled/gPrintln")) {
    drawGPrintln(theOscMessage);
  } else if(theOscMessage.checkAddrPattern("/oled/gWaveform")) {
    drawGWaveform(theOscMessage);
  } else if(theOscMessage.checkAddrPattern("/oled/gShowInfoBar")) {
    drawGShowInfoBar(theOscMessage);
  } else if(theOscMessage.checkAddrPattern("/oled/gFillArea")) {
    drawGFillArea(theOscMessage);
  } else if(theOscMessage.checkAddrPattern("/oled/gBox")) {
    drawGBox(theOscMessage);
  } else if(theOscMessage.checkAddrPattern("/patchLoaded")) {
    // TODO
    if (theOscMessage.get(0).intValue() == 1) {
      patchLoaded = true;
    } else {
      patchLoaded = false;
    }
  } else if(theOscMessage.checkAddrPattern("/enablepatchsub")) {
    if (theOscMessage.get(0).intValue() == 1) {
      enablePatchSub = true;
    } else {
      enablePatchSub = false;
    }
  } else if(theOscMessage.checkAddrPattern("/gohome")) {
    patchListMode();
  } else if(theOscMessage.checkAddrPattern("/knobs")) {
    drawKnobs(theOscMessage);
  } else {
    /* print the address pattern and the typetag of the received OscMessage */
    //print("### received an osc message.");
    //print(" addrpattern: "+theOscMessage.addrPattern());
    //println(" typetag: "+theOscMessage.typetag());
  }
}

void patchListMode() {
  println("patchListMode");
  patchList = true;
  drawPatches();
}

void drawPatches() {
  fill(0);
  noStroke();
  rect(0, 0, 240, 128);
  if (patchLoadedIndex >= 0) {
    drawLine(0, "> " + patches[patchLoadedIndex].getName());
  }
  for (int i = 0; i < 5; i++) {
    drawLine(i + 1, patches[patchIndex + i].getName());
  }
  drawInvertLine(patchSelected - patchIndex + 1);
}

void previousPatch() {
  patchSelected--;
  if (patchSelected < 0) {
    patchSelected = 0;
  }
  if (patchSelected < patchIndex) {
    patchIndex--;
  }
  drawPatches();
}

void nextPatch() {
  patchSelected++;
  if (patchSelected >= patches.length) {
    patchSelected = patches.length - 1;
  }
  if (patchSelected > patchIndex + 4) {
    patchIndex++;
  }
  drawPatches();
}

void selectPatch() {
  patchList = false;
  if (patchSelected != patchLoadedIndex) {
    patchLoadedIndex = patchSelected;
    if (patches.length > 0) {
      File mainPd = getMainPd(patches[patchLoadedIndex]);
      if (mainPd != null) {
        showInfoBar = true;
        enablePatchSub = false;
        patchLoaded = false;
        sendLoadPatch(mainPd.getAbsolutePath());
      }
    }
  } else {
    for (int i = 0; i < 6; i++) {
      drawLine(i, "");
    }
  }
}
