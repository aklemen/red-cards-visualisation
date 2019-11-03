import controlP5.*;

import java.util.Date;

ControlP5 cp5;

float unit; 
Toggle modeSwitch;

float closestDist;
String closestText;
float closestTextX;
float closestTextY;

Integrator[] interpolators;
Integrator[][] homeInterpolators;
Integrator[][] awayInterpolators;

PFont regularFont;
PFont mediumFont;
PFont boldFont;

boolean modeSwitchValue = false;

boolean redCards = true;
boolean teamWithRC = true;
boolean teamNoRC = true;

String currentRedCardIndicator;

void setup() {

  // setup the surface

  background(white);
  size (1500, 1000);
  surface.setResizable(true);
  smooth();

  regularFont = createFont("Montserrat Regular", 12);
  mediumFont = createFont("Montserrat Medium", 12);
  boldFont = createFont("Montserrat Bold", 12);
  textFont(boldFont);

  // init list

  loadFileToObjectList();

  cp5 = new ControlP5(this);

  unit = (height - (2*marginVertical)) / (listOfMatchesSize);

  modeSwitch = cp5.addToggle("modeSwitchValue")
    .setCaptionLabel("")
    .setMode(ControlP5.SWITCH)
    .setColorBackground(home)
    .setColorActive(lightGrey)
    ;

  updateLocations();

  interpolators = new Integrator[listOfMatchesSize];
  homeInterpolators = new Integrator[listOfMatchesSize][5];
  awayInterpolators = new Integrator[listOfMatchesSize][5];


  for (int i = 0; i < listOfMatchesSize; i++) {
    float initRedValue = locationsList.get(i).getRedCardX();
    interpolators[i] = new Integrator(initRedValue);
    interpolators[i].attraction = 0.1;

    for (int j = 0; j < locationsList.get(i).getHomeGoalsX().length; j++) {
      float initHomeValue = locationsList.get(i).getHomeGoalsX()[j];
      homeInterpolators[i][j] = new Integrator(initHomeValue);
      homeInterpolators[i][j].attraction = 0.1;
    }

    for (int j = 0; j < locationsList.get(i).getAwayGoalsX().length; j++) {
      float initAwayValue = locationsList.get(i).getAwayGoalsX()[j];
      awayInterpolators[i][j] = new Integrator(initAwayValue);
      awayInterpolators[i][j].attraction = 0.1;
    }
  }
}

void setCurrent() {
  if (!modeSwitchValue) {

    for (int i = 0; i < listOfMatchesSize; i++) {

      interpolators[i].target(locationsList.get(i).getRedCardX());

      for (int j = 0; j < locationsList.get(i).getHomeGoalsX().length; j++) {
        homeInterpolators[i][j].target(locationsList.get(i).getHomeGoalsX()[j]);
      }

      for (int j = 0; j < locationsList.get(i).getAwayGoalsX().length; j++) {
        awayInterpolators[i][j].target(locationsList.get(i).getAwayGoalsX()[j]);
      }
    }
  } else {
    for (int i = 0; i < listOfMatchesSize; i++) {

      interpolators[i].target(specialLocationsList.get(i).getRedCardX());

      for (int j = 0; j < locationsList.get(i).getHomeGoalsX().length; j++) {
        homeInterpolators[i][j].target(specialLocationsList.get(i).getHomeGoalsX()[j]);
      }

      for (int j = 0; j < locationsList.get(i).getAwayGoalsX().length; j++) {
        awayInterpolators[i][j].target(specialLocationsList.get(i).getAwayGoalsX()[j]);
      }
    }
  }
}


void mousePressed() {

  // red cards button

  if (overRect(width - (marginHorizontal/3) - ((int)unit*5)/2, marginVertical*4, (int)unit*5, (int)unit*5)) {
    teamNoRC = !teamNoRC;
  }
  
  // team with red card button
  
  
  // team without red card button
  
}



