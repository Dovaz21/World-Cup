#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    # get team_id winner
    TEAM_ID_W=$($PSQL "SELECT team_id FROM teams WHERE name ='$WINNER'")

    # if not found winner
    if [[ -z $TEAM_ID_W ]]
    then
      # insert winner
      INSERT_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER winner.
      fi
      TEAM_ID_W=$($PSQL "SELECT team_id FROM teams WHERE name ='$WINNER'")
    fi

    # get team_id opponent
    TEAM_ID_O=$($PSQL "SELECT team_id FROM teams WHERE name ='$OPPONENT'")

    # if not found opponent
    if [[ -z $TEAM_ID_O ]]
    then
      # insert opponent
      INSERT_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $OPPONENT opponent.
      fi
      TEAM_ID_O=$($PSQL "SELECT team_id FROM teams WHERE name ='$OPPONENT'")
    fi

    # -----------------------------------------------------------------------

    # get game_id
    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE winner_id='$TEAM_ID_W' AND opponent_id='$TEAM_ID_O'")

    # insert game
    INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $TEAM_ID_W, $TEAM_ID_O, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAME == "INSERT 0 1" ]]
    then
      echo "Inserted into games, ($YEAR, $ROUND, $TEAM_ID_W, $TEAM_ID_O, $WINNER_GOALS, $OPPONENT_GOALS)"
    fi
  fi
done
