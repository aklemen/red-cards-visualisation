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

color white, black, darkGrey, lightGrey, red, lightRed, withRC, withRCLight, noRC, noRCLight, blue;

void setup() {

  // setup the surface

  colorMode(HSB, 360, 100, 100);
  


//color withRC = color(245, 190, 65);
//color withRCLight = color(99,92,76);
//color noRC = color(37,128,57);
//color noRCLight = color(88,96,90);
//color blue = color(49,169,184);

  white = color(0, 0, 100);
  black = color(0, 0, 0);
  darkGrey = color(0, 0, 59);
  lightGrey = color(0, 0, 94);
  red = color(8, 84, 86);
  lightRed = color(8, 44, 86);
  withRC = color(42, 73, 96);
  withRCLight = color(42, 33, 96);
  noRC = color(133, 71, 50);
  noRCLight = color(133, 31, 60);
  blue = color(187, 73, 72);

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
    .setColorBackground(blue)
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




void draw() {
  background(white);

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


    if (tempMatch.getHomeRedTime() != 0) {
      if (redCards) {
        drawRedCard(i, "home");
      }
      currentRedCardIndicator = "home";
    } else {
      if (redCards) {
        drawRedCard(i, "away");
      }
      currentRedCardIndicator = "away";
    }

    // draw goals

    for (int j = 0; j < listOfMatches.get(i).getHomeGoals().length; j++) {
      homeInterpolators[i][j].update();
      if (currentRedCardIndicator.equals("home") && teamWithRC) {
        fill(withRC);
        drawGoal(i, j, "home");
      } else if (!currentRedCardIndicator.equals("home") && teamNoRC) {
        fill(noRC);
        drawGoal(i, j, "home");
      }
    }

    for (int j = 0; j < listOfMatches.get(i).getAwayGoals().length; j++) {
      awayInterpolators[i][j].update();
      if (currentRedCardIndicator.equals("away") && teamWithRC) {
        fill(withRC);
        drawGoal(i, j, "away");
      } else if (!currentRedCardIndicator.equals("away") && teamNoRC) {
        fill(noRC);
        drawGoal(i, j, "away");
      }
    }

    drawScale();
    drawName(i);
  }



  textAlign(CENTER, CENTER);
  textFont(boldFont);
  textSize(unit);
  fill(white);
  text("Preklop načina", width - (marginHorizontal/3), marginVertical + unit*12);

  modeSwitch.setSize((int)unit*5, (int)unit*3);
  modeSwitch.setPosition(width - (marginHorizontal/3) - (modeSwitch.getWidth() / 2), marginVertical + unit*14);



  fill(white);
  text("Rdeči kartoni", width - (marginHorizontal/3), marginVertical + unit*29);

  rectMode(CORNER);
  if (redCards) {
    fill(red);
  } else {
    fill(lightRed);
  }
  rect(width - (marginHorizontal/3) - ((int)unit*5)/2, marginVertical + unit*31, (int)unit*5, (int)unit*5, unit/2);




  fill(white);
  text("Goli ekipe brez RK", width - (marginHorizontal/3), marginVertical + unit*41);

  if (teamNoRC) {
    fill(noRC);
  } else {
    fill(noRCLight);
  }
  //ellipse(width - (marginHorizontal/3) - ((int)unit*5)/2, marginVertical + unit*43, (int)unit*5, (int)unit*5);
  ellipse(width - (marginHorizontal/3), marginVertical + unit*45.5, (int)unit*5.5, (int)unit*5.5);




  fill(white);
  text("Goli ekipe z RK", width - (marginHorizontal/3), marginVertical + unit*53);

  if (teamWithRC) {
    fill(withRC);
  } else {
    fill(withRCLight);
  }
  ellipse(width - (marginHorizontal/3), marginVertical + unit*57.5, (int)unit*5.5, (int)unit*5.5);
}

void mousePressed() {

  // red cards button

  if (overRect(width - (marginHorizontal/3) - ((int)unit*5)/2, marginVertical + unit*31, (int)unit*5, (int)unit*5)) {
    redCards = !redCards;
  }

  // team without red card button

  if (overCircle(width - (marginHorizontal/3), marginVertical + unit*45.5, unit*5.5)) {
    teamNoRC = !teamNoRC;
  }

  // team with red card button

  if (overCircle(width - (marginHorizontal/3), marginVertical + unit*57.5, unit*5.5)) {
    teamWithRC = !teamWithRC;
  }
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
    textFont(mediumFont);
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
  textSize(unit*0.7);
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
  
  stroke(darkGrey);
  strokeWeight(1);

  //if (homeOrAway.equals("home")) {
  //  stroke(black);
  //} else {
  //  stroke(blue);
  //}

  fill(red);
  rectMode(CENTER);
  rect(x, y, unit, unit, unit/5);
}

void drawGoal(int i, int j, String homeOrAway) {
  float x;

  float y = marginVertical+(i*unit)+unit/2;

  if (homeOrAway.equals("home")) {
    x = homeInterpolators[i][j].value;
  } else {
    x = awayInterpolators[i][j].value;
  }
  noStroke();
  ellipse(x, y, unit, unit);
}