void draw() {

  background(255);

  updateLocations();
  setCurrent();

  unit = (height - (2*marginVertical)) / (listOfMatchesSize);


  rectMode(CORNER);
  noStroke();

  drawScaleNumbers();

  for (int i = 0; i < listOfMatchesSize; i++) {
    Match tempMatch = listOfMatches.get(i);

    if (i % 2 == 0) {
      fill(lightGrey);
      rect(0, marginVertical + (i*unit), width - marginHorizontal, unit);
    }



    interpolators[i].update();

    // draw red cards

    if (redCards) {
      if (tempMatch.getHomeRedTime() != 0) {
        drawRedCard(i, "home");
        currentRedCardIndicator = "home";
      } else {
        drawRedCard(i, "away");
        currentRedCardIndicator = "away";
      }
    }
    // draw goals

    for (int j = 0; j < listOfMatches.get(i).getHomeGoals().length; j++) {
      if ((currentRedCardIndicator.equals("home") && teamWithRC) || teamNoRC) {
        homeInterpolators[i][j].update();
        drawGoal(i, j, "home");
      }
    }

    for (int j = 0; j < listOfMatches.get(i).getAwayGoals().length; j++) {
      if ((currentRedCardIndicator.equals("away") && teamWithRC) || teamNoRC) {
        awayInterpolators[i][j].update();
        drawGoal(i, j, "away");
      }
    }

    drawScale();
    drawName(i);
  }


  modeSwitch.setSize((int)unit*5, (int)unit*3);
  modeSwitch.setPosition(width - (marginHorizontal/3) - (modeSwitch.getWidth() / 2), marginVertical*3);
  rectMode(CORNER);
  if (redCards) {
    fill(red);
  } else {
    fill(lightRed);
  }
  rect(width - (marginHorizontal/3) - ((int)unit*5)/2, marginVertical*4, (int)unit*5, (int)unit*5);
}


void drawScaleNumbers() {
  if (!modeSwitchValue) {
    stroke(lightGrey);

    strokeWeight(2);
    //line(mapMinutes(45), height - marginVertical - unit/2, mapMinutes(45), height - marginVertical);
    line(mapMinutes(45), marginVertical, mapMinutes(45), height - marginVertical);
    line(mapMinutes(90), marginVertical, mapMinutes(90), height - marginVertical);

    fill(darkGrey);
    textAlign(CENTER, CENTER);
    textSize(unit*2);
    text("0'", marginHorizontal, height - marginVertical + unit*2);
    text("45'", mapMinutes(45), height - marginVertical + unit*2);
    text("90'", mapMinutes(90), height - marginVertical + unit*2);
  }
}

void drawScale() {
  strokeWeight(2);
  //stroke(lightGrey);
  //line(mapMinutes(45), marginVertical, mapMinutes(45), height - marginVertical);
  //line(mapMinutes(90), marginVertical, mapMinutes(90), height - marginVertical);

  // axis

  stroke(darkGrey);  
  line(marginHorizontal, marginVertical, marginHorizontal, height - marginVertical);
  //line(marginHorizontal, marginVertical, width - marginHorizontal, marginVertical);
  line(marginHorizontal, height - marginVertical, width - marginHorizontal, height - marginVertical);



  // toolbar

  rectMode(CORNER);
  noStroke();
  fill(darkGrey);
  rect(width-((2*marginHorizontal)/3), 2*marginVertical, ((2*marginHorizontal)/3), height-4*marginVertical);
}

void drawName(int i) {
  textFont(mediumFont);
  textSize(unit*0.8);
  fill(black);
  textAlign(RIGHT, CENTER);
  text(listOfMatches.get(i).getHomeTeam(), marginHorizontal/2 - (unit/2), marginVertical+(unit/2)+(i*unit));
  textAlign(CENTER, CENTER);
  text(":", marginHorizontal/2, marginVertical+(unit/2)+(i*unit));
  textAlign(LEFT, CENTER);
  text(listOfMatches.get(i).getAwayTeam(), marginHorizontal/2 + (unit/2), marginVertical+(unit/2)+(i*unit));
}

void drawRedCard(int i, String homeOrAway) {
  //float x = mapMinutes(minute);
  float x = interpolators[i].value;
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

void drawGoal(int i, int j, String homeOrAway) {
  float x;

  float y = marginVertical+(i*unit)+unit/2;

  if (homeOrAway.equals("home")) {
    x = homeInterpolators[i][j].value;
    fill(home);
  } else {
    fill(away);
    x = awayInterpolators[i][j].value;
  }
  noStroke();
  ellipse(x, y, unit, unit);
}
