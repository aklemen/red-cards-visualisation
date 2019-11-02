import controlP5.*;

import java.util.Date;

// Locations in usual mode

float homeX[];
float awayX[];
float redX[];

// Locations in special mode

float homeSpecialX[];
float awaySpecialX[];
float redSpecialX[];

// Current locations

float homeSpecialX[];
float awaySpecialX[];
float redSpecialX[];

float redCardDistances[];

ControlP5 cp5;

float unit; 
Toggle modeSwitch;

float closestDist;
String closestText;
float closestTextX;
float closestTextY;



void setup() {

  // setup the surface

  background(white);
  size (1500, 1000);
  surface.setResizable(true);
  smooth();

  // init list

  loadFileToObjectList();

  redCardDistances = new float[listOfMatchesSize];
  homeLocsX = new float[listOfMatchesSize];
  awayLocsX = new float[listOfMatchesSize];
  redCardLocsX = new float[listOfMatchesSize];

  cp5 = new ControlP5(this);

  unit = (height - (2*marginVertical)) / (listOfMatchesSize);

  modeSwitch = cp5.addToggle("modeSwitch")
    .setCaptionLabel("")
    .setMode(ControlP5.SWITCH)
    .setColorBackground(lightGrey)
    .setColorForeground(home)
    .setValueLabel("HEEJ") 
    //.setValue(true)
    ;
}

void draw() {

  // define the unit

  unit = (height - (2*marginVertical)) / (listOfMatchesSize);

  // horizontal lines and scale

  rectMode(CORNER);
  noStroke();
  textSize(unit*0.7);

  for (int i = 0; i < listOfMatchesSize; i++) {

    Match tempMatch = listOfMatches.get(i);

    noStroke();
    rectMode(CORNER);

    if (i % 2 == 0) {
      fill(lightGrey);
      rect(0, marginVertical + (i*unit), width - marginHorizontal, unit);
    } else {
      fill(white);
      rect(0, marginVertical + (i*unit), width - marginHorizontal, unit);
    }

    drawName(i);
    drawScale();


    // draw red cards

    if (tempMatch.getHomeRedTime() != 0) {
      drawRedCard(tempMatch.getHomeRedTime(), i, "home");
    } else {
      drawRedCard(tempMatch.getAwayRedTime(), i, "away");
    }

    // draw goals

    int[] tempGoals;

    if (tempMatch.getHomeGoals().length > 0) {
      tempGoals = tempMatch.getHomeGoals();
      for (int j = 0; j < tempGoals.length; j++) {
        drawGoal(tempGoals[j], i, "home");
      }
    }

    if (tempMatch.getAwayGoals().length > 0) {
      tempGoals = tempMatch.getAwayGoals();
      for (int j = 0; j < tempGoals.length; j++) {
        drawGoal(tempGoals[j], i, "away");
      }
    }
  }

  rectMode(CENTER);
  modeSwitch.setSize((int)unit*5, (int)unit*3);
  modeSwitch.setPosition(width - (marginHorizontal/3) - (modeSwitch.getWidth() / 2), marginVertical*3);
}


void drawScale() {
  //strokeWeight(1);
  //stroke(lightGrey);
  //line(mapMinutes(45), marginVertical, mapMinutes(45), height - marginVertical);
  //line(mapMinutes(90), marginVertical, mapMinutes(90), height - marginVertical);

  // axis

  stroke(black);  
  line(marginHorizontal, marginVertical, marginHorizontal, height - marginVertical);
  line(marginHorizontal, height - marginVertical, width - marginHorizontal, height - marginVertical);

  // toolbar

  rectMode(CORNER);
  noStroke();
  fill(darkGrey);
  rect(width-((2*marginHorizontal)/3), 2*marginVertical, ((2*marginHorizontal)/3), height-4*marginVertical);
}

void drawName(int i) {
  fill(black);
  textAlign(RIGHT, CENTER);
  text(listOfMatches.get(i).getHomeTeam(), marginHorizontal/2 - (unit/2), marginVertical+(unit/2)+(i*unit));
  textAlign(CENTER, CENTER);
  text(":", marginHorizontal/2, marginVertical+(unit/2)+(i*unit));
  textAlign(LEFT, CENTER);
  text(listOfMatches.get(i).getAwayTeam(), marginHorizontal/2 + (unit/2), marginVertical+(unit/2)+(i*unit));
}

void drawRedCard(float minute, int i, String homeOrAway) {
  float x = mapMinutes(minute);
  redCardDistances[i] = width/2 - x;

  x = redCardDistances[i] + x;

  float y = marginVertical+(i*unit)+unit/2;

  fill(red);
  strokeWeight(3);

  if (homeOrAway.equals("home")) {
    stroke(home);
  } else {
    stroke(away);
  }
  rectMode(CENTER);
  rect(x, y, unit, unit);
}

void drawGoal(float minute, int i, String homeOrAway) {
  float x = mapMinutes(minute);

  x = mapMinutes(minute) + redCardDistances[i];

  float y = marginVertical+(i*unit)+unit/2;

  if (homeOrAway.equals("home")) {
    fill(home);
  } else {
    fill(away);
  }
  noStroke();
  ellipse(x, y, unit, unit);
}
