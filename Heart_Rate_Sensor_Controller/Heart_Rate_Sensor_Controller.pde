import processing.serial.*; //import the Serial library
import controlP5.*;
import grafica.*;

Serial port;  // The serial port, this is a new instance of the Serial class (an Object)
ControlP5 cp5;
String portNames[];

GPlot plot;
int step=0;
GPointsArray points;

DropdownList dList;
 
// b_0000 > beats per minute
// s_0000 > signal value

void setup() {
  
  size(1000, 800);
  background(0);
  textSize(30);
  text("BEATS PER MINUTE", 50, 340);
  textSize(70);
  text("Heart Rate Sensor", 350, 50);
  
  cp5 = new ControlP5(this);
  dList = cp5.addDropdownList("list")
                .setPosition(650,40)
                .setSize(200,200)
                .setItemHeight(20)
                .setBarHeight(25)
                .setBackgroundColor(255)           
                .setColorLabel(255);
  
  portNames = Serial.list();
  dList.addItems(portNames);

  // Prepare the points for the plot
  points = new GPointsArray(1000);
  plot = new GPlot(this);

  /**for (int i=0; i<1000; i++)
  {
    points.add(i, random(0, 50));
  }**/
  plot.setPos(40, 225);
  plot.setPoints(points);
  plot.setOuterDim(1000,300);
  plot.getXAxis().setAxisLabelText("time");
  plot.getYAxis().setAxisLabelText("Ampiltude");
  plot.setTitleText("Calculating the no of beats per minute");
  
}

void draw() {
  
  //while (port.available() > 0) { //as long as there is data coming from serial port, read it and store it 
    //serial = port.readStringUntil('\n');
  //}
  
  if(port!=null && port.available()>0){
   
    String s = port.readStringUntil('\n');
    if(s != null) { //<>//
      String str[] = s.split("_"); //<>//
      if(str[0].equals("b")){
          updateBPM(Integer.parseInt(str[1].trim()));
       } else if(str[0].equals("s")){
          updateSignal(Long.parseLong(str[1].trim()));
        }
      }
    }
  
  plot.beginDraw();
  plot.drawBackground();
  plot.drawXAxis();
  plot.drawYAxis();
  plot.drawBox();
  plot.getMainLayer().drawPoints();
  plot.drawLines();
  plot.endDraw();

  //delay(2);
}

void serialEvent2(Serial s){
  String[] str = s.readString().split("_");
  
  if(str[0].equals("b")){
    updateBPM(Integer.parseInt(str[1]));
  } else if(str[0].equals("s")){
    updateSignal(Integer.parseInt(str[1]));
  }
}

void updateBPM(int val){
  
  fill(255);
  rect(50, 350, 150, 80);
  fill(color(160, 160, 160));
  textSize(20);
  text(val, 50, 390);
  
}


void updateSignal(long val){

  plot.addPoint(new GPoint(step, val));
  step++;
  
  if(step > 1000){
    plot.removePoint(0);
  }
}

public void list(float choice){
 
  try {
    println("initiaitng port " + portNames[(int) choice]);
    port = new Serial(this,portNames[(int) choice], 115200);
    port.clear();
   // port.bufferUntil(7);
    println("Success : port intialised");
  } catch (Exception e){
    println(e.toString());
  }
}