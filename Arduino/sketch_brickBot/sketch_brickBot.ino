#include <Servo.h>

#define PIN_RIGHT 1
#define PIN_LEFT  0
#define PIN_TRIG  3
#define PIN_ECHO  2

#define MOTOR_STOP 90

const int full_speed[3][2] = {{20, -90}, {90, -34}, {90, -18}};  // left, straight, right
const int slow_speed[2] = {20, -12};  // straight

static bool remoteOn = false;
static bool autopilotOn = true;
static bool connectedOn = false;
static int dir = 0;
static int steer = 0;

Servo servoRight, servoLeft;

void setup() {
  
  // setup serial
  Serial.begin(57600);
  Serial.setTimeout(5);
  Bean.enableWakeOnConnect( true );
  
  // setup the motors
  servoRight.attach(PIN_RIGHT);
  servoRight.write(MOTOR_STOP);
  servoLeft.attach(PIN_LEFT);
  servoLeft.write(MOTOR_STOP);

  // Setup echolocation
  pinMode(PIN_TRIG, OUTPUT);
  pinMode(PIN_ECHO, INPUT);

  // Start with led off
  Bean.setLed(0,0,0);
}

void loop() {

  // Check if connected
  bool isConnected = Bean.getConnectionState();
  if (isConnected && !connectedOn) {
    // If this is the first connect, turn off the autopilot by default
    // The connected devise can turn it back on manually.
    autopilotOn = false;
  }
  connectedOn = isConnected;

  // If the autopilot is ON or the Bean is connected, check state
  if (autopilotOn || isConnected) {

    // Turn on LED to indicate awake
    Bean.setLed(0, 255, 0);

    // Check conditions
    if (isConnected) {
      checkRemote();
    }

    if (autopilotOn) {
      // If the autopilot is on then check the range
      checkRange();
    }
    else {
      // Otherwise, reset the autopilot state
      resetAutopilot();
    }
    
    // update the motor state
    if (remoteOn || autopilotOn) {
      runMotors();
    }
    else {
      stopMotors();
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
 * Functions for setting the motor speed.
 */

#define DIR_FORWARD 1
#define DIR_BACKWARD -1
#define STEER_RIGHT 1
#define STEER_LEFT -1

void stopMotors() {
  dir = 0;
  steer = 0;
  setMotorValue(PIN_RIGHT, MOTOR_STOP);
  setMotorValue(PIN_LEFT, MOTOR_STOP);
}

void runMotors() {
  if (dir == 0) {
    if (steer == 0) {
      setMotorValue(PIN_RIGHT, MOTOR_STOP);
      setMotorValue(PIN_LEFT, MOTOR_STOP);
    }
    else {
      setMotorValue(PIN_RIGHT, steer * -1 * slow_speed[PIN_RIGHT] + 90);
      setMotorValue(PIN_LEFT, steer * slow_speed[PIN_LEFT] + 90);
    }
  }
  else {
    for (int mm=0; mm <= 1; mm++) {
      int spd = dir * full_speed[steer + 1][mm] + 90;
      setMotorValue(mm, spd);
    }
  }
}

int motorSpeed[2] = {MOTOR_STOP, MOTOR_STOP};

void setMotorValue(int motor, int spd) {

  // If this is a switch from forward/backward then send the 
  // stop signal and set a delay
  if ((spd > MOTOR_STOP && motorSpeed[motor] < MOTOR_STOP) ||
      (spd < MOTOR_STOP && motorSpeed[motor] > MOTOR_STOP)) {
        setMotorValue(motor, MOTOR_STOP);
        delay(50);
  }
  
  // write to the appropriate motor
  motorSpeed[motor] = spd;
  if (motor == PIN_RIGHT) {
    servoRight.write(spd);
  }
  else {
    servoLeft.write(spd);
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
        uint8_t controlFlag = rec_buffer[ii];
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


/**
 * Autopilot using range finder
 */

static int reverseCount = 0;
static int forwardCount = 0;
static int autoSteer = STEER_LEFT;

void resetAutopilot() {
  // reset if using remote
  reverseCount = 0;
  forwardCount = 0;
  autoSteer = STEER_LEFT;
}

void checkRange() {
  
  if (reverseCount > 0) {
    // count down the reverse count if backing up
    reverseCount--;
    if (reverseCount == 10) {
      dir = 0;
      flipAutoSteer();
    }
  }
  else if (hasObjectInFront()) {
    reverseCount = 20;
    dir = DIR_BACKWARD;
    steer = autoSteer;
    flipAutoSteer();
  }
  else {
    // move in serpentine
    dir = DIR_FORWARD;
    steer = autoSteer;
    forwardCount++;
    if (forwardCount > 20) {
      flipAutoSteer();
    }
  }
}

void flipAutoSteer() {
  forwardCount = 0;
  autoSteer = (autoSteer == STEER_LEFT) ? STEER_RIGHT : STEER_LEFT;
}

bool hasObjectInFront() {
  
  // trigger a read
  digitalWrite(PIN_TRIG, LOW);  
  delayMicroseconds(2); 
  digitalWrite(PIN_TRIG, HIGH);
  delayMicroseconds(5); 
  digitalWrite(PIN_TRIG, LOW);

  // read value
  long duration = pulseIn(PIN_ECHO, HIGH);

  return duration < 800;
}

