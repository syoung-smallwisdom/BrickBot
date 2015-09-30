
#define PIN_TRIG  3
#define PIN_ECHO  2

void setupRangeFinder() {
  // Setup echolocation
  pinMode(PIN_TRIG, OUTPUT);
  pinMode(PIN_ECHO, INPUT);
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
