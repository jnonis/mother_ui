static final int WIDTH = 240; //384;
static final int HEIGHT = 128; //384;

int getScladeValue(int value) {
  return round(value * SCALE);
}

void drawLine(OscMessage theOscMessage) {
  int index = Integer.parseInt(theOscMessage.addrPattern().substring(11, 12));
  Object[] args = theOscMessage.arguments();
  StringBuilder text = new StringBuilder();
  for (int i = 0; i < args.length; i++) {
    if (i > 0) {
      text.append(" ");
    }
    text.append(args[i].toString());
  }
  if (!lineMode) {
    fill(0);
    noStroke();
    rect(0, 0, WIDTH, HEIGHT);
    println("Changing to line mode");
    lineMode = true;
    showInfoBar = true;
    
  }
  drawLine(index, text.toString());
}

void drawLine(int index, String text) {
  fill(0,0,0);
  //rect(0, getScladeValue((index * 10) + 3), WIDTH, getScladeValue(9));
  if (index == 1) {
    rect(0, getScladeValue(8), WIDTH, getScladeValue(5));
  } else if (index == 5) {
    rect(0, getScladeValue(60), WIDTH, getScladeValue(3));
  }
  rect(0, getScladeValue((index * 10) + 2), WIDTH, getScladeValue(10));
  fill(255,255,255);
  textSize(getScladeValue(8));
  text(text, getScladeValue(5), getScladeValue((index + 1) * 10));
}

void drawInvertLine(OscMessage theOscMessage) {
  int index = theOscMessage.get(0).intValue() + 1;
  drawInvertLine(index);
}

void drawInvertLine(int index) {
  int x1 = 0;
  int y1 = getScladeValue((index * 10) + 3);
  int x2 = WIDTH;
  int y2 = getScladeValue(9);
  loadPixels();
  for (int i = x1; i < x1 + x2; i++) {
    for (int j = y1; j < y1 + y2; j++) {
      int pixel = get(i, j);
      int pixelColor;
      if (pixel == color(0)) {
        pixelColor = color(255);
      } else {
        pixelColor = color(0);
      }
      pixels[j*width+i] = pixelColor;
    }
  }
  updatePixels();
}

void drawLed(OscMessage theOscMessage) {
  int value = theOscMessage.get(0).intValue();
  switch(value) {
    case 1:
      // Green
      fill(0,255,0);
      break;
    case 2:
      // Blue
      fill(0,0,255);
      break;
    case 3:
      // Aqua
      fill(0,255,255);
      break;
    case 4:
      // Red
      fill(255,0,0);
      break;
    case 5:
      // Yellow
      fill(255,255,0);
      break;           
    case 6:
      // Magenta
      fill(255,0,255);
      break;
    case 7:
      // White
      fill(255,255,255);
      break;
    default:
      // Black
      fill(0,0,0);
      break;
  }  
  rect(192, 136, 48, 48);
}

void drawVumeter(OscMessage theOscMessage) {
  if (!showInfoBar) {
    return;
  }

  int inL = theOscMessage.get(0).intValue();
  if (inL < 0) inL = 0;
  int inR = theOscMessage.get(1).intValue();
  if (inR < 0) inR = 0;
  int outL = theOscMessage.get(2).intValue();
  if (outL < 0) outL = 0;
  int outR = theOscMessage.get(3).intValue();
  if (outR < 0) outR = 0;

  fill(0,0,0);
  rect(0, 0, WIDTH, getScladeValue(8));
  fill(255,255,255);
 
  textSize(getScladeValue(6));
  text("I", getScladeValue(5), getScladeValue(7));
  int offset = 64;
  text("O", getScladeValue(offset), getScladeValue(7));
  
  for (int i = 0; i < 11; i++) {
    if (inL > i) {
      rect(getScladeValue(10 + (3 * i)), getScladeValue(2), getScladeValue(2), getScladeValue(2));
    } else {
      rect(getScladeValue(10 + (3 * i)), getScladeValue(3), getScladeValue(1), getScladeValue(1));
    }
    if (inR > i) {
      rect(getScladeValue(10 + (3 * i)), getScladeValue(6), getScladeValue(2), getScladeValue(2));
    } else {
      rect(getScladeValue(10 + (3 * i)), getScladeValue(7), getScladeValue(1), getScladeValue(1));
    }
    if (outL > i) {
      rect(getScladeValue(offset + 10 + (3 * i)), getScladeValue(2), getScladeValue(2), getScladeValue(2));
    } else {
      rect(getScladeValue(offset + 10 + (3 * i)), getScladeValue(3), getScladeValue(1), getScladeValue(1));
    }
    if (outR > i) {
      rect(getScladeValue(offset + 10 + (3 * i)), getScladeValue(6), getScladeValue(2), getScladeValue(2));
    } else {
      rect(getScladeValue(offset + 10 + (3 * i)), getScladeValue(7), getScladeValue(1), getScladeValue(1));
    }
  }
}

void drawGShowInfoBar(OscMessage theOscMessage) {
  if (theOscMessage.get(1).intValue() == 1) {
    showInfoBar = true;
  } else {
    showInfoBar = false;
  }
}

void drawGClear() {
  println("drawGClear");
  if (lineMode) {
    lineMode = false;
  }
  fill(0);
  noStroke();
  rect(0, 0, 384, 192);
}

void drawGSetPixel(OscMessage theOscMessage) {
  int x = theOscMessage.get(1).intValue();
  int y = theOscMessage.get(2).intValue();
  if(theOscMessage.get(3).intValue() == 1) {
    fill(255,255,255);
  } else {
    fill(0,0,0);
  }
  int scaledx = getScladeValue(x);
  int scaledy = getScladeValue(y);
  rect(scaledx, scaledy, SCALE, SCALE);
}

