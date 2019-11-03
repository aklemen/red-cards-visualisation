// reading the file and adding to list

ArrayList<Match> listOfMatches = new ArrayList();
int listOfMatchesSize;

void loadFileToObjectList() {

  Table matchesTable = loadTable("tekme.csv", "header"); 

  for (TableRow row : matchesTable.rows()) {

    int[] homeGoals = new int[]{row.getInt("Home1"), row.getInt("Home2"), row.getInt("Home3"), row.getInt("Home4"), row.getInt("Home5")};
    homeGoals = removeZeros(homeGoals);
    int[] awayGoals = new int[]{row.getInt("Away1"), row.getInt("Away2"), row.getInt("Away3"), row.getInt("Away4"), row.getInt("Away5")};
    awayGoals = removeZeros(awayGoals);

    Match tempMatch = new Match(row.getString("Date"), row.getString("HomeTeam"), row.getString("AwayTeam"), row.getInt("HomeRedTime"), row.getInt("AwayRedTime"), row.getString("Result"), row.getInt("HomeGoals"), homeGoals, row.getInt("AwayGoals"), awayGoals);

    listOfMatches.add(tempMatch);

    int currentRedTimeHere = 0;
    String currentRedCardIndicatorHere;
    

    if (tempMatch.getHomeRedTime() != 0) {
      currentRedTimeHere = tempMatch.getHomeRedTime();
      currentRedCardIndicatorHere = "home";
    } else {
      currentRedTimeHere = tempMatch.getAwayRedTime();
      currentRedCardIndicatorHere = "away";
    }
    
    sumOfMinutesFromStartUntilRed += currentRedTimeHere;

    int[] tempGoals;

    if (tempMatch.getHomeGoals().length > 0) {
      tempGoals = tempMatch.getHomeGoals();
      for (int j = 0; j < tempGoals.length; j++) {
        if (tempGoals[j] < currentRedTimeHere) {
          if (currentRedCardIndicatorHere.equals("home")) {
            sumOfWithRedUntilRed++;
          } else {
            sumOfNoRedUntilRed++;
          }
        } else {
          if (currentRedCardIndicatorHere.equals("home")) {
            sumOfWithRedFulltime++;
          } else {
            sumOfNoRedFulltime++;
          }
        }
      }
    }

    if (tempMatch.getAwayGoals().length > 0) {
      tempGoals = tempMatch.getAwayGoals();
      for (int j = 0; j < tempGoals.length; j++) {
        if (tempGoals[j] < currentRedTimeHere) {
          if (currentRedCardIndicatorHere.equals("away")) {
            sumOfWithRedUntilRed++;
          } else {
            sumOfNoRedUntilRed++;
          }
        } else {
          if (currentRedCardIndicatorHere.equals("away")) {
            sumOfWithRedFulltime++;
          } else {
            sumOfNoRedFulltime++;
          }
        }
      }
    }
  }

  listOfMatchesSize = listOfMatches.size();
  
  sumOfMinutesFromRedUntilFulltime = maxMinute*listOfMatchesSize - sumOfMinutesFromStartUntilRed;

  percentageGoalsWithRedUntilRed = Math.round(sumOfWithRedUntilRed*100 / (sumOfWithRedUntilRed + sumOfWithRedFulltime));
  percentageGoalsNoRedUntilRed = Math.round(sumOfNoRedUntilRed*100 / (sumOfNoRedUntilRed + sumOfNoRedFulltime));
  percentageGoalsWithRedFulltime = Math.round(sumOfWithRedFulltime*100 / (sumOfWithRedUntilRed + sumOfWithRedFulltime));
  percentageGoalsNoRedFulltime = Math.round(sumOfNoRedFulltime*100 / (sumOfNoRedUntilRed + sumOfNoRedFulltime));
  
  goalPerMinWithRedUntilRed = sumOfWithRedUntilRed / sumOfMinutesFromStartUntilRed;
  goalPerMinNoRedUntilRed = sumOfNoRedUntilRed / sumOfMinutesFromStartUntilRed;
  goalPerMinWithRedFulltime = sumOfWithRedFulltime / sumOfMinutesFromRedUntilFulltime;
  goalPerMinNoRedFulltime = sumOfNoRedFulltime / sumOfMinutesFromRedUntilFulltime;
  
  
}

