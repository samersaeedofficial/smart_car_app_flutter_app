#include <SoftwareSerial.h>

#define TRIG_PIN 11
#define ECHO_PIN 12
#define LEFT_IR_PIN 7
#define RIGHT_IR_PIN 4

// Motor Driver Pins (L298N / L293D)
#define MOTOR_L_F 5
#define MOTOR_L_B 6
#define MOTOR_R_B 9
#define MOTOR_R_F 10

// 4 Corner LED Pins
#define LED_FL A0  // Front Left LED
#define LED_FR A1  // Front Right LED
#define LED_BL A2  // Back Left LED
#define LED_BR A3  // Back Right LED

// Buzzer Pin
#define HORN_PIN 8

// Bluetooth Software Serial (Nano D2 -> TX | Nano D3 -> RX)
SoftwareSerial BT_Serial(2, 3); 

char baseDirection = 'S'; // Selected base direction ('F', 'B', or 'S')
int CarMode = 2;          // Default: Manual Control
int motorSpeed = 200;     // PWM Speed (0-255)
int last_CarMode = -1;

// Turning Indicator Control (0: OFF, 1: LEFT BLINK, 2: RIGHT BLINK)
int turnState = 0;

void setLEDs(bool fl, bool fr, bool bl, bool br) {
  digitalWrite(LED_FL, fl ? HIGH : LOW);
  digitalWrite(LED_FR, fr ? HIGH : LOW);
  digitalWrite(LED_BL, bl ? HIGH : LOW);
  digitalWrite(LED_BR, br ? HIGH : LOW);
}

// Non-blocking LED blinking routine
void updateBlinkLEDs() {
  unsigned long currentMillis = millis();
  static unsigned long previousMillis = 0;
  static bool ledState = false;
  const long interval = 250; // Blink speed (250ms)

  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;
    ledState = !ledState;
  }

  if (turnState == 1) {
    // Left Indicator Blinking
    digitalWrite(LED_FL, ledState ? HIGH : LOW);
    digitalWrite(LED_BL, ledState ? HIGH : LOW);
    digitalWrite(LED_FR, LOW);
    digitalWrite(LED_BR, LOW);
  } else if (turnState == 2) {
    // Right Indicator Blinking
    digitalWrite(LED_FR, ledState ? HIGH : LOW);
    digitalWrite(LED_BR, ledState ? HIGH : LOW);
    digitalWrite(LED_FL, LOW);
    digitalWrite(LED_BL, LOW);
  } else {
    // Turn state == 0 (All OFF)
    setLEDs(false, false, false, false);
  }
}

float getDistance(int trig, int echo) {
  digitalWrite(trig, LOW);
  delayMicroseconds(2);
  digitalWrite(trig, HIGH);
  delayMicroseconds(10);
  digitalWrite(trig, LOW);
  
  long duration = pulseIn(echo, HIGH, 20000); 
  if (duration == 0) return 999.0;
  return duration / 58.0;
}

void Stop_Car() {
  analogWrite(MOTOR_L_F, 0);
  analogWrite(MOTOR_L_B, 0);
  analogWrite(MOTOR_R_B, 0);
  analogWrite(MOTOR_R_F, 0);
  turnState = 0; // Turn off lights
}

void forward() {
  analogWrite(MOTOR_L_F, motorSpeed);
  analogWrite(MOTOR_L_B, 0);
  analogWrite(MOTOR_R_B, 0);
  analogWrite(MOTOR_R_F, motorSpeed);
  turnState = 0; // Turn off lights
}

void backward() {
  analogWrite(MOTOR_L_F, 0);
  analogWrite(MOTOR_L_B, motorSpeed);
  analogWrite(MOTOR_R_B, motorSpeed);
  analogWrite(MOTOR_R_F, 0);
  turnState = 0; // Turn off lights
}

// Forward Turning Routines
void forward_left() {
  analogWrite(MOTOR_L_F, motorSpeed); 
  analogWrite(MOTOR_L_B, 0); 
  analogWrite(MOTOR_R_B, 0);
  analogWrite(MOTOR_R_F, motorSpeed / 2); 
  turnState = 1; // Left blink ON
}

void forward_right() {
  analogWrite(MOTOR_L_F, motorSpeed / 2); 
  analogWrite(MOTOR_L_B, 0); 
  analogWrite(MOTOR_R_B, 0);
  analogWrite(MOTOR_R_F, motorSpeed); 
  turnState = 2; // Right blink ON
}

// Reverse Turning Routines
void backward_left() {
  analogWrite(MOTOR_L_F, 0);
  analogWrite(MOTOR_L_B, motorSpeed); 
  analogWrite(MOTOR_R_B, motorSpeed / 2); 
  analogWrite(MOTOR_R_F, 0);
  turnState = 1; // Left blink ON
}

