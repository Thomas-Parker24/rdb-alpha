#!/bin/bash

guess_number(){
  read GUESS
  INTENT=$(( $2 + 1 ))

  if [[ ! "$GUESS" =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    guess_number $1 $INTENT
  elif [[ $GUESS -gt $1 ]]; then
    echo "It's lower than that, guess again:"
    guess_number $1 $INTENT
  elif [[ $GUESS -lt $1 ]]; then
    echo "It's higher than that, guess again:"
    guess_number $1 $INTENT
  else
    echo "You guessed it in $INTENT tries. The secret number was $1. Nice job!"
    return
  fi

} 

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo "Enter your username:"
read USER
LENGTH=${#USER}

if [[ $LENGTH -lt 22 ]]
then  
  NUMBER=$(( ($RANDOM % 1000) + 1 ))
  USER_DATA=$($PSQL "SELECT u.user_id, u.name, COUNT(g.user_id) AS total_games, MIN(g.intents) AS best_game  FROM users AS u  JOIN games AS g USING(user_id)  WHERE u.name = '$USER' GROUP BY u.user_id, u.name;")

  if [[ -z $USER_DATA ]]
  then
    INSERT_RESULT=$($PSQL "INSERT INTO users (name) values ('$USER')")
    echo "Welcome, $USER! It looks like this is your first time here."
  else
    echo "$USER_DATA" | while IFS="|" read USERID NAME GAMES_PLAYED BEST_GAME
    do 
      echo "Welcome back, $USER! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    done
  fi

  USER_ID=$($PSQL "SELECT user_id from users where name = '$USER'")
  echo "Guess the secret number between 1 and 1000:"
  guess_number $NUMBER 0
  INSERT_RESULT=$($PSQL "INSERT INTO GAMES (user_id, intents) values ($USER_ID, $INTENT)")
else
  echo "Higher than 22"
  
fi


