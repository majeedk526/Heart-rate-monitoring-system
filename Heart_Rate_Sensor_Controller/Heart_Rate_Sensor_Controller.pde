import processing.serial.*; //import the Serial library //<>//
import controlP5.*; // library for control buttons/ list box
import grafica.*; // library to plot graph

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

  //set window size and display heading
  size(1000, 800);
  background(159, 0, 0);
  textSize(70);
  text("Heart Rate Sensor", 230, 50);
  textSize(30);
  text("BEATS PER MINUTE", 50, 700);
  updateBPM(0);

  // Create list box and add COM port
  cp5 = new ControlP5(this);
  dList = cp5.addDropdownList("list")
    .setPosition(700, 60)
    .setSize(200, 200)
    .setItemHeight(20)
    .setBarHeight(25)
    .setBackgroundColor(255)           
    .setColorLabel(255);

  portNames = Serial.list();
  dList.addItems(portNames);

  // Setup graph and define points array size
  points = new GPointsArray(1000);
  plot = new GPlot(this);

  plot.setPos(40, 225);
  plot.setPoints(points);
  plot.setOuterDim(900, 300);
  plot.getXAxis().setAxisLabelText("time");
  plot.getYAxis().setAxisLabelText("Ampiltude");
  plot.setTitleText("Calculating the no of beats per minute");
}

void draw() {

  if (port!=null && port.available()>0) {

    String s = port.readStringUntil('\n');
    if (s != null) {
      String str[] = s.split("_");
      if (str[0].equals("b")) {
        updateBPM(Integer.parseInt(str[1].trim()));
      } else if (str[0].equals("s")) {
        updateSignal(Long.parseLong(str[1].trim()));
      }
    }
  }

// update graph
  plot.beginDraw();
  plot.drawBackground();
  plot.drawXAxis();
  plot.drawYAxis();
  plot.drawBox();
  plot.getMainLayer().drawPoints();
  plot.drawLines();
  plot.endDraw();
}

// update BPM on in the window
void updateBPM(int val) {
  fill(255);
  rect(width/2-100, 650, 100, 100);
  fill(color(160, 160, 160));
  textSize(30);
  text(val, width/2-60, 700);
}


// update value on graph
void updateSignal(long val) {
  plot.addPoint(new GPoint(step, val));
  step++;
  if (step > 1000) {
    plot.removePoint(0);
  }
}

// open the COM port for serial communication
public void list(float choice) {
  try {
    println("initiaitng port " + portNames[(int) choice]);
    port = new Serial(this, portNames[(int) choice], 115200);
    port.clear();
    // port.bufferUntil(7);
    println("Success : port intialised");
  } 
  catch (Exception e) {
    println(e.toString());
  }
}