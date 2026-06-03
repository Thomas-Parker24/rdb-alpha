#! /bin/bash
PSQL="psql --username=postgres --dbname=salon -t --no-align -c"

function MAIN_MENU(){

if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

SERVICES_RESULT=$($PSQL "SELECT service_id, name FROM services")
declare -A SERVICES_ARRAY

while IFS="|" read -r ID NAME 
do
  echo "$ID) $NAME"
  SERVICES_ARRAY["$ID"]=$NAME
done <<< "$SERVICES_RESULT"

read SERVICE_ID_SELECTED

if [[ ! -v SERVICES_ARRAY[$SERVICE_ID_SELECTED] ]]
then
  MAIN_MENU "I could not find that service. What would you like today?"
  return
fi

echo "Ingrese el teléfono"
read CUSTOMER_PHONE
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers where Phone = '$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_NAME ]]
then
  echo "Ingrese el nombre"
  read CUSTOMER_NAME

  INSERT_RESULT=$($PSQL "INSERT INTO customers (name, phone) values ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")

  if [[ $INSERT_RESULT == "INSERT 0 1" ]]
  then
    echo "Cliente creado..." 
  fi 
fi

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers where Phone = '$CUSTOMER_PHONE'")

echo "Hora"
read SERVICE_TIME

echo "Guardando servicio..."
INSERT_SERVICE_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

SELECTED_SERVICE_NAME=${SERVICES_ARRAY[$SERVICE_ID_SELECTED]}
echo "I have put you down for a $SELECTED_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU