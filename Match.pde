class Match {
  String date;
  String homeTeam;
  String awayTeam;
  int homeRedTime;
  int awayRedTime;
  String result;
  int homeGoalsCount;
  int[] homeGoals;
  int awayGoalsCount;
  int[] awayGoals;
 
  Match( String date, String homeTeam, String awayTeam, int homeRedTime, int awayRedTime, String result, int homeGoalsCount, int[] homeGoals, int awayGoalsCount, int[] awayGoals){
    this.date = date;
    this.homeTeam = homeTeam;
    this.awayTeam = awayTeam;
    this.homeRedTime = homeRedTime;
    this.awayRedTime = awayRedTime;
    this.result = result;
    this.homeGoalsCount = homeGoalsCount;
    this.homeGoals = homeGoals;
    this.awayGoalsCount = awayGoalsCount;
    this.awayGoals = awayGoals;
  }
  
  String getDate(){
    return date;
  }
  
  String getHomeTeam(){
    return homeTeam;
  }
  
  String getAwayTeam(){
    return awayTeam;
  }
  
  int getHomeRedTime(){
    return homeRedTime;
  }
  
  int getAwayRedTime(){
    return awayRedTime;
  }
  
  String getResult(){
    return result;
  }
  
  int getHomeGoalsCount(){
    return homeGoalsCount;
  }
  
  int[] getHomeGoals(){
    return homeGoals;
  }
  
  int getAwayGoalsCount(){
    return awayGoalsCount;
  }
  
  int[] getAwayGoals(){
    return awayGoals;
  }
  
}
