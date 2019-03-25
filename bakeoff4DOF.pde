import java.util.ArrayList;
import java.util.Collections;
import java.util.Arrays;

//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float border = 0; //some padding from the sides of window
int trialCount = 12; //this will be set higher for the bakeoff
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this value to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false; //is the user done

final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float screenTransX = 0;
float screenTransY = 0;
float screenRotation = 0;
float screenZ = 50f;

// Translation Control
float rectDiag = sqrt((screenZ*screenZ)/2);
boolean tcClicked = false;
float tcOffsetX, tcOffsetY;

// Size Control
float sizeControlSize;
boolean scClicked = false;

// Rotation Control
float rotationControlSize = 10.0f;
Point rotationPoint;
float hoveringDist = 30.0f;
boolean rcClicked = false;

// Green signals
boolean translation_green = false;
boolean size_green = false;
boolean rotation_green = false;

private class Target
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

private class Point
{
  float x,y;
  
  Point(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

ArrayList<Target> targets = new ArrayList<Target>();

void setup() {
  size(1000, 800); 

  rectMode(CENTER);
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  textAlign(CENTER);

  //don't change this! 
  border = inchToPix(2f); //padding of 1.0 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Target t = new Target();
    t.x = random(-width/2+border, width/2-border); //set a random x with some padding
    t.y = random(-height/2+border, height/2-border); //set a random y with some padding
    t.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    t.z = ((j%12)+1)*inchToPix(.25f); //increasing size from .25 up to 3.0" 
    targets.add(t);
    println("created target with " + t.x + "," + t.y + "," + t.rotation + "," + t.z);
  }

  Collections.shuffle(targets); // randomize the order of the button; don't change this.
}



void draw() {

  background(40); //background is dark grey
  fill(200);
  noStroke();

  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per target", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per target inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }

  //===========DRAW DESTINATION SQUARES=================
  for (int i=0; i<trialCount; i++)
  {
    pushMatrix();
    translate(width/2, height/2); //center the drawing coordinates to the center of the screen
    Target t = targets.get(i);
    translate(t.x, t.y); //center the drawing coordinates to the center of the screen
    rotate(radians(t.rotation));
    if (trialIndex==i)
      fill(255, 0, 0, 192); //set color to semi translucent
    else
      fill(128, 60, 60, 128); //set color to semi translucent
    rect(0, 0, t.z, t.z);
    // CENTER POINT
    noStroke();
    fill(0,255,0);
    circle(0,0,10);
    popMatrix();
  }

  //===========DRAW CURSOR SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  translate(screenTransX, screenTransY);
  rotate(radians(screenRotation));
  noFill();
  strokeWeight(3f);
  stroke(160);
  if (translation_green && rotation_green && size_green) stroke(0,255,0);
  rect(0, 0, screenZ, screenZ);
  // CENTER POINT
  noStroke();
  fill(255,255,0);
  circle(0,0,10);
  
  
  popMatrix();
  
  //===========DRAW SIZE CONTROL=================
  fill(160);
  sizeControlSize = screenZ * 2 / 27 + (234/27);
  Point[] corners = getCorners();
  for (Point point : corners) {
    circle(point.x, point.y, sizeControlSize);
  }
  
  //===========DRAW ROTATION CONTROL=================
  rotationPoint = getHoveringPoint(corners[0], corners[1]);
  circle(rotationPoint.x, rotationPoint.y, rotationControlSize);

  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  scaffoldControlLogic(); //you are going to want to replace this!
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
  
  //===========DRAW GREEN SIGNALS=================
  float signalHGap = inchToPix(0.3f);
  float signalVGap = inchToPix(0.5f);
  float signalSize = inchToPix(0.5f);
  float signalFontSize = 13.0;
  
  float x = width - signalSize;
  float y = signalVGap;
  noStroke();
  textSize(signalFontSize);
  // Rotation Green Signal
  if (rotation_green) fill(0,200,30);
  else fill(160);
  rect(x, y, signalSize, signalSize);
  fill(255);
  text("Rotation", x, y + signalSize);
  
  // Size Green Signal
  x -= signalSize + signalHGap;
  if (size_green) fill(0,200,30);
  else fill(160);
  rect(x, y, signalSize, signalSize);
  fill(255);
  text("Size", x, y + signalSize);
  
  // Translation Green Signal
  x -= signalSize + signalHGap;
  if (translation_green) fill(0,200,30);
  else fill(160);
  rect(x, y, signalSize, signalSize);
  fill(255);
  text("Position", x, y + signalSize);
  
}

//my example design for control, which is terrible
void scaffoldControlLogic()
{
  // Check for green signals
  if (mousePressed) {
    refresh_green();
  }

  // Rotation Control
  if(mousePressed && dist(rotationPoint.x, rotationPoint.y, mouseX, mouseY) < rotationControlSize && !(tcClicked || scClicked)) {
    rcClicked = true;
  }
  
  // Size Control
  Point[] corners = getCorners();
  for (Point corner : corners) {
    if(mousePressed && dist(corner.x, corner.y, mouseX, mouseY) < sizeControlSize && !(rcClicked || tcClicked)) {
      scClicked = true;
    }
  }
  
  // Translation Control
  if (mousePressed && dist(screenTransX + width/2, screenTransY + height/2, mouseX, mouseY) < rectDiag && !(rcClicked || scClicked)) {
    tcClicked = true;
    tcOffsetX = mouseX - screenTransX + width/2;
    tcOffsetY = mouseY - screenTransY + height/2;
  }

  //left middle, move left
  text("left", inchToPix(.4f), height/2);
  if (mousePressed && dist(0, height/2, mouseX, mouseY)<inchToPix(.8f))
    screenTransX-=inchToPix(.02f);

  text("right", width-inchToPix(.4f), height/2);
  if (mousePressed && dist(width, height/2, mouseX, mouseY)<inchToPix(.8f))
    screenTransX+=inchToPix(.02f);

  text("up", width/2, inchToPix(.4f));
  if (mousePressed && dist(width/2, 0, mouseX, mouseY)<inchToPix(.8f))
    screenTransY-=inchToPix(.02f);

  text("down", width/2, height-inchToPix(.4f));
  if (mousePressed && dist(width/2, height, mouseX, mouseY)<inchToPix(.8f))
    screenTransY+=inchToPix(.02f);
}


void mousePressed()
{  
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
}

void mouseReleased()
{
  if (rcClicked) {
    rcClicked = false;
    return;
  }
  if (tcClicked) {
    tcClicked = false;
    return;
  }
  if (scClicked) {
    scClicked = false;
    return;
  }
  
  //check to see if user clicked middle of screen within 3 inches
  if (dist(width/2, height/2, mouseX, mouseY)<inchToPix(3f))
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    trialIndex++; //and move on to next trial

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
}

void mouseDragged() {
  float cursorX = screenTransX + width/2;
  float cursorY = screenTransY + height/2;
  float distance = dist(cursorX, cursorY, mouseX, mouseY);
  
  // Size Control
  if (scClicked) {
    screenZ = constrain(sqrt(2) * distance, inchToPix(.25f), inchToPix(4f));
    rectDiag = sqrt((screenZ*screenZ)/2);
  }
  
  // Translation Control
  else if (tcClicked) {
    screenTransX = -(tcOffsetX - mouseX - width/2);
    screenTransY = -(tcOffsetY - mouseY - height/2);
  }
  
  // Rotation Control
  else if (rcClicked) {
    float rotation = PI * -2/4 + atan2((cursorY - mouseY), (cursorX - mouseX));
    screenRotation = rotation * 180 / PI;
  }
}

void refresh_green() {
  Target t = targets.get(trialIndex);  
  translation_green = dist(t.x, t.y, screenTransX, screenTransY)<inchToPix(.05f);
  size_green = abs(t.z - screenZ)<inchToPix(.05f);
  rotation_green = calculateDifferenceBetweenAngles(t.rotation, screenRotation)<=5;
}

Point[] getCorners() {
  float x = screenTransX + width/2;
  float y = screenTransY + height/2;
  
  float rectDiag = sqrt((screenZ*screenZ)/2);
  float rectAngle = (float)Math.PI / 4;
  float rotation = screenRotation * (float)Math.PI / 180;
  
  Point[] corners = new Point[4];
  corners[0] = new Point(x +  rectDiag * cos(-rectAngle + rotation), y +  rectDiag * sin(-rectAngle + rotation));
  corners[1] = new Point(x + -rectDiag * cos( rectAngle + rotation), y + -rectDiag * sin( rectAngle + rotation));
  corners[2] = new Point(x + -rectDiag * cos(-rectAngle + rotation), y + -rectDiag * sin(-rectAngle + rotation));
  corners[3] = new Point(x +  rectDiag * cos( rectAngle + rotation), y +  rectDiag * sin( rectAngle + rotation));
  
  return corners;
}

Point getHoveringPoint(Point p1, Point p2) {
  float x1 = p1.x;
  float y1 = p1.y;
  float x2 = p2.x;
  float y2 = p2.y;
  
  float diagLen = sqrt(pow((y1-y2),2) + pow((x1-x2),2));
  
  float x = (x1+x2)/2 + hoveringDist * (y1-y2) / diagLen;
  float y = (y1+y2)/2 + hoveringDist * (x2-x1) / diagLen;
  
  return new Point(x,y);
}


//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Target t = targets.get(trialIndex);	
  boolean closeDist = dist(t.x, t.y, screenTransX, screenTransY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation, screenRotation)<=5;
  boolean closeZ = abs(t.z - screenZ)<inchToPix(.05f); //has to be within +-0.05"	

  println("Close Enough Distance: " + closeDist + " (cursor X/Y = " + t.x + "/" + t.y + ", target X/Y = " + screenTransX + "/" + screenTransY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(t.rotation, screenRotation)+")");
  println("Close Enough Z: " +  closeZ + " (cursor Z = " + t.z + ", target Z = " + screenZ +")");
  println("Close enough all: " + (closeDist && closeRotation && closeZ));

  return closeDist && closeRotation && closeZ;
}

//utility function I include to calc diference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}

//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}
