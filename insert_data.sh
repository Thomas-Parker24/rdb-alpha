#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

TRUNCATE_TABLES_RESULT=$($PSQL "TRUNCATE TABLE TEAMS, GAMES;")
echo $TRUNCATE_TABLES_RESULT

#Read games.csv file 

declare -A TEAMS
while IFS=, read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  
  if [[ $YEAR == "year" ]]
  then
    continue
  fi

  if [[ ! -v TEAMS[$WINNER] ]]
  then
    TEAMS[$WINNER]=1
  fi

  if [[ ! -v TEAMS[$OPPONENT] ]] 
  then 
    TEAMS[$OPPONENT]=1
  fi
done < ./games.csv

TEAMS_COUNT=${#TEAMS[@]}
echo "Cantidad de equipos: $TEAMS_COUNT"

echo "Agregando equipos a la base de datos...";

INSERT_TEAMS_QUERY="INSERT INTO teams (name) VALUES "  
for TEAM_NAME in "${!TEAMS[@]}"
do
  INSERT_TEAMS_QUERY+="('$TEAM_NAME'),"
done

INSERT_TEAMS_QUERY="${INSERT_TEAMS_QUERY%?}"
INSERT_TEAMS_QUERY+=";"
INSERT_TEAMS_RESULT=$($PSQL "$INSERT_TEAMS_QUERY")

if [[ $INSERT_TEAMS_RESULT == "INSERT 0 24" ]]
then
  echo "Equipos agregados exitosamente."
fi 

echo "Consultando id de los equipos..."
TEAMS_ID_QUERY_RESULT=$($PSQL "SELECT team_id, name FROM teams")

declare -A TEAMS_ID_ARRAY
while IFS="|" read -r ID NAME 
do
  TEAMS_ID_ARRAY["$NAME"]=$ID
done <<< "$TEAMS_ID_QUERY_RESULT"

INSERT_GAMES_QUERY="INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES"

while IFS=, read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do  
  if [[ $YEAR == "year" ]]
  then
    continue
  fi

  WINNER_ID=${TEAMS_ID_ARRAY[$WINNER]}
  OPPONENT_ID=${TEAMS_ID_ARRAY[$OPPONENT]}
  INSERT_GAMES_QUERY+="($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS),"

done < ./games.csv

INSERT_GAMES_QUERY="${INSERT_GAMES_QUERY%?}"
INSERT_GAMES_RESULT=$($PSQL "$INSERT_GAMES_QUERY")

if [[ $INSERT_GAMES_RESULT == "INSERT 0 32" ]]
then
  echo "Juegos agregados exitosamente."
fi
