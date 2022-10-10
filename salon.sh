#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo-e "\n~~~Welcome to the FCC Salon~~~\n"

MAIN_MENU(){
  
  if [[ $1 ]]
  then
    echo -e "\n!! $1 !!\n"
  fi

  echo "How may I help you?" 

  SERVICES=$($PSQL "select service_id, name from services order by service_id")
 
  echo "$SERVICES" | sed 's/|/) /'

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Please enter a number (0-9)"
  else
    SERVICE_ID_SELECTED=$($PSQL "select service_id from services where service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_ID_SELECTED ]] 
    then
      MAIN_MENU "Please enter one of the displayed numbers"
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUST_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE' ")
      CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE' ")
      if [[ -z $CUST_ID ]]
      then
        echo -e "\nNew customer! What is your name?"
        read CUSTOMER_NAME
        NEW_CUST=$($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE') ") 
        CUST_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE' ")
      fi # end -z cust id
      
      SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")

      echo -e "\nWhat time would you like your service, $CUSTOMER_NAME"
      read SERVICE_TIME

      APPOINT=$($PSQL "insert into appointments(time, customer_id, service_id) values('$SERVICE_TIME', $CUST_ID, $SERVICE_ID_SELECTED) " )

      if [[ $APPOINT = "INSERT 0 1" ]]
      then
        echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      else
        echo "error, closing"
      fi

    fi # end -z service_id_selected

  fi # end ! service_ID_selected

}

EXIT () {
  echo -e "\nExiting... Thanks for stopping by!\n"
}

MAIN_MENU