void backward_right() {
  analogWrite(MOTOR_L_F, 0);
  analogWrite(MOTOR_L_B, motorSpeed / 2); 
  analogWrite(MOTOR_R_B, motorSpeed); 
  analogWrite(MOTOR_R_F, 0);
  turnState = 2; // Right blink ON
}

// Immediate Manual Command Handling
void handleManualCommand(char c) {
  switch (c) {
    case 'F': 
      baseDirection = 'F';
      forward(); 
      break;

    case 'B': 
      baseDirection = 'B';
      backward(); 
      break;

    case 'L': 
      if (baseDirection == 'B') backward_left();
      else forward_left();
      break;

    case 'R': 
      if (baseDirection == 'B') backward_right();
      else forward_right();
      break;

    case 'S': 
      baseDirection = 'S';
      Stop_Car(); 
      break;
  }
}

void Free_Move() {
  float distance = getDistance(TRIG_PIN, ECHO_PIN);
  if (distance > 0 && distance < 25) {
    Stop_Car();
    delay(100);
    forward_left();
    delay(200);
  } else {
    forward();
  }
}

void Line_Follower() {
  int LS = digitalRead(LEFT_IR_PIN);
  int RS = digitalRead(RIGHT_IR_PIN);

  if (LS == 0 && RS == 0) forward();
  else if (LS == 1 && RS == 0) forward_left();
  else if (LS == 0 && RS == 1) forward_right();
  else Stop_Car();
}

void setup() {
  Serial.begin(9600);    
  BT_Serial.begin(9600); 
  
  pinMode(MOTOR_L_F, OUTPUT);
  pinMode(MOTOR_L_B, OUTPUT);
  pinMode(MOTOR_R_B, OUTPUT);
  pinMode(MOTOR_R_F, OUTPUT);
  
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  
  pinMode(LEFT_IR_PIN, INPUT);
  pinMode(RIGHT_IR_PIN, INPUT);

  // LED Pins Setup
  pinMode(LED_FL, OUTPUT);
  pinMode(LED_FR, OUTPUT);
  pinMode(LED_BL, OUTPUT);
  pinMode(LED_BR, OUTPUT);

  // Buzzer Setup
  pinMode(HORN_PIN, OUTPUT);
  noTone(HORN_PIN);

  Stop_Car();
}

void loop() {
  while (BT_Serial.available() > 0) {
    char c = (char)BT_Serial.read();
    
    if (c == '\r' || c == '\n' || c == ' ') continue;

    // Speed adjustment (e.g. V180)
    if (c == 'V') {
      int parsedSpeed = 0;
      unsigned long startMs = millis();
      while (millis() - startMs < 50) { 
        if (BT_Serial.available() > 0) {
          char d = (char)BT_Serial.read();
          if (d >= '0' && d <= '9') {
            parsedSpeed = parsedSpeed * 10 + (d - '0');
          } else break;
        }
      }
      if (parsedSpeed > 0 && parsedSpeed <= 255) {
        motorSpeed = parsedSpeed;
        if (CarMode == 2) {
          if (baseDirection == 'F') forward();
          else if (baseDirection == 'B') backward();
        }
      }
      continue;
    }

    // Horn Bluetooth Commands
    if (c == 'H') {
      tone(HORN_PIN, 400); // Horn Sound ON (Low pitch tone)
      digitalWrite(HORN_PIN, HIGH); // Active buzzer support
      continue;
    } else if (c == 'h') {
      noTone(HORN_PIN);    // Horn Sound OFF
      digitalWrite(HORN_PIN, LOW);
      continue;
    }

    // Mode Switching & Drive Control
    if (c == 'A') {
      CarMode = 1; 
      Stop_Car();
    } else if (c == 'M') {
      CarMode = 2; 
      baseDirection = 'S';
      Stop_Car();
    } else if (c == 'G') {
      CarMode = 3; 
      Stop_Car();
    } else if (c == 'S' && CarMode != 2) {
      CarMode = 0; 
      Stop_Car();
    } else {
      if (c == 'F' || c == 'B' || c == 'L' || c == 'R' || c == 'S') {
        CarMode = 2; 
        handleManualCommand(c);
      }
    }
  }

  // Handle Mode Change Reset
  if (CarMode != last_CarMode) {
    Stop_Car();
    last_CarMode = CarMode;
  }

  // Continuous Modes Execution
  if (CarMode == 1) Free_Move();
  else if (CarMode == 3) Line_Follower();
  else if (CarMode == 0) Stop_Car();

  // Update Indicator LEDs state continuously
  updateBlinkLEDs();
}