void drawGLine(OscMessage theOscMessage) {
  int x1 = theOscMessage.get(1).intValue();
  x1 = getScladeValue(x1);
  int y1 = theOscMessage.get(2).intValue();
  if (y1 < 0) {
    y1 = 64 + y1;
  }
  y1 = getScladeValue(y1);
  
  int x2 = theOscMessage.get(3).intValue();
  x2 = getScladeValue(x2);
  int y2 = theOscMessage.get(4).intValue();
  if (y2 < 0) {
      y2 = 64 + y2;
  }
  y2 = getScladeValue(y2);
  
  if (theOscMessage.get(5).intValue() == 1) {
    stroke(255,255,255);
  } else {
    stroke(0,0,0);
  }
  line(x1, y1, x2, y2);
  stroke(0);
}

void drawGInvertArea(OscMessage theOscMessage) {
  int x1 = theOscMessage.get(1).intValue();
  if (x1 < 0) return;
  x1 = getScladeValue(x1);
  int y1 = theOscMessage.get(2).intValue();
  if (y1 < 0) return;
  y1 = getScladeValue(y1);
  int x2 = getScladeValue(theOscMessage.get(3).intValue());
  int y2 = getScladeValue(theOscMessage.get(4).intValue());
  loadPixels();
  for (int i = x1; i < x1 + x2; i++) {
    for (int j = y1; j < y1 + y2; j++) {
      int pixel = get(i, j);
      int pixelColor;
      if (pixel == color(0)) {
        pixelColor = color(255);
      } else {
        pixelColor = color(0);
      }
      pixels[j*width+i] = pixelColor;
    }
  }
  updatePixels();
}

void drawGPrintln(OscMessage theOscMessage) {
  int x = getScladeValue(theOscMessage.get(1).intValue() + 5);
  int y = getScladeValue(theOscMessage.get(2).intValue() + 5);
  int size = getScladeValue(theOscMessage.get(3).intValue());
  textSize(size);
  if (theOscMessage.get(4).intValue() == 1) {
    fill(255);
  } else {
    fill(0);
  }
  Object[] args = theOscMessage.arguments();
  StringBuilder text = new StringBuilder();
  for (int i = 5; i < args.length; i++) {
      if (i > 5) {
      text.append(" ");
    }
    text.append(args[i].toString());
  }
  text(text.toString(), x, y);
  stroke(0);
}

void drawGWaveform(OscMessage theOscMessage) {
  byte[] blob = theOscMessage.get(1).blobValue();
  int bloblen = blob.length;
  if (bloblen > 128) {
      bloblen = 128;
  }
  stroke(255);
  strokeWeight(SCALE);
  for (int i = 1; i < bloblen; i++) {
    int x1 = getScladeValue(i - 1);
    int y1 = getScladeValue(blob[i - 1] & 0x3f);
    int x2 = getScladeValue(i);
    int y2 = getScladeValue(blob[i] & 0x3f);
    line(x1, y1, x2, y2);
  }
  stroke(0);
  strokeWeight(1);
}

void drawGFillArea(OscMessage theOscMessage) {
  int x1 = getScladeValue(theOscMessage.get(1).intValue());
  int y1 = theOscMessage.get(2).intValue();
  if (y1 < 0) {
      y1 = 64 + y1;
  }
  y1 = getScladeValue(y1);
  int x2 = getScladeValue(theOscMessage.get(3).intValue());
  int y2 = theOscMessage.get(4).intValue();
  if (y2 < 0) {
      y2 = 64 + y2;
  }
  y2 = getScladeValue(y2);
  if (theOscMessage.get(5).intValue() == 1) {
    fill(255);
  } else {
    fill(0);
  }
  rect(x1, y1, x2 - x1, y2 - y1);
}

void drawGBox(OscMessage theOscMessage) {
  int x1 = theOscMessage.get(1).intValue();
  if (x1 < 0) {
      x1 = 0;
  }
  x1 = getScladeValue(x1);
  int y1 = theOscMessage.get(2).intValue();
  if (y1 < 0) {
      y1 = 64 + y1;
  }
  y1 = getScladeValue(y1);
  int x2 = theOscMessage.get(3).intValue();
  if (x2 < 0) {
      x2 = 0;
  }
  x2 = getScladeValue(x2);
  int y2 = theOscMessage.get(4).intValue();
  if (y2 < 0) {
      y2 = 64 + y2;
  }
  y2 = getScladeValue(y2);
  if (theOscMessage.get(5).intValue() == 1) {
    stroke(255);
  } else {
    stroke(0);
  }
  fill(0,0);
  rect(x1, y1, x2, y2);
  stroke(0);
  fill(0,255);
}

void drawKnobs(OscMessage theOscMessage) {
  disableKnob1Callback = true;
  disableKnob2Callback = true;
  disableKnob3Callback = true;
  disableKnob4Callback = true;
  disableVolumeCallback = true;
  knob1.setValue(getFloatFromOscArg(theOscMessage, 0));
  knob2.setValue(getFloatFromOscArg(theOscMessage, 1));
  knob3.setValue(getFloatFromOscArg(theOscMessage, 2));
  knob4.setValue(getFloatFromOscArg(theOscMessage, 3));
  volume.setValue(getFloatFromOscArg(theOscMessage, 4));
  println("volume: " + getFloatFromOscArg(theOscMessage, 4));
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
