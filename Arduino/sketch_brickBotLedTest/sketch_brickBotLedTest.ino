
static bool remoteOn = 0;
static bool autopilotOn = 0;
static int dir = 0;
static int steer = 0;
static uint8_t controlFlag = 0;
static int blinkCount = 0;

void setup() {
  
  // setup serial
  Serial.begin(57600);
  Serial.setTimeout(5);
  Bean.enableWakeOnConnect( true );

  // Start with led off
  Bean.setLed(0,0,0);
}

void loop() {

  bool isConnected = Bean.getConnectionState();
  if (isConnected) {

    checkRemote();

    if (remoteOn) {
      // RGB Led doesn't actually light very well so ignore the Forward/Backward and just use Left/Right
      if (steer < 0) {
        Bean.setLed(255, 0, 0);
      }
      else if (steer > 0) {
        Bean.setLed(0, 255, 0);
      }
      else {
        Bean.setLed(0, 0, 255);
      }
    }
    else if (autopilotOn) {
      // If autopilot, then blink the LED
      if (blinkCount < 10) {
        Bean.setLed(0, 255, 0);
      }
      else {
        Bean.setLed(0, 0, 0);
      }
      blinkCount++;
      if (blinkCount > 20) {
        blinkCount = 0;
      }
    }
    else {
      Bean.setLed(0, 0, 0);
    }
    
    // use a delay rather than a Bean.sleep so that the motors stay active
    delay(50);
  }
  else {

    // reset state
    remoteOn = false;
    dir = 0;
    steer = 0;

    // Turn off LED
    Bean.setLed(0, 0, 0);
    
    // Sleep unless woken
    Bean.sleep(0xFFFFFFFF);
  }
}

/**
 * Controlling via the iPhone app
 */

typedef struct {
  uint8_t steer: 2;     // 2-bit = left, center, right
  uint8_t dir: 2;       // 2-bit = back, center, forward
  bool remoteOn: 1;
  uint8_t padding: 3;
} BB_ControlStruct;

const uint8_t BBControlFlagRemote = 0xF0;
const uint8_t BBControlFlagAutopilot = 0xF1;

void checkRemote() {
  
  //Create a buffer to recieve from LightBlue, along with length
  char rec_buffer[64];
  size_t rec_length = 64;

  //Set the length to number of bytes recieved
  rec_length = Serial.readBytes(rec_buffer, rec_length);
  if (rec_length > 0) {
    for (int ii = 0; ii < rec_length - 1; ii += 2 ) {
        controlFlag = rec_buffer[ii];
        if (controlFlag == BBControlFlagRemote) {
            BB_ControlStruct control;
            remoteOn = (rec_buffer[ii + 1] != 0);
            if (remoteOn) {
              memcpy(&control, &rec_buffer[ii + 1], sizeof(control));
              steer = (int)control.steer - 1;
              dir = (int)control.dir - 1;
            }
            else {
              steer = 0;
              dir = 0;
            }
        }
        else if (controlFlag == BBControlFlagAutopilot) {
            autopilotOn = (rec_buffer[ii + 1] != 0);
        }
    }
  }
}

