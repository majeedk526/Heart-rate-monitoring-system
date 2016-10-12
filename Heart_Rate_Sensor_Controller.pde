import processing.serial.*; //import the Serial library
import controlP5.*;
import grafica.*;

String serial;   // declare a new string called 'serial' . A string is a sequence of characters (data type know as "char")
Serial port;  // The serial port, this is a new instance of the Serial class (an Object)
ControlP5 cp5;
int a[]=new int[60];
GPlot plot;
int step=0;
GPointsArray points;
void setup() {
  size(1000, 800);
  background(0);

  // Prepare the points for the plot
  points = new GPointsArray(60);
  plot = new GPlot(this);

  for (int i=0; i<60; i++)
  {
    points.add(i, random(0, 8));
  }
  plot.setPos(525, 225);
  plot.setPoints(points);
  plot.getXAxis().setAxisLabelText("time");
  plot.getYAxis().setAxisLabelText("Ampiltude");
  plot.setTitleText("Calculating the no of beats per minute");
  port = new Serial(this, Serial.list()[0], 9600); // initializing the object by assigning a port and baud rate (must match that of Arduino)
  port.clear();  // function from serial library that throws out the first reading, in case we started reading in the middle of a string from Arduino
  serial = port.readStringUntil('\n'); // function that reads the string from serial port until a println and then assigns string to our string variable (called 'serial')
  serial = null; // initially, the string will be null (empty)
  println(plot.getPointsRef().get(59));
}

void draw() {
  // background(0);



  PFont font;
  // The font must be located in the sketch's 
  // "data" directory to load successfully
  font = createFont("Arial", 15);
  textFont(font, 32);
  text("Heart Rate Sensor", 350, 50);
  

  while (port.available() > 0) { //as long as there is data coming from serial port, read it and store it 
    serial = port.readStringUntil('\n');
  }
  if (serial != null) {  //if the string is not empty, print the following

    /*  Note: the split function used below is not necessary if sending only a single variable. However, it is useful for parsing (separating) messages when
     reading from multiple inputs in Arduino. Below is example code for an Arduino sketch
     */

    //    String[] a = split(serial, ',');  //a new array (called 'a') that stores values into separate cells (separated by commas specified in your Arduino program)
    //println(a[0]); //print Value1 (in cell 1 of Array - remember that arrays are zero-indexed)
    //println(a[1]); //print Value2 value
  }
  textFont(font, 16);
  text("BEATS PER MINUTE", 50, 340);
  float c=random(0, 70);
  fill(255);
  rect(50, 350, 150, 80);
  fill(color(160, 160, 160));
  textSize(20);
  text(c, 50, 390);
  for (int i = 0; i < 60; i++) {
    points.add(i, 0);
  }
  plot.addPoint(new GPoint(step, random(0, 50)));
  plot.removePoint(0);
  step++;
  if (step>60) {
    step=0;
  }
  plot.beginDraw();
  plot.drawBackground();
  plot.drawXAxis();
  plot.drawYAxis();
  plot.drawBox();
  plot.getMainLayer().drawPoints();
  plot.drawLines();
  plot.endDraw();

  // delay(500);
}