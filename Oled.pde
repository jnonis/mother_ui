
/**
 * GUI - Oled display.
 */
public class Oled {
  private static final int SCALE = 2;
  private static final int WIDTH = 128 * SCALE; // 256
  private static final int HEIGHT = 64 * SCALE; // 128
  
  public static final int MAIN = 0;
  public static final int PATCH = 1;
  
  private PGraphics[] pages = new PGraphics[2];
  private PGraphics canvas;
  
  public Oled() {
    for (int i = 0; i < pages.length; i++) {
      pages[i] = createGraphics(WIDTH, HEIGHT);
      pages[i].noSmooth();
    }
    canvas = pages[MAIN];
  }
  
  public void setPage(int page) {
    canvas = pages[page];
  }
  
  public void draw(PApplet parent) {
    parent.pushMatrix();
    parent.translate(0, 0);
    parent.image(canvas, 0, 0, WIDTH, HEIGHT);
    parent.popMatrix();
  }
  
  private int scaleValue(int value) {
    return round(value * SCALE);
  }
  
  void clearOled() {
    canvas.beginDraw();
    canvas.fill(0);
    canvas.noStroke();
    canvas.rect(0, 0, WIDTH, HEIGHT);
    canvas.endDraw();
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
      //clearOled();
      println("Changing to line mode");
      lineMode = true;
      showInfoBar = true;
      
    }
    drawLine(index, text.toString());
  }
  
  void drawLine(int index, String text) {
    canvas.beginDraw();
    canvas.fill(0,0,0);
    canvas.noStroke();
    canvas.rect(0, scaleValue((index * 10) + 2), WIDTH, scaleValue(10));
    canvas.fill(255,255,255);
    canvas.textSize(scaleValue(8));
    canvas.textAlign(LEFT, CENTER);
    int y = scaleValue((index * 10) + 2 + 4);
    canvas.text(text, scaleValue(2), y);
    canvas.endDraw();
  }
  
  void drawInvertLine(OscMessage theOscMessage) {
    int index = theOscMessage.get(0).intValue() + 1;
    drawInvertLine(index);
  }
  
  void drawInvertLine(int index) {
    canvas.beginDraw();
    int x1 = 0;
    int y1 = scaleValue((index * 10) + 2);
    int x2 = WIDTH;
    int y2 = scaleValue(10);
    canvas.loadPixels();
    for (int i = x1; i < x1 + x2; i++) {
      for (int j = y1; j < y1 + y2; j++) {
        int pixel = canvas.get(i, j);
        int pixelColor;
        if (pixel == color(0)) {
          pixelColor = color(255);
        } else {
          pixelColor = color(0);
        }
        canvas.pixels[j*WIDTH+i] = pixelColor;
      }
    }
    canvas.updatePixels();
    canvas.endDraw();
  }
  
  void drawVumeter(OscMessage theOscMessage) {
    if (!showInfoBar) {
      return;
    }
    canvas.beginDraw();
  
    int inL = theOscMessage.get(0).intValue();
    if (inL < 0) inL = 0;
    int inR = theOscMessage.get(1).intValue();
    if (inR < 0) inR = 0;
    int outL = theOscMessage.get(2).intValue();
    if (outL < 0) outL = 0;
    int outR = theOscMessage.get(3).intValue();
    if (outR < 0) outR = 0;
  
    canvas.noStroke();
    canvas.fill(0,0,0);
    canvas.rect(0, 0, WIDTH, scaleValue(12));
    
    canvas.fill(255,255,255);
    canvas.textSize(scaleValue(7));
    canvas.textAlign(LEFT, CENTER);
    canvas.text("I", scaleValue(5), scaleValue(4));
    int offset = 64 + 5;
    canvas.text("O", scaleValue(offset), scaleValue(4));
    
    for (int i = 0; i < 11; i++) {
      if (inL > i) {
        canvas.rect(scaleValue(10 + (3 * i)), scaleValue(2), scaleValue(2), scaleValue(2));
      } else {
        canvas.rect(scaleValue(10 + (3 * i)), scaleValue(3), scaleValue(1), scaleValue(1));
      }
      if (inR > i) {
        canvas.rect(scaleValue(10 + (3 * i)), scaleValue(6), scaleValue(2), scaleValue(2));
      } else {
        canvas.rect(scaleValue(10 + (3 * i)), scaleValue(7), scaleValue(1), scaleValue(1));
      }
      if (outL > i) {
        canvas.rect(scaleValue(offset + 10 + (3 * i)), scaleValue(2), scaleValue(2), scaleValue(2));
      } else {
        canvas.rect(scaleValue(offset + 10 + (3 * i)), scaleValue(3), scaleValue(1), scaleValue(1));
      }
      if (outR > i) {
        canvas.rect(scaleValue(offset + 10 + (3 * i)), scaleValue(6), scaleValue(2), scaleValue(2));
      } else {
        canvas.rect(scaleValue(offset + 10 + (3 * i)), scaleValue(7), scaleValue(1), scaleValue(1));
      }
    }
    canvas.endDraw();
  }
  
  void drawGShowInfoBar(OscMessage theOscMessage) {
    if (theOscMessage.get(1).intValue() == 1) {
      showInfoBar = true;
    } else {
      showInfoBar = false;
    }
  }
  
  void drawGClear() {
    if (lineMode) {
      lineMode = false;
    }
    this.clearOled();
  }
  
  void drawGSetPixel(OscMessage theOscMessage) {
    canvas.beginDraw();
    int x = theOscMessage.get(1).intValue();
    int y = theOscMessage.get(2).intValue();
    if(theOscMessage.get(3).intValue() == 1) {
      canvas.fill(255,255,255);
    } else {
      canvas.fill(0,0,0);
    }
    int scaledx = scaleValue(x);
    int scaledy = scaleValue(y);
    canvas.noStroke();
    canvas.rect(scaledx, scaledy, SCALE, SCALE);
    canvas.endDraw();
  }
  
  void drawGLine(OscMessage theOscMessage) {
    canvas.beginDraw();
    int x1 = theOscMessage.get(1).intValue();
    x1 = scaleValue(x1);
    int y1 = theOscMessage.get(2).intValue();
    if (y1 < 0) {
      y1 = 63 + y1;
    }
    y1 = scaleValue(y1);
    
    int x2 = theOscMessage.get(3).intValue();
    x2 = scaleValue(x2);
    int y2 = theOscMessage.get(4).intValue();
    if (y2 < 0) {
        y2 = 63 + y2;
    }
    y2 = scaleValue(y2);
    
    if (theOscMessage.get(5).intValue() == 1) {
      canvas.stroke(255,255,255);
    } else {
      canvas.stroke(0,0,0);
    }
    canvas.strokeWeight(SCALE);
    canvas.line(x1, y1, x2, y2);
    canvas.strokeWeight(1);
    canvas.endDraw();
  }
  
  void drawGInvertArea(OscMessage theOscMessage) {
    canvas.beginDraw();
    int x1 = theOscMessage.get(1).intValue();
    if (x1 < 0) return;
    x1 = scaleValue(x1);
    int y1 = theOscMessage.get(2).intValue();
    if (y1 < 0) return;
    y1 = scaleValue(y1);
    int x2 = scaleValue(theOscMessage.get(3).intValue());
    int y2 = scaleValue(theOscMessage.get(4).intValue());
    canvas.loadPixels();
    for (int i = x1; i < x1 + x2; i++) {
      for (int j = y1; j < y1 + y2; j++) {
        int pixel = canvas.get(i, j);
        int pixelColor;
        if (pixel == color(0)) {
          pixelColor = color(255);
        } else {
          pixelColor = color(0);
        }
        canvas.pixels[j*WIDTH+i] = pixelColor;
      }
    }
    canvas.updatePixels();
    canvas.endDraw();
  }
  
  void drawGPrintln(OscMessage theOscMessage) {
    canvas.beginDraw();
    int x = scaleValue(theOscMessage.get(1).intValue());
    int y = scaleValue(theOscMessage.get(2).intValue());
    int size = scaleValue(theOscMessage.get(3).intValue());
    canvas.noStroke();
    canvas.textSize(size);
    if (theOscMessage.get(4).intValue() == 1) {
      canvas.fill(255);
    } else {
      canvas.fill(0);
    }
    Object[] args = theOscMessage.arguments();
    StringBuilder text = new StringBuilder();
    for (int i = 5; i < args.length; i++) {
        if (i > 5) {
        text.append(" ");
      }
      text.append(args[i].toString());
    }
    if (!text.toString().contains("%")) {
      println("GPrintLn: " + x + " " + y + " " + size + " " + text);
    }
    canvas.textAlign(LEFT, TOP);
    canvas.text(text.toString(), x, y);
    canvas.endDraw();
  }
  
  void drawGWaveform(OscMessage theOscMessage) {
    canvas.beginDraw();
    byte[] blob = theOscMessage.get(1).blobValue();
    int bloblen = blob.length;
    if (bloblen > 128) {
        bloblen = 128;
    }
    canvas.stroke(255);
    canvas.strokeWeight(SCALE);
    for (int i = 1; i < bloblen; i++) {
      int x1 = scaleValue(i - 1);
      int y1 = scaleValue(blob[i - 1] & 0x3f);
      int x2 = scaleValue(i);
      int y2 = scaleValue(blob[i] & 0x3f);
      canvas.line(x1, y1, x2, y2);
    }
    canvas.stroke(0);
    //strokeWeight(1);
    canvas.endDraw();
  }
  
  void drawGFillArea(OscMessage theOscMessage) {
    canvas.beginDraw();
    int x1 = scaleValue(theOscMessage.get(1).intValue());
    int y1 = theOscMessage.get(2).intValue();
    if (y1 < 0) {
        y1 = 63 + y1;
    }
    y1 = scaleValue(y1);
    int x2 = theOscMessage.get(3).intValue();
    if (x2 > 127) {
      x2 = 127;
    }
    x2 = scaleValue(x2);
    int y2 = theOscMessage.get(4).intValue();
    if (y2 < 0) {
        y2 = 63 + y2;
    }
    y2 = scaleValue(y2);
    if (theOscMessage.get(5).intValue() == 1) {
      canvas.fill(255);
    } else {
      canvas.fill(0);
    }
    canvas.stroke(0);
    canvas.rect(x1, y1, x2, y2);
    canvas.endDraw();
  }
  
  void drawGBox(OscMessage theOscMessage) {
    canvas.beginDraw();
    int x1 = theOscMessage.get(1).intValue();
    if (x1 < 0) {
        x1 = 0;
    }
    x1 = scaleValue(x1);
    int y1 = theOscMessage.get(2).intValue();
    if (y1 < 0) {
        y1 = 64 + y1;
    }
    y1 = scaleValue(y1);
    int x2 = theOscMessage.get(3).intValue();
    if (x2 < 0) {
        x2 = 0;
    }
    x2 = scaleValue(x2);
    int y2 = theOscMessage.get(4).intValue();
    if (y2 < 0) {
        y2 = 64 + y2;
    }
    y2 = scaleValue(y2);
    if (theOscMessage.get(5).intValue() == 1) {
      canvas.stroke(255);
    } else {
      canvas.stroke(0);
    }
    canvas.fill(0,0);
    canvas.rect(x1, y1, x2, y2);
    canvas.stroke(0);
    canvas.fill(0,255);
    canvas.endDraw();
  }
  
  void drawGCircle(OscMessage theOscMessage) {
    canvas.beginDraw();
    int x = scaleValue(theOscMessage.get(1).intValue());
    int y = scaleValue(theOscMessage.get(2).intValue());
    int r = scaleValue(theOscMessage.get(3).intValue());
    if (theOscMessage.get(4).intValue() == 1) {
      canvas.stroke(255);
    } else {
      canvas.stroke(0);
    }
    canvas.strokeWeight(SCALE);
    canvas.noFill();
    canvas.ellipse(x, y, 2 * r, 2 * r);
    canvas.strokeWeight(1);
    canvas.endDraw();
  }
  
  void drawGFilledCircle(OscMessage theOscMessage) {
    canvas.beginDraw();
    int x = scaleValue(theOscMessage.get(1).intValue());
    int y = scaleValue(theOscMessage.get(2).intValue());
    int r = scaleValue(theOscMessage.get(3).intValue());
    if (theOscMessage.get(4).intValue() == 1) {
      canvas.fill(255);
    } else {
      canvas.fill(0);
    }
    canvas.noStroke();
    canvas.ellipse(x, y, 2 * r, 2 * r);
    canvas.endDraw();
  }
}
