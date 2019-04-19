import processing.io.GPIO;
import processing.io.I2C;

/**
 * MCP23008 implementation ported from:
 * https://github.com/adafruit/Adafruit-MCP23008-library
 */
class MCP23008 extends I2C {
  // Address
  static final int MCP23008_ADDRESS = 0x20;
  // Registers
  static final int MCP23008_IODIR = 0x00;
  static final int MCP23008_IPOL = 0x01;
  static final int MCP23008_GPINTEN = 0x02;
  static final int MCP23008_DEFVAL = 0x03;
  static final int MCP23008_INTCON = 0x04;
  static final int MCP23008_IOCON = 0x05;
  static final int MCP23008_GPPU = 0x06;
  static final int MCP23008_INTF = 0x07;
  static final int MCP23008_INTCAP = 0x08;
  static final int MCP23008_GPIO = 0x09;
  static final int MCP23008_OLAT = 0x0A;
  
  int i2caddr;
  
  MCP23008(String dev) {
    this(dev, 0);
  }
  
  MCP23008(String dev, int addr) {
    super(dev);

    if (addr > 7) {
      addr = 7;
    }
    i2caddr = addr;
  
    // set defaults!
    beginTransmission(MCP23008_ADDRESS | i2caddr);
    write((byte)MCP23008_IODIR);
    write((byte)0xFF);  // all inputs
    write((byte)0x00);
    write((byte)0x00);
    write((byte)0x00);
    write((byte)0x00);
    write((byte)0x00);
    write((byte)0x00);
    write((byte)0x00);
    write((byte)0x00);
    write((byte)0x00);  
    endTransmission();
  }
  
  void pinMode(int p, int d) {
    int iodir;
    
    // only 8 bits!
    if (p > 7)
      return;
    
    iodir = read8(MCP23008_IODIR);
  
    // set the pin and direction
    if (d == GPIO.INPUT) {
      iodir |= 1 << p; 
    } else {
      iodir &= ~(1 << p);
    }
    
    // write the new IODIR
    write8(MCP23008_IODIR, iodir);
  }
  
  int readGPIO() {
    // read the current GPIO input 
    return read8(MCP23008_GPIO);
  }
  
  void writeGPIO(int gpio) {
    write8(MCP23008_GPIO, gpio);
  }
  
  void digitalWrite(int p, int d) {
    int gpio;
    
    // only 8 bits!
    if (p > 7)
      return;
  
    // read the current GPIO output latches
    gpio = readGPIO();
  
    // set the pin and direction
    if (d == GPIO.HIGH) {
      gpio |= 1 << p; 
    } else {
      gpio &= ~(1 << p);
    }
  
    // write the new GPIO
    writeGPIO(gpio);
  }
  
  void pullUp(int p, int d) {
    int gppu;
    
    // only 8 bits!
    if (p > 7)
      return;
  
    gppu = read8(MCP23008_GPPU);
    // set the pin and direction
    if (d == GPIO.HIGH) {
      gppu |= 1 << p; 
    } else {
      gppu &= ~(1 << p);
    }
    // write the new GPIO
    write8(MCP23008_GPPU, gppu);
  }
  
  int digitalRead(int p) {
    // only 8 bits!
    if (p > 7)
      return 0;
  
    // read the current GPIO
    return (readGPIO() >> p) & 0x1;
  }
  
  int read8(int addr) {
    beginTransmission(MCP23008_ADDRESS | i2caddr);
    write((byte)addr);  
    endTransmission();
    beginTransmission(MCP23008_ADDRESS | i2caddr);
    byte[] data = read(1);
    endTransmission();
    return data[0];
  }
  
  void write8(int addr, int data) {
    beginTransmission(MCP23008_ADDRESS | i2caddr);
    write((byte)addr);
    write((byte)data);
    endTransmission();
  }
}
