import processing.io.GPIO;

/**
 * Harware rotary encoder handler.
 * - initialize GPIO
 * - read direction
 * - detect velocity
 */
public class RotaryEncoder {
  final int pinA;
  final int pinB;
  private int status = GPIO.HIGH;
  private int lastValue;
  private int lastValueTime;
  private int counter;
  
  public RotaryEncoder(int pinA, int pinB) {
    this.pinA = pinA;
    this.pinB = pinB;
    GPIO.pinMode(pinA, GPIO.INPUT_PULLUP);
    GPIO.pinMode(pinB, GPIO.INPUT_PULLUP);
  }
  
  public int read() {
    int n = GPIO.digitalRead(pinA);
    int value = 0;
    int velocity = 1;
    if ((status == GPIO.LOW) && (n == GPIO.HIGH)) {
      if (GPIO.digitalRead(pinB) == GPIO.LOW) {
        value--;
      } else {
        value++;
      }
      
      if(value == lastValue) {
        counter++;
        int now = millis();
        if(now - lastValueTime < 100) {
            velocity = max((counter / 6) * 5, 1);
        }
        lastValueTime = now;
      } else {
        counter = 0;
      }
      lastValue = value;
    }
    status = n;
    return value * velocity;
  }
}
