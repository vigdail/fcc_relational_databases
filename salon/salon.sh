#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  SERVICE_LIST=$($PSQL "SELECT * FROM services")
  echo "$SERVICE_LIST" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Thats not a corrent service number."
  else
    SERVICE_EXISTS=$($PSQL "
      SELECT count(*) FROM services
      WHERE service_id = $SERVICE_ID_SELECTED
    ")
    if [[ $SERVICE_EXISTS -ne 1 ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      APPOINT_SERVICE $SERVICE_ID_SELECTED
    fi
  fi
}

APPOINT_SERVICE() {
  GET_CUSTOMER_ID
  CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')
  echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
  read SERVICE_TIME
  
  INSERT_APPOINTMENT_RESULT=$($PSQL "
    INSERT INTO appointments (customer_id, service_id, time)
    VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')
  ")
  if [[ $INSERT_APPOINTMENT_RESULT != "INSERT 0 1" ]]
  then
    MAIN_MENU "error creating appoinment."
  else 
    SELECTED_SERVICE_NAME=$($PSQL "
      SELECT name FROM services
      WHERE
        service_id = $SERVICE_ID_SELECTED
    ")
    SELECTED_SERVICE_NAME=$(echo $SELECTED_SERVICE_NAME | sed -E 's/^ *| *$//g')
    echo -e "\nI have put you down for a $SELECTED_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi

}

GET_CUSTOMER_ID() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "
    SELECT name FROM customers
    WHERE phone = '$CUSTOMER_PHONE'
  ")
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "
      INSERT INTO customers (name, phone)
      VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')
    ")
  fi
  CUSTOMER_ID=$($PSQL "
    SELECT customer_id FROM customers
    WHERE
      phone = '$CUSTOMER_PHONE'
  ")
}

MAIN_MENU
