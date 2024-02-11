#!/bin/bash
echo -e "\n\n~~~~~ MY SALON ~~~~~\n\n"

PSQL="psql --username=postgres --dbname=salon -t --no-align -c"

echo -e "Welcome to My Salon, how can I help you?"

StartSalon(){
  echo -e "\n${1}"
  SERVICES=$($PSQL "SELECT * FROM services")
  echo -e "$(echo "$SERVICES" | sed 's/|/) /g')"
  read SERVICE_ID_SELECTED
  SERVICE_EXIST=$($PSQL "SELECT * FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
  if [[ -z $SERVICE_EXIST ]]
  then
    StartSalon "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_EXISTS=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_EXISTS ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
    fi
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
    read SERVICE_TIME
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    SCHEDULE=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES('$CUSTOMER_ID','$SERVICE_ID_SELECTED','$SERVICE_TIME')")
    if [[ $SCHEDULE == "INSERT 0 1" ]]
    then
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}
StartSalon;
