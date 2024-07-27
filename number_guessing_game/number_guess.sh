#!/bin/bash

echo "Enter your username:"
read USER_NAME

PSQL="psql -U freecodecamp --db=number_guess --tuples-only -c"

SELECT_USER_RESULT=$($PSQL "
  SELECT games_played, best_game FROM users
  WHERE name = '$USER_NAME'
")

if [[ $SELECT_USER_RESULT ]]
then
  echo "$SELECT_USER_RESULT" | while read GAMES_PLAYED BAR BEST_GAME 
  do
    echo $BEST_GAME
    echo "Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
else
  echo "Welcome, $USER_NAME! It looks like this is your first time here."
  GAMES_PLAYED=0
fi

SECRET_NUMBER=$(($RANDOM % 1000 + 1))

echo "Guess the secret number between 1 and 1000:"
NUMBER_OF_GUESSES=0
while [[ $GUESS != $SECRET_NUMBER ]]
do
  NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES+1))
  read GUESS
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  fi
done

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

if [[ $BEST_GAME ]]
then
  if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
  then
    NUMBER_OF_GUESSES=$BEST_GAME
  fi
else
  BEST_GAME=$NUMBER_OF_GUESSES
fi
GAMES_PLAYED=$(($GAMES_PLAYED+1))

UPDATE_RESULT=$($PSQL "
  INSERT INTO users (name, games_played, best_game)
  VALUES ('$USER_NAME', $GAMES_PLAYED, $BEST_GAME)
  ON CONFLICT(name)
  DO
  UPDATE
  SET games_played = $GAMES_PLAYED, best_game = $BEST_GAME
")
