/**
 * Simple single box control program.
 */

import processing.serial.*;
import processing.opengl.*;

Serial myPort;  // Create object from Serial class
int val;      // Data received from the serial port
int[] potDestinations = {64, 64, 64, 64};

void setup() 
{
  size(210, 200, OPENGL);
  frameRate(30);
  // I know that the first port in the serial list on my mac
  // is always my  FTDI adaptor, so I open Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  delay(1000);
  println(Serial.list());
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
}

int protocolCounter = 0;

final int TOTAL_POTS = 4;
final int TOTAL_SWITCHES = 2;

int[] potValues = new int[TOTAL_POTS];
int[] switchValues = new int[TOTAL_SWITCHES];

void draw()
{
  //background(64);
  fill(64,64,64,52);
  rect(0, 0, width, height);
  for(int i=0; i<TOTAL_POTS; i++){
      fill(2*potValues[i]);
      rect(i*50+10, 25+potValues[i], 40, 20);
      fill(255, 190, 220);
      rect(i*50+10, 30+potDestinations[i], 40, 10);
  }
  if(doSin){
    float speed = 0.25;
    potDestinations[0] = (int)(64+40*sin((float)frameCount*speed+0.0));
    potDestinations[1] = (int)(64+40*sin((float)frameCount*speed+PI/4.0));
    potDestinations[2] = (int)(64+40*sin((float)frameCount*speed+PI/2));
    potDestinations[3] = (int)(64+40*sin((float)frameCount*speed+3.0*PI/4.0));
    sendPotDestinations();
  }
  
  
  for (int i = 0; i < TOTAL_SWITCHES; i++) {
      fill(switchValues[i] * 255);
      ellipse((i+1) * 30, height - 20, 20, 20);
  }
}


void serialEvent(Serial myPort) {
while ( myPort.available() > 0) {  // If data is available,
    byte b = (byte)myPort.read();

    if (protocolCounter == 0) {
        if (b == -1) {
            protocolCounter++;
        } 
    } else if (protocolCounter > 0) {
        if (protocolCounter <= TOTAL_POTS) {
            potValues[protocolCounter-1] = b;
        } else {
          int switchIndex = protocolCounter - TOTAL_POTS - 1;  
          if (switchIndex < TOTAL_SWITCHES) {
              if (switchValues[switchIndex] != b) {
                  switchValues[switchIndex] = b;
              }
          }  
        }
        println(protocolCounter+" = "+b);
        protocolCounter++;
        if (protocolCounter > TOTAL_POTS + TOTAL_SWITCHES) {
            protocolCounter = 0;
            println("----------");
        }
    }
  }
}

void mouseClicked(){
  int pot = min(TOTAL_POTS-1, (int)((mouseX*4) / width));
  potDestinations[pot] = (mouseY)*127/height;
  sendPotDestinations();
}

void sendPotDestinations(){
  myPort.write((byte)255);
  for(int i=0; i<TOTAL_POTS; i++){
   myPort.write((byte)0x7F&(byte)potDestinations[i]);
  }
}

boolean doSin = false;
void keyPressed(){
  if(key == 's'){
    doSin = !doSin;
  }
}


