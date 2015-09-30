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
const uint8_t BBControlFlagMotorCalibration = 0xF2;
const uint8_t BBControlFlagResetCalibration = 0xF3;

// This flag will only be false when first connected
static bool connectedOn = false;

bool getConnectionState() {

  bool isConnected = Bean.getConnectionState();
  if (isConnected) {
    if (!connectedOn) {
      // If this is the first connect, turn off the autopilot by default
      // The connected devise can turn it back on manually.
      autopilotOn = false;
    }
    checkRemote();
  }
  else {
    remoteOn = false;
  }
  connectedOn = isConnected;
  
  return isConnected;
}

void checkRemote() {
  
  //Create a buffer to recieve from LightBlue, along with length
  char rec_buffer[64];
  size_t rec_length = 64;

  //Set the length to number of bytes recieved
  rec_length = Serial.readBytes(rec_buffer, rec_length);
  if (rec_length > 0) {
      uint8_t controlFlag = rec_buffer[0];
      if (controlFlag == BBControlFlagRemote) {
          BB_ControlStruct control;
          remoteOn = (rec_buffer[1] != 0);
          if (remoteOn) {
            memcpy(&control, &rec_buffer[1], sizeof(control));
            steer = (int)control.steer - 1;
            dir = (int)control.dir - 1;
          }
          else {
            steer = 0;
            dir = 0;
          }
      }
      else if (controlFlag == BBControlFlagAutopilot) {
        autopilotOn = (rec_buffer[1] != 0);
      }
      else if (controlFlag == BBControlFlagResetCalibration) {
        // Read the motor calibration from the scratch banks
        readMotorCalibration();
      }
      else if (controlFlag == BBControlFlagMotorCalibration) {
        for (int ii=1; ii < rec_length && ii < SPEED_COUNT; ii++) {
          updateMotorCalibration(ii - 1, rec_buffer[ii]);
        }
      }
  }
}
