import controlP5.*;
import java.util.Date;

ControlP5 cp5;

float unit; 
Toggle modeSwitch;

Integrator[] interpolators;
Integrator[][] homeInterpolators, awayInterpolators;

PFont regularFont, mediumFont, boldFont;

boolean modeSwitchValue = false;

boolean redCards = true;
boolean teamWithRC = true;
boolean teamNoRC = true;

String currentRedCardIndicator;

color white, black, darkGrey, lightGrey, red, lightRed, withRC, withRCLight, noRC, noRCLight, blue, darkishGrey;

final float maxMinute = 100;
float marginHorizontal, marginVertical;

float sumOfWithRedUntilRed = 0;
float sumOfNoRedUntilRed = 0;
float sumOfWithRedFulltime = 0;
float sumOfNoRedFulltime = 0;

float sumOfMinutesFromStartUntilRed = 0;
float sumOfMinutesFromRedUntilFulltime = 0;

float percentageGoalsWithRedUntilRed, percentageGoalsNoRedUntilRed, percentageGoalsWithRedFulltime, percentageGoalsNoRedFulltime;
float goalPerMinWithRedUntilRed, goalPerMinNoRedUntilRed, goalPerMinWithRedFulltime, goalPerMinNoRedFulltime;


void setup() {

  // setup the surface

  colorMode(HSB, 360, 100, 100);
  size (1500, 1000);
  surface.setResizable(true);
  smooth();

  // margins

  marginHorizontal = 200;
  marginVertical = 80;

  // colors

  white = color(0, 0, 100);
  black = color(0, 0, 0);
  darkGrey = color(0, 0, 59);
  darkishGrey = color(0, 0, 80);
  lightGrey = color(0, 0, 94);
  red = color(8, 84, 86);
  lightRed = color(8, 44, 86);
  withRC = color(42, 73, 96);
  withRCLight = color(42, 33, 96);
  noRC = color(133, 71, 50);
  noRCLight = color(133, 31, 80);
  blue = color(187, 73, 72);

  // fonts

  regularFont = createFont("Montserrat Regular", 48, true);
  mediumFont = createFont("Montserrat Medium", 48, true);
  boldFont = createFont("Montserrat Bold", 48, true);
  textFont(boldFont);



  cp5 = new ControlP5(this);

  unit = (height - (2*marginVertical)) / (listOfMatchesSize);

  modeSwitch = cp5.addToggle("modeSwitchValue")
    .setCaptionLabel("")
    .setMode(ControlP5.SWITCH)
    .setColorBackground(blue)
    .setColorActive(lightGrey)
    ;

  // init lists in update locations

  loadFileToObjectList();

  updateLocations();

  // set interpolators

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

// draw function

void draw() {
  background(white);

  updateLocations();
  setCurrent();

  unit = (height - (2*marginVertical)) / (listOfMatchesSize);

  rectMode(CORNER);
  noStroke();

  drawScaleNumbers();
  drawButtonsAndTitles();

  for (int i = 0; i < listOfMatchesSize; i++) {
    Match tempMatch = listOfMatches.get(i);
    rectMode(CORNER);
    noStroke();
    if (i % 2 == 0) {
      fill(lightGrey);
      rect(0, marginVertical + (i*unit), width - marginHorizontal, unit);
    }

    int currentRedTime = 0;

    if (tempMatch.getHomeRedTime() != 0) {
      currentRedCardIndicator = "home";
      currentRedTime = tempMatch.getHomeRedTime();
    } else {
      currentRedCardIndicator = "away";
      currentRedTime = tempMatch.getAwayRedTime();
    }

    // popups on matches

    rectMode(CORNER);
    noStroke();

    if (overRect(0, marginVertical + (i*unit), width - marginHorizontal, unit)) {
      if (tempMatch.getResult().equals("H")) {
        if (currentRedCardIndicator.equals("home")) {
          fill(withRCLight);
        } else {
          fill(noRCLight);
        }
      } else if (tempMatch.getResult().equals("A")) {
        if (currentRedCardIndicator.equals("away")) {
          fill(withRCLight);
        } else {
          fill(noRCLight);
        }
      } else {
        fill(darkishGrey);
      }
      rect(0, marginVertical + (i*unit), width - marginHorizontal, unit);
    }

    if (overRect(0, marginVertical + (i*unit), marginHorizontal, unit)) {
      drawPopup(tempMatch.getHomeGoalsCount(), tempMatch.getAwayGoalsCount(), i, tempMatch.getResult());
    }

    interpolators[i].update();

    // draw red cards and popups on red cards

    float currentRedX = interpolators[i].value;

    if (redCards) {
      drawRedCard(i, currentRedCardIndicator);
      if (overRect(currentRedX - unit/2, marginVertical+(i*unit), unit, unit)) {
        drawPopupSmall(currentRedTime, i, currentRedX, lightRed);
      }
    }

    // draw goals

    for (int j = 0; j < listOfMatches.get(i).getHomeGoals().length; j++) {
      homeInterpolators[i][j].update();
      if (currentRedCardIndicator.equals("home") && teamWithRC) {
        fill(withRC);
        drawGoal(i, j, "home");
        if (overCircle(homeInterpolators[i][j].value, marginVertical+(i*unit), unit*1.3)) {
          drawPopupSmall(listOfMatches.get(i).getHomeGoals()[j], i, homeInterpolators[i][j].value, withRC);
        }
      } else if (!currentRedCardIndicator.equals("home") && teamNoRC) {
        fill(noRC);
        drawGoal(i, j, "home");
        if (overCircle(homeInterpolators[i][j].value, marginVertical+(i*unit), unit*1.3)) {
          drawPopupSmall(listOfMatches.get(i).getHomeGoals()[j], i, homeInterpolators[i][j].value, noRC);
        }
      }
    }

    for (int j = 0; j < listOfMatches.get(i).getAwayGoals().length; j++) {
      awayInterpolators[i][j].update();
      if (currentRedCardIndicator.equals("away") && teamWithRC) {
        fill(withRC);
        drawGoal(i, j, "away");
        if (overCircle(awayInterpolators[i][j].value, marginVertical+(i*unit), unit*1.3)) {
          drawPopupSmall(listOfMatches.get(i).getAwayGoals()[j], i, awayInterpolators[i][j].value, withRC);
        }
      } else if (!currentRedCardIndicator.equals("away") && teamNoRC) {
        fill(noRC);
        drawGoal(i, j, "away");
        if (overCircle(awayInterpolators[i][j].value, marginVertical+(i*unit), unit*1.3)) {
          drawPopupSmall(listOfMatches.get(i).getAwayGoals()[j], i, awayInterpolators[i][j].value, noRC);
        }
      }
    }

    drawScale();
    drawName(i);
  }

  drawGraphs();
}

// mouse pressed overriden

void mousePressed() {
  drawGraphs();
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

// set current view

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

void drawGraphs() {
  if (modeSwitchValue) {
    rectMode(CORNER);
    noStroke();
    fill(noRC);
    rect(width/2-goalPerMinNoRedUntilRed*unit*1000, height - marginVertical + unit, goalPerMinNoRedUntilRed*unit*1000, unit*2);
    rect(width/2, height - marginVertical + unit, goalPerMinNoRedFulltime*unit*1000, unit*2);


    fill(withRC);
    rect(width/2-goalPerMinWithRedUntilRed*unit*1000, height - marginVertical + unit*3, goalPerMinWithRedUntilRed*unit*1000, unit*2);
    rect(width/2, height - marginVertical + unit*3, goalPerMinWithRedFulltime*unit*1000, unit*2);

    strokeWeight(2);
    stroke(darkGrey);
    line (width/2, height-marginVertical, width/2, height-marginVertical + unit*5);


    //println("sum", sumOfWithRedUntilRed);
    //println("percentageGoalsWithRedUntilRed", percentageGoalsWithRedUntilRed);
    //println("percentageGoalsWithRedUntilRed", percentageGoalsWithRedFulltime);
    //println("percentageGoalsNoRedUntilRed", percentageGoalsNoRedUntilRed);
    //println("percentageGoalsNoRedUntilRed", percentageGoalsNoRedFulltime);

    //println("goalPerMinWithRedUntilRed", goalPerMinWithRedUntilRed*1000);
    //println("goalPerMinNoRedUntilRed", goalPerMinNoRedUntilRed*1000);
    //println("goalPerMinWithRedFulltime", goalPerMinWithRedFulltime*1000);
    //println("goalPerMinNoRedFulltime", goalPerMinNoRedFulltime*1000);

    if (
      overRect(width/2-goalPerMinNoRedUntilRed*unit*1000, height - marginVertical + unit, goalPerMinNoRedUntilRed*unit*1000, unit*2) ||
      overRect(width/2, height - marginVertical + unit, goalPerMinNoRedFulltime*unit*1000, unit*2) ||
      overRect(width/2-goalPerMinWithRedUntilRed*unit*1000, height - marginVertical + unit*3, goalPerMinWithRedUntilRed*unit*1000, unit*2) ||
      overRect(width/2, height - marginVertical + unit*3, goalPerMinWithRedFulltime*unit*1000, unit*2)
      ) {

      stroke(lightGrey);
      fill(darkGrey);
      strokeWeight(2);
      pushMatrix();
      translate(width/2 - unit*8, height - marginVertical - unit*6);  
      beginShape ();
      vertex (0, 0); // 1
      vertex (unit*16, 0); // 2
      vertex (unit*16, unit*6); // 3
      vertex (unit*9, unit*6); // 4
      vertex (unit*8, unit*7); // 5
      vertex (unit*7, unit*6); // 6
      vertex (0, unit*6); // 7
      vertex (0, 0); // 8
      endShape ();
      popMatrix();

      fill(white);
      textAlign(CENTER, CENTER);
      textFont(boldFont);
      textSize(unit*1.5);
      text("GOSTOTA GOLOV", width/2, height - marginVertical - unit*4);
      textFont(mediumFont);
      textSize(unit*1.2);
      text("[ goli / min ]", width/2, height - marginVertical - unit*2);
    }
  }
}


void drawPopup(int homeScore, int awayScore, int i, String winner) {

  if (winner.equals("H")) {
    if (currentRedCardIndicator.equals("home")) {
      fill(withRCLight);
    } else {
      fill(noRCLight);
    }
  } else if (winner.equals("A")) {
    if (currentRedCardIndicator.equals("away")) {
      fill(withRCLight);
    } else {
      fill(noRCLight);
    }
  } else {
    fill(darkishGrey);
  }

  stroke(lightGrey);
  strokeWeight(2);
  pushMatrix();
  translate(marginHorizontal/2 - unit*2, marginVertical - (unit*2.5) + unit*i);  
  beginShape ();
  vertex (0, 0);
  vertex (unit*4, 0);
  vertex (unit*4, unit*2);
  vertex (unit*2.5, unit*2);
  vertex (unit*2, unit*2.5);
  vertex (unit*1.5, unit*2);
  vertex (0, unit*2);
  vertex (0, 0);
  endShape ();
  popMatrix();

  fill(white);
  textAlign(CENTER, CENTER);
  textFont(boldFont);
  textSize(unit);
  text(String.valueOf(homeScore) + " : " + String.valueOf(awayScore), marginHorizontal/2, marginVertical - (unit*1.7) + unit*i);
}


void drawPopupSmall(int minute, int i, float x, color col) {
  fill(col);
  stroke(lightGrey);
  strokeWeight(2);
  pushMatrix();
  translate(x - unit*2, marginVertical - (unit*2.5) + unit*i);  
  beginShape ();
  vertex (0, 0);
  vertex (unit*4, 0);
  vertex (unit*4, unit*2);
  vertex (unit*2.5, unit*2);
  vertex (unit*2, unit*2.5);
  vertex (unit*1.5, unit*2);
  vertex (0, unit*2);
  vertex (0, 0);
  endShape ();
  popMatrix();

  fill(white);
  textAlign(CENTER, CENTER);
  textFont(boldFont);
  textSize(unit);
  text(String.valueOf(minute)+"'", x, marginVertical - (unit*1.6) + unit*i);
}

void drawButtonsAndTitles() {

  // toolbar

  rectMode(CORNER);
  noStroke();
  fill(darkGrey);
  rect(width-((2*marginHorizontal)/3), 2*marginVertical, ((2*marginHorizontal)/3), height-4*marginVertical);

  // buttons

  textAlign(CENTER, CENTER);
  textFont(boldFont);
  textSize(unit);
  fill(white);
  text("Preklop pogleda", width - (marginHorizontal/3), marginVertical + unit*12);

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

  // title

  fill(black);
  textAlign(CENTER, CENTER);
  textFont(boldFont);
  textSize(unit*2);
  text("Kako rdeči kartoni vplivajo na gole?", width/2, marginVertical/2);

  fill(darkGrey);
  //textAlign(RIGHT, CENTER);
  textAlign(CENTER, CENTER);
  textFont(boldFont);
  textSize(unit*1.5);
  //text("TEKME", marginHorizontal - 2*unit, marginVertical - unit*2);
  text("TEKME", marginHorizontal/2, marginVertical - unit*2);

  textAlign(LEFT, CENTER);
  text("GOLI IN RK", marginHorizontal + 3*unit, marginVertical - unit*3);
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
  stroke(darkGrey);  
  line(marginHorizontal, marginVertical - unit*3, marginHorizontal, height - marginVertical);

  line(marginHorizontal/2 + unit*4, marginVertical - unit*2, marginHorizontal, marginVertical - unit*2);
  line(marginHorizontal + unit*2, marginVertical - unit*3, marginHorizontal, marginVertical - unit*3);

  line(marginHorizontal, height - marginVertical, width - marginHorizontal, height - marginVertical);
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

// drawing elements

void drawRedCard(int i, String homeOrAway) {
  float x = interpolators[i].value;
  float y = marginVertical+(i*unit)+unit/2;

  stroke(darkGrey);
  strokeWeight(1);

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
