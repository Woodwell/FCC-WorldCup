#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

if [[ $($PSQL "TRUNCATE TABLE games, teams") != 'TRUNCATE TABLE' ]]
then
   echo 'problem truncating table'; exit;
fi

# this function does the hard work of ensuring that the teams are in the team table in the db.  id is on stdout.  return val indicates success/failure
function get_team_id() {
  team=$1;
  __resultvar=$2;
  team_id=$($PSQL "SELECT team_id from teams WHERE NAME='$team'")
  if [[ -z $team_id ]]
  then
    if [[ $($PSQL "INSERT INTO teams(name) VALUES('$team')") == "INSERT 0 1" ]]
    then
      team_id=$($PSQL "SELECT team_id from teams WHERE NAME='$team'")
    else
      return -1
    fi
  fi
  eval $__resultvar="'$team_id'";
  return 0;
}

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR == year ]]
  then
    # skip the first line
    continue
  fi
  get_team_id "$WINNER" WINNER_ID;
  get_team_id "$OPPONENT" OPPONENT_ID;
  echo "inserting" $YEAR $ROUND $WINNER_ID $OPPONENT_ID $WINNER_GOALS $OPPONENT_GOALS
  result=$($PSQL "INSERT INTO games(year, round, winner_goals, opponent_goals, winner_id, opponent_id) VALUES('$YEAR', '$ROUND', '$WINNER_GOALS', '$OPPONENT_GOALS','$WINNER_ID','$OPPONENT_ID')")
  
done
