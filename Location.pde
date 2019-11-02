class Location {
  int redCard;
  int[] homeGoals;
  int[] awayGoals;
 
  Location(int redCard, int[] homeGoals, int[] awayGoals){
    this.redCard = redCard;
    this.homeGoals = homeGoals;
    this.awayGoals = awayGoals;
  }
  
  int getRedCard(){
    return redCard;
  }
  
  int[] getHomeGoals(){
    return homeGoals;
  }
  
  int[] getAwayGoals(){
    return awayGoals;
  }
  
}
