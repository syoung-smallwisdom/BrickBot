#include <Servo.h>

/**
 * Functions for setting the motor speed.
 */

// Arduino Pin for the right & left motors. These are defined separately from 
// the array position b/c these values are hardcoded based on which pin the motor
// is connected to rather than the array position of the calibrated speeds
#define PIN_LEFT  0
#define PIN_RIGHT 1

// Array position of the motor
#define MOTOR_LEFT  0
#define MOTOR_RIGHT 1

#define STOP 90
#define SLOW 20

Servo servoRight, servoLeft;

#define SPEED_COUNT 3
#define MAX_OFFSET 80
static int full_speed[SPEED_COUNT][2] = {{MAX_OFFSET/2, -90}, {90, -90}, {90, -1*MAX_OFFSET/2}};  // left, straight, right - defaults

void setupMotors() {
  servoRight.attach(PIN_RIGHT);
  servoRight.write(STOP);
  servoLeft.attach(PIN_LEFT);
  servoLeft.write(STOP);
  readMotorCalibration();
}

void stopMotors() {
  dir = 0;
  steer = 0;
  setMotorValue(MOTOR_RIGHT, STOP);
  setMotorValue(MOTOR_LEFT, STOP);
}

void runMotors() {
  if (dir == 0) {
    if (steer == 0) {
      setMotorValue(MOTOR_RIGHT, STOP);
      setMotorValue(MOTOR_LEFT, STOP);
    }
    else {
      setMotorValue(MOTOR_RIGHT, steer * SLOW + 90);
      setMotorValue(MOTOR_LEFT, steer * SLOW + 90);
    }
  }
  else {
    for (int mm=MOTOR_LEFT; mm <= MOTOR_RIGHT; mm++) {
      int spd = dir * full_speed[steer + 1][mm] + 90;
      setMotorValue(mm, spd);
    }
  }
}

int motorSpeed[2] = {STOP, STOP};

void setMotorValue(int motor, int spd) {

  // If this is a switch from forward/backward then send the 
  // stop signal and set a delay
  if ((spd > STOP && motorSpeed[motor] < STOP) ||
      (spd < STOP && motorSpeed[motor] > STOP)) {
        setMotorValue(motor, STOP);
        delay(50);
  }
  
  // write to the appropriate motor
  motorSpeed[motor] = spd;
  if (motor == MOTOR_RIGHT) {
    servoRight.write(spd);
  }
  else {
    servoLeft.write(spd);
  }
}

void readMotorCalibration() {
  ScratchData motorData = Bean.readScratchData(MotorCalibrationScratchBank);
  if (motorData.length >= SPEED_COUNT) {
    for (int ii=0; ii < SPEED_COUNT; ii++) {
      updateMotorCalibration(ii, motorData.data[ii]);
    }
  }
}

void updateMotorCalibration(int ii, uint8_t record) {
  // If the normalized percent is negative, then change LEFT, else change RIGHT
  int percent = (int)record - 100;
  full_speed[ii][MOTOR_LEFT] = percent < 0 ? 90 + MAX_OFFSET * percent / 100 : 90;
  full_speed[ii][MOTOR_RIGHT] = percent > 0 ? -90 + MAX_OFFSET * percent / 100 : -90;
}