ArrayList<Location> locationsList = new ArrayList();
float redCardX;
float redCard;
float[] homeGoalsX = new float[5];
float[] awayGoalsX = new float[5];
;

ArrayList<Location> specialLocationsList = new ArrayList();
float specialRedCardX;
float redCardDifferenceX;
float[] specialHomeGoalsX = new float[5];
float[] specialAwayGoalsX = new float[5];

float halfX;

void updateLocations() {

  locationsList.clear();
  specialLocationsList.clear();

  for (int i = 0; i < listOfMatchesSize; i++) {

    Match tempMatch = listOfMatches.get(i);

    // red cards

    if (tempMatch.getHomeRedTime() != 0) {
      redCard = tempMatch.getHomeRedTime();
      redCardX = mapMinutes(redCard);
      //redCardDifferenceMinutes = 45 - tempMatch.getHomeRedTime();
    } else {
      redCard = tempMatch.getAwayRedTime();
      redCardX = mapMinutes(redCard);
      //redCardDifferenceMinutes = 45 - tempMatch.getAwayRedTime();
    }

    specialRedCardX = mapMinutesOnHalf(redCard);

    halfX = mapMinutes(maxMinute/2);

    redCardDifferenceX = halfX - specialRedCardX;

    specialRedCardX = mapMinutesOnHalf(redCard) + redCardDifferenceX;

    int[] tempGoals;

    if (tempMatch.getHomeGoals().length > 0) {
      tempGoals = tempMatch.getHomeGoals();
      homeGoalsX = new float[tempGoals.length];
      specialHomeGoalsX = new float[tempGoals.length];
      for (int j = 0; j < tempGoals.length; j++) {
        homeGoalsX[j] = mapMinutes((float)tempGoals[j]);
        specialHomeGoalsX[j] = mapMinutesOnHalf((float)tempGoals[j]) + redCardDifferenceX;
      }
    }

    if (tempMatch.getAwayGoals().length > 0) {
      tempGoals = tempMatch.getAwayGoals();
      awayGoalsX = new float[tempGoals.length];
      specialAwayGoalsX = new float[tempGoals.length];
      for (int j = 0; j < tempGoals.length; j++) {
        awayGoalsX[j] = mapMinutes((float)tempGoals[j]);
        specialAwayGoalsX[j] = mapMinutesOnHalf((float)tempGoals[j]) + redCardDifferenceX;
      }
    }

    Location tempLocation = new Location(redCardX, homeGoalsX, awayGoalsX);

    Location tempSpecialLocation = new Location(specialRedCardX, specialHomeGoalsX, specialAwayGoalsX);

    locationsList.add(i, tempLocation);
    specialLocationsList.add(i, tempSpecialLocation);
  }
}


// maps minutes to fit in graph

float mapMinutes(float minute) {
  return map(minute, 0, maxMinute, marginHorizontal, width - marginHorizontal);
}

//TODO preglej, če je to ok glede postavitve
float mapMinutesOnHalf(float minute) {
  return map(minute, 0, maxMinute, marginHorizontal, mapMinutes(maxMinute/2));
}

// checks if mouse is over rectangle or circle

boolean overRect(float x, float y, float width, float height) {
  if (mouseX >= x && mouseX <= x+width && 
    mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

boolean overCircle(float x, float y, float diameter) {
  float disX = x - mouseX;
  float disY = y - mouseY;
  if (sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
    return true;
  } else {
    return false;
  }
}

// removes zeros from int array

int[] removeZeros(int[] array) {
  int n = 0;
  for (int i = 0; i < array.length; i++) {
    if (array[i] != 0)
      n++;
  }

  int[] newArray = new int[n];
  int j=0;

  for (int i = 0; i < array.length; i++) {
    if (array[i] != 0)
    { 
      newArray[j]=array[i]; 
      j++;
    }
  }

  return newArray;
}
