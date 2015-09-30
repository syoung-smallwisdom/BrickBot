#define DIR_FORWARD 1
#define DIR_BACKWARD -1
#define STEER_RIGHT 1
#define STEER_LEFT -1

#define RobotNameScratchBank 1
#define MotorCalibrationScratchBank 2

static bool remoteOn = false;
static bool autopilotOn = true;
static int dir = 0;
static int steer = 0;
static int autopilotTimeout = 0;
const int delayMilliseconds = 50;

void setup() {
  
  // Setup the serial connection
  Serial.begin(57600);
  Serial.setTimeout(5);
  
  // Setup the bean to wake up when connected to the remote
  Bean.enableWakeOnConnect(true);
  
  // setup the motors
  setupMotors();

  // Setup the Rangefinder
  setupRangeFinder();
}

void loop() {

  // Check if connected
  bool isConnected = getConnectionState();

  // If the autopilot is ON or the Bean is connected, check state
  if (autopilotOn || isConnected) {
    
    if (isConnected) {
      // Reset the autopilot timeout if connected 
      autopilotTimeout = 0;
    }
    else {
      autopilotTimeout++;
      if (autopilotTimeout * delayMilliseconds > 10*60*1000) {
        // If it's been running in autopilot for 10 minutes (and isn't connected), 
        // then stop and put it to sleep.
        autopilotOn = false;
      }
    }

    // Always update the autopilot state
    updateAutopilot();

    // update the motor state
    if (remoteOn || autopilotOn) {
      runMotors();
    }
    else {
      stopMotors();
    }

    // use a delay rather than a Bean.sleep so that the motors stay active
    delay(delayMilliseconds);
  }
  else {

    // reset state
    remoteOn = false;
    dir = 0;
    steer = 0;
    
    // Sleep unless woken
    Bean.sleep(0xFFFFFFFF);
  }
}




