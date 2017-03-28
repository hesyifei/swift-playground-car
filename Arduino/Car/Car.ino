// Arduino pins for the shift register
#define MOTORLATCH 12
#define MOTORCLK 4
#define MOTORENABLE 7
#define MOTORDATA 8

// 8-bit bus after the 74HC595 shift register
// (not Arduino pins)
// These are used to set the direction of the bridge driver.
#define MOTOR1_A 2
#define MOTOR1_B 3
#define MOTOR2_A 1
#define MOTOR2_B 4
#define MOTOR3_A 5
#define MOTOR3_B 7
#define MOTOR4_A 0
#define MOTOR4_B 6

// Arduino pins for the PWM signals.
#define MOTOR1_PWM 11
#define MOTOR2_PWM 3
#define MOTOR3_PWM 6
#define MOTOR4_PWM 5
#define SERVO1_PWM 10
#define SERVO2_PWM 9

// Codes for the motor function.
#define FORWARD 1
#define BACKWARD 2
#define BRAKE 3
#define RELEASE 4

#define TURN_LEFT 11
#define TURN_RIGHT 12

// 255
#define SPEED 200


// for ultra sonic
#define TRIGPIN A9
#define ECHOPIN A8


unsigned long previousMillis = 0;        // will store last time data was obtained
const long interval = 10;


int positionData = 0;



const char startByte = '<';
const char stopByte = '>';

const byte maxBuffer = 20;



void setup()
{
  Serial1.begin(9600);
  Serial.begin(9600);

  Serial.println("Hello! :D");

  pinMode(TRIGPIN, OUTPUT);
  pinMode(ECHOPIN, INPUT);
}


void loop()
{
  unsigned long currentMillis = millis();

  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;

    positionData++;
    //Serial.println(positionData);


    long cm = ping();
    Serial1.print(cm);
    Serial1.print(" ");

    if (cm <= 100) {
      //Serial.println("HAHAHA");
    }
  }

  //movePos(FORWARD, 10000);
  //rotate(TURN_LEFT, 10000);


  // Stores the characters between the start and stop bytes
  static char buffer[maxBuffer];
  // Keeps track of spot in buffer
  static byte index = 0;
  if (Serial1.available()) {
    char cmdChar;
    unsigned int para = 0;


    char inChar = Serial1.read();
    Serial.print(inChar);

    if (inChar == startByte) { // If start byte is received
      index = 0; // then reset buffer and start fresh
    } else if (inChar == stopByte) { // If stop byte is received
      Serial.println("");
      buffer[index] = '\0'; // then null terminate
      String inputString = String(buffer);
      String oriString = inputString;
      Serial.println(inputString);

      cmdChar = buffer[0];
      Serial.println(cmdChar);

      inputString.remove(0, 1);
      para = processData(inputString); // and process the data
      Serial.println(para);

      index = 0; // this isn't necessary, but helps limit overflow
    } else { // otherwise
      buffer[index] = inChar; // put the character into our array
      index++; // and move to the next key in the array
    }

    /* Overflow occurs when there are more than 5 characters in between
       the start and stop bytes. This has to do with having limited space
       in our array. We chose to limit our array to 5 (+1 for null terminator)
       because an int will never be above 5 characters */
    if (index >= maxBuffer) {
      index = 0;
      Serial.println("Overflow occured, next value is unreliable");
    }

    if (cmdChar == 'f') {
      movePos(FORWARD, para);
    } else if (cmdChar == 'b') {
      movePos(BACKWARD, para);
    } else if (cmdChar == 'r') {    // turn right
      rotate(TURN_RIGHT, para);
    } else if (cmdChar == 'l') {    // turn left
      rotate(TURN_LEFT, para);
    } else if (cmdChar == 's') {    // stop car
      movePos(RELEASE, 0);
    }
  }
}

unsigned int processData(String iStr) {
  unsigned int value = iStr.toInt(); // convert string to int
  //Serial.print("Value: ");
  //Serial.println(value);
  return value;
}

void movePos(int command, int timeI) {
  motor(1, command, SPEED);
  motor(2, command, SPEED);
  motor(3, command, SPEED);
  motor(4, command, SPEED);
  if (timeI != 0) {
    delay(timeI);
    motor(1, RELEASE, 0);
    motor(2, RELEASE, 0);
    motor(3, RELEASE, 0);
    motor(4, RELEASE, 0);
  }
}

void rotate(int command, int timeI) {
  switch (command)
  {
    case TURN_LEFT:
      motor(1, BACKWARD, SPEED);
      motor(2, FORWARD, SPEED);
      motor(3, FORWARD, SPEED);
      motor(4, BACKWARD, SPEED);
      break;
    case TURN_RIGHT:
      motor(1, FORWARD, SPEED);
      motor(2, BACKWARD, SPEED);
      motor(3, BACKWARD, SPEED);
      motor(4, FORWARD, SPEED);
      break;
  }
  if (timeI != 0) {
    delay(timeI);
    motor(1, RELEASE, 0);
    motor(2, RELEASE, 0);
    motor(3, RELEASE, 0);
    motor(4, RELEASE, 0);
  }
}



// for ultrasonic
long ping() {
  digitalWrite(TRIGPIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIGPIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIGPIN, LOW);
  return pulseIn(ECHOPIN, HIGH) / 58;
}


// DON'T CHANGE BELOW


// Initializing
// ------------
// There is no initialization function.
//
// The shiftWrite() has an automatic initializing.
// The PWM outputs are floating during startup,
// that's okay for the Motor Shield, it stays off.
// Using analogWrite() without pinMode() is valid.
//


