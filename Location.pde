class Location {
  float redCardX;
  float[] homeGoalsX;
  float[] awayGoalsX;

  Location(float redCardX, float[] homeGoalsX, float[] awayGoalsX) {
    this.redCardX = redCardX;
    this.homeGoalsX = homeGoalsX;
    this.awayGoalsX = awayGoalsX;
  }

  float getRedCardX() {
    return redCardX;
  }

  float[] getHomeGoalsX() {
    return homeGoalsX;
  }

  float[] getAwayGoalsX() {
    return awayGoalsX;
  }

  void setRedCardX(float redCardX) {
    this.redCardX = redCardX;
  }

  void setHomeGoalsX(float[] homeGoalsX) {
    this.homeGoalsX = homeGoalsX;
  }

  void setAwayGoalsX(float[] awayGoalsX) {
    this.awayGoalsX = awayGoalsX;
  }
}
