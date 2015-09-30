/**
 * Autopilot using range finder
 */
static int reverseCount = 0;
static int forwardCount = 0;
static int autoSteer = STEER_LEFT;

void updateAutopilot() {
    if (autopilotOn) {
      // If the autopilot is on then check the range
      checkRange();
    }
    else {
      // Otherwise, reset the autopilot state
      resetAutopilot();
    }
}

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
      // Once the robot has backed up, then turn before starting forward again
      dir = 0;
      flipAutoSteer();
    }
  }
  else if (hasObjectInFront()) {
    // Object in front detected so start the reverse
    reverseCount = 20;
    dir = DIR_BACKWARD;
    steer = autoSteer;
    flipAutoSteer();
  }
  else {
    // move in serpentine - this gives the rangefinder a broader scope
    // which means it does a better job of "seeing" obsticles like chair legs
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