// ---------------------------------
// motor
//
// Select the motor (1-4), the command,
// and the speed (0-255).
// The commands are: FORWARD, BACKWARD, BRAKE, RELEASE.
//
void motor(int nMotor, int command, int speed)
{
  int motorA, motorB;

  if (nMotor >= 1 && nMotor <= 4)
  {
    switch (nMotor)
    {
      case 1:
        motorA   = MOTOR1_A;
        motorB   = MOTOR1_B;
        break;
      case 2:
        motorA   = MOTOR2_A;
        motorB   = MOTOR2_B;
        break;
      case 3:
        motorA   = MOTOR3_A;
        motorB   = MOTOR3_B;
        break;
      case 4:
        motorA   = MOTOR4_A;
        motorB   = MOTOR4_B;
        break;
      default:
        break;
    }

    switch (command)
    {
      case FORWARD:
        motor_output (motorA, HIGH, speed);
        motor_output (motorB, LOW, -1);     // -1: no PWM set
        break;
      case BACKWARD:
        motor_output (motorA, LOW, speed);
        motor_output (motorB, HIGH, -1);    // -1: no PWM set
        break;
      case BRAKE:
        // The AdaFruit library didn't implement a brake.
        // The L293D motor driver ic doesn't have a good
        // brake anyway.
        // It uses transistors inside, and not mosfets.
        // Some use a software break, by using a short
        // reverse voltage.
        // This brake will try to brake, by enabling
        // the output and by pulling both outputs to ground.
        // But it isn't a good break.
        motor_output (motorA, LOW, 255); // 255: fully on.
        motor_output (motorB, LOW, -1);  // -1: no PWM set
        break;
      case RELEASE:
        motor_output (motorA, LOW, 0);  // 0: output floating.
        motor_output (motorB, LOW, -1); // -1: no PWM set
        break;
      default:
        break;
    }
  }
}


// ---------------------------------
// motor_output
//
// The function motor_ouput uses the motor driver to
// drive normal outputs like lights, relays, solenoids,
// DC motors (but not in reverse).
//
// It is also used as an internal helper function
// for the motor() function.
//
// The high_low variable should be set 'HIGH'
// to drive lights, etc.
// It can be set 'LOW', to switch it off,
// but also a 'speed' of 0 will switch it off.
//
// The 'speed' sets the PWM for 0...255, and is for
// both pins of the motor output.
//   For example, if motor 3 side 'A' is used to for a
//   dimmed light at 50% (speed is 128), also the
//   motor 3 side 'B' output will be dimmed for 50%.
// Set to 0 for completelty off (high impedance).
// Set to 255 for fully on.
// Special settings for the PWM speed:
//    Set to -1 for not setting the PWM at all.
//
void motor_output (int output, int high_low, int speed)
{
  int motorPWM;

  switch (output)
  {
    case MOTOR1_A:
    case MOTOR1_B:
      motorPWM = MOTOR1_PWM;
      break;
    case MOTOR2_A:
    case MOTOR2_B:
      motorPWM = MOTOR2_PWM;
      break;
    case MOTOR3_A:
    case MOTOR3_B:
      motorPWM = MOTOR3_PWM;
      break;
    case MOTOR4_A:
    case MOTOR4_B:
      motorPWM = MOTOR4_PWM;
      break;
    default:
      // Use speed as error flag, -3333 = invalid output.
      speed = -3333;
      break;
  }

  if (speed != -3333)
  {
    // Set the direction with the shift register
    // on the MotorShield, even if the speed = -1.
    // In that case the direction will be set, but
    // not the PWM.
    shiftWrite(output, high_low);

    // set PWM only if it is valid
    if (speed >= 0 && speed <= 255)
    {
      analogWrite(motorPWM, speed);
    }
  }
}


// ---------------------------------
// shiftWrite
//
// The parameters are just like digitalWrite().
//
// The output is the pin 0...7 (the pin behind
// the shift register).
// The second parameter is HIGH or LOW.
//
// There is no initialization function.
// Initialization is automatically done at the first
// time it is used.
//
void shiftWrite(int output, int high_low)
{
  static int latch_copy;
  static int shift_register_initialized = false;

  // Do the initialization on the fly,
  // at the first time it is used.
  if (!shift_register_initialized)
  {
    // Set pins for shift register to output
    pinMode(MOTORLATCH, OUTPUT);
    pinMode(MOTORENABLE, OUTPUT);
    pinMode(MOTORDATA, OUTPUT);
    pinMode(MOTORCLK, OUTPUT);

    // Set pins for shift register to default value (low);
    digitalWrite(MOTORDATA, LOW);
    digitalWrite(MOTORLATCH, LOW);
    digitalWrite(MOTORCLK, LOW);
    // Enable the shift register, set Enable pin Low.
    digitalWrite(MOTORENABLE, LOW);

    // start with all outputs (of the shift register) low
    latch_copy = 0;

    shift_register_initialized = true;
  }

  // The defines HIGH and LOW are 1 and 0.
  // So this is valid.
  bitWrite(latch_copy, output, high_low);

  // Use the default Arduino 'shiftOut()' function to
  // shift the bits with the MOTORCLK as clock pulse.
  // The 74HC595 shiftregister wants the MSB first.
  // After that, generate a latch pulse with MOTORLATCH.
  shiftOut(MOTORDATA, MOTORCLK, MSBFIRST, latch_copy);
  delayMicroseconds(5);    // For safety, not really needed.
  digitalWrite(MOTORLATCH, HIGH);
  delayMicroseconds(5);    // For safety, not really needed.
  digitalWrite(MOTORLATCH, LOW);
}

