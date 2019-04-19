import processing.io.GPIO;
import processing.io.I2C;
import java.lang.reflect.Method;

/**
 * Allows access to hardware control using GPIO.
 */
class GPIOControl extends GPIO {
  final RotaryEncoder[] ENCODERS = new RotaryEncoder[] {
    new RotaryEncoder(22, 23),
    new RotaryEncoder(4, 6),
    new RotaryEncoder(16, 26),
    new RotaryEncoder(5, 12)
  };
  final int[] BUTTONS = { 27, 106, 13, 107, 105, 104 };
  int[] buttonStatus = new int[BUTTONS.length];  
  MCP23008 mcp23008;
  PApplet parent;
  Method encoderListener;
  Method buttonListener;
  
  GPIOControl() {
    // Init MCP23008
    mcp23008 = new MCP23008(I2C.list()[0]);
    for (int i = 0; i < 8; i++) {
      mcp23008.pinMode(i, GPIO.INPUT);
      mcp23008.pullUp(i, GPIO.HIGH);
    }
    
    // Init status
    for (int i = 0; i < buttonStatus.length; i++) {
      buttonStatus[i] = HIGH;
    }
        
    // Init GPIO
    for (int i = 0; i < ENCODERS.length; i++) {
      attachInterrupt(ENCODERS[i].pinA, GPIO.CHANGE);
    }
    for (int i = 0; i < BUTTONS.length; i++) {
      initButton(BUTTONS[i]);
    }
    
    // Start MCP23008 pulling
    pullMCP23008();
  }
  
  void initButton(int pinSwitch) {
    if (pinSwitch < 100) {
      GPIO.pinMode(pinSwitch, GPIO.INPUT_PULLUP);
      attachInterrupt(pinSwitch, GPIO.CHANGE);
    }
  }
  
  void handleInterrupt(int pin) { 
    for (int i = 0; i < ENCODERS.length; i++) {
      if (ENCODERS[i].pinA == pin) {
        // Update encoder
        handleEncoder(i);
      } else if (BUTTONS[i] == pin) {
        // Update switch
        handleGPIOButton(i);
      }
    }
  }
  
  void handleEncoder(int i) {
    int value = ENCODERS[i].read();
    if (value != 0 && encoderListener != null) {
      try {
        encoderListener.invoke(parent, i, value);
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
  }
  
  void handleGPIOButton(int i) {
    int value = GPIO.digitalRead(BUTTONS[i]); 
    handleButton(i, value);
  }
  
  void handleButton(int i, int value) {
    if (buttonStatus[i] != value) {
      if (buttonListener != null) {
        try {
          buttonListener.invoke(parent, i, 1 - value);
        } catch (Exception e) {
          e.printStackTrace();
        }
      }
      buttonStatus[i] = value;
    }
  }

  void pullMCP23008() {
    Thread t = new Thread(new Runnable() {
      public void run() {
        try {
          while (!Thread.currentThread().isInterrupted()) {
            for (int i = 0; i < BUTTONS.length; i++) {
              if (BUTTONS[i] >= 100) {
                int value = mcp23008.digitalRead(BUTTONS[i] - 100);
                handleButton(i, value);
              }
            }
            Thread.sleep(10);
          }
        } catch (Exception e) {
          // terminate the thread on any unexpected exception that might occur
          System.err.println("Terminating MCP230008 pull after catching: " + e.getMessage());
        }
      }
    }, "PULL MPC23008");

    t.setPriority(Thread.MAX_PRIORITY);
    t.start();
  }
  
  void attachInterrupt(int pin, int mode) {
    if (irqThreads.containsKey(pin)) {
      throw new RuntimeException("You must call releaseInterrupt before attaching another interrupt on the same pin");
    }

    enableInterrupt(pin, mode);

    final int irqPin = pin;
    Thread t = new Thread(new Runnable() {
      public void run() {
        boolean gotInterrupt = false;
        try {
          do {
            try {
              if (waitForInterrupt(irqPin, 100)) {
                gotInterrupt = true;
              }
              if (gotInterrupt && serveInterrupts) {
                handleInterrupt(irqPin);
                gotInterrupt = false;
              }
              // if we received an interrupt while interrupts were disabled
              // we still deliver it the next time interrupts get enabled
              // not sure if everyone agrees with this logic though
            } catch (RuntimeException e) {
              // make sure we're not busy spinning on error
              Thread.sleep(100);
            }
          } while (!Thread.currentThread().isInterrupted());
        } catch (Exception e) {
          // terminate the thread on any unexpected exception that might occur
          System.err.println("Terminating interrupt handling for pin " + irqPin + " after catching: " + e.getMessage());
        }
      }
    }, "GPIO" + pin + " IRQ");

    t.setPriority(Thread.MAX_PRIORITY);
    t.start();

    irqThreads.put(pin, t);
  }
  
  void attachEncoderListener(PApplet parent, String method) {
    try {
      encoderListener = parent.getClass().getMethod(method, int.class, int.class);
      this.parent = parent;
    } catch (NoSuchMethodException e) {
      throw new RuntimeException("Method " + method + " does not exist");
    }
  }
  
  void attachButtonListener(PApplet parent, String method) {
    try {
      buttonListener = parent.getClass().getMethod(method, int.class, int.class);
      this.parent = parent;
    } catch (NoSuchMethodException e) {
      throw new RuntimeException("Method " + method + " does not exist");
    }
  }
}
