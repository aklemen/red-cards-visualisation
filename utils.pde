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
  }
  
  listOfMatchesSize = listOfMatches.size();
  
}

// maps minutes to fit in graph

float mapMinutes(float minute) {
  return map(minute, 0, maxMinute, marginHorizontal, (width/2));
}

// checks if mouse is over rectangle

boolean overRect(float x, float y, float width, float height) {
  if (mouseX >= x && mouseX <= x+width && 
    mouseY >= y && mouseY <= y+height) {
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
