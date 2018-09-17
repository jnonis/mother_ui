import oscP5.*;
import netP5.*;
import g4p_controls.*;
import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;

static final String ROOT = "/Users/jnonis/dev/pure_data/Organelle_Patches";
static final int SCALE = 480 / 128;

OscP5 oscP5;
NetAddress myRemoteLocation;
Queue<OscMessage> meesages;

/** Status. */
boolean patchList = true;
boolean showInfoBar = true;
boolean enablePatchSub = false;
boolean patchLoaded = false;

File[] patches;
int patchIndex = 0;
int patchSelected = 0;
int patchLoadedIndex = -1;

void setup() {
  size(480,320);
  frameRate(25);
  
  meesages = new ConcurrentLinkedQueue();
  /* start oscP5, listening for incoming messages at port 4001 */
  oscP5 = new OscP5(this,4001);
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  myRemoteLocation = new NetAddress("127.0.0.1",4000);
  
  background(0);
  
  createGUI();
  aux.fireAllEvents(true);
  
  patches = listFile(ROOT);
  drawPatches();
}

void draw() {
  while (!meesages.isEmpty()) {
    OscMessage theOscMessage = meesages.poll();
    if (theOscMessage != null) {
      handleOscEvent(theOscMessage);
    }
  }
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
  if(theOscMessage.checkAddrPattern("/oled/vumeter")==true) {
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
  } else {
    /* print the address pattern and the typetag of the received OscMessage */
    print("### received an osc message.");
    print(" addrpattern: "+theOscMessage.addrPattern());
    println(" typetag: "+theOscMessage.typetag());
  }
}

void patchListMode() {
  patchList = true;
  drawPatches();
}

void drawPatches() {
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
