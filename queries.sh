#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=worldcup --no-align --tuples-only -c"

# Do not change code above this line. Use the PSQL variable above to query your database.

echo -e "\nTotal number of goals in all games from winning teams:"
echo "$($PSQL "SELECT SUM(winner_goals) FROM games")"

echo -e "\nTotal number of goals in all games from both teams combined:"
echo "$($PSQL "SELECT SUM(WINNER_GOALS + OPPONENT_GOALS) FROM GAMES")"

echo -e "\nAverage number of goals in all games from the winning teams:"
echo "$($PSQL "SELECT AVG(WINNER_GOALS) FROM GAMES")"

echo -e "\nAverage number of goals in all games from the winning teams rounded to two decimal places:"
echo "$($PSQL "SELECT ROUND(AVG(WINNER_GOALS),2) FROM GAMES")"

echo -e "\nAverage number of goals in all games from both teams:"
echo "$($PSQL "SELECT AVG(WINNER_GOALS + OPPONENT_GOALS) FROM GAMES")"

echo -e "\nMost goals scored in a single game by one team:"
echo "$($PSQL "SELECT MAX(WINNER_GOALS) FROM GAMES")"

echo -e "\nNumber of games where the winning team scored more than two goals:"
echo "$($PSQL "SELECT COUNT(*) FROM GAMES WHERE WINNER_GOALS > 2")"

echo -e "\nWinner of the 2018 tournament team name:"
echo "$($PSQL "SELECT name from games join teams on winner_id = team_id where year = 2018 and round = 'Final'")"

echo -e "\nList of teams who played in the 2014 'Eighth-Final' round:"
echo "$($PSQL "select name from teams where team_id in (select winner_id from games where year=2014 and round='Eighth-Final') or team_id in (select opponent_id from games where year=2014 and round='Eighth-Final') order by name")"

echo -e "\nList of unique winning team names in the whole data set:"
echo "$($PSQL "SELECT DISTINCT(NAME) from teams where team_id in (select winner_id from games)")"

echo -e "\nYear and team name of all the champions:"
echo "$($PSQL "select g.year, name from games as g inner join teams as W on W.team_id = g.winner_id where g.Round='Final' order by year")"

echo -e "\nList of teams that start with 'Co':"
echo "$($PSQL "SELECT NAME from teams where name like 'Co%'")"
