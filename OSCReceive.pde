
boolean disableKnob1Callback = false;
boolean disableKnob2Callback = false;
boolean disableKnob3Callback = false;
boolean disableKnob4Callback = false;
boolean disableVolumeCallback = false;
boolean disableExprCallback = false;

void handleOscEvent(OscMessage theOscMessage) {
  if(!patchList && theOscMessage.checkAddrPattern("/oled/vumeter")) {
    oled.drawVumeter(theOscMessage);
  } else if(!patchList && theOscMessage.addrPattern().startsWith("/oled/line/")) {
    oled.drawLine(theOscMessage);
  } else if(!patchList && theOscMessage.checkAddrPattern("/oled/invertline")) {
    oled.drawInvertLine(theOscMessage);
  } else if(theOscMessage.checkAddrPattern("/led")) {
    led.drawLed(theOscMessage);
  } else if(!patchList && theOscMessage.checkAddrPattern("/oled/gClear")) {
    oled.drawGClear();
  } else if(!patchList && theOscMessage.checkAddrPattern("/oled/gSetPixel")) {
    oled.drawGSetPixel(theOscMessage);
  } else if(!patchList && theOscMessage.checkAddrPattern("/oled/gLine")) {
    oled.drawGLine(theOscMessage);
  } else if(!patchList && theOscMessage.checkAddrPattern("/oled/gInvertArea")) {
    oled.drawGInvertArea(theOscMessage);
  } else if(!patchList && theOscMessage.checkAddrPattern("/oled/gFlip")) {
    // TODO
  } else if(!patchList && theOscMessage.checkAddrPattern("/oled/gPrintln")) {
    oled.drawGPrintln(theOscMessage);
  } else if(!patchList && theOscMessage.checkAddrPattern("/oled/gWaveform")) {
    oled.drawGWaveform(theOscMessage);
  } else if(theOscMessage.checkAddrPattern("/oled/gShowInfoBar")) {
    oled.drawGShowInfoBar(theOscMessage);
  } else if(!patchList && theOscMessage.checkAddrPattern("/oled/gFillArea")) {
    oled.drawGFillArea(theOscMessage);
  } else if(!patchList && theOscMessage.checkAddrPattern("/oled/gBox")) {
    oled.drawGBox(theOscMessage);
  } else if(!patchList && theOscMessage.checkAddrPattern("/oled/gCircle")) {
    oled.drawGCircle(theOscMessage);
  } else if(!patchList && theOscMessage.checkAddrPattern("/oled/gFilledCircle")) {
    oled.drawGFilledCircle(theOscMessage);
  } else if(!patchList && theOscMessage.checkAddrPattern("/patchLoaded")) {
    // TODO
    if (theOscMessage.get(0).intValue() == 1) { //<>//
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
    /*print("### received an osc message.");
    print(" addrpattern: "+theOscMessage.addrPattern());
    println(" typetag: "+theOscMessage.typetag());
    */
  }
}

void drawKnobs(OscMessage theOscMessage) {
  disableKnob1Callback = true;
  disableKnob2Callback = true;
  disableKnob3Callback = true;
  disableKnob4Callback = true;
  disableVolumeCallback = true;
  disableExprCallback = true;
  knob1.setValue(getFloatFromOscArg(theOscMessage, 0));
  knob2.setValue(getFloatFromOscArg(theOscMessage, 1));
  knob3.setValue(getFloatFromOscArg(theOscMessage, 2));
  knob4.setValue(getFloatFromOscArg(theOscMessage, 3));
  volume.setValue(getFloatFromOscArg(theOscMessage, 4));
  expr.setValue(getFloatFromOscArg(theOscMessage, 5));
}

float getFloatFromOscArg(OscMessage theOscMessage, int index) {
  byte[] types = theOscMessage.getTypetagAsBytes();
  float value;
  // 105 = 'i'
  if (105 == types[index]) {
    value = theOscMessage.get(index).intValue();
  } else {
    value = theOscMessage.get(index).floatValue();
  }
  return value;
}
