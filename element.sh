PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else

if [[ $1 =~ ^[0-9]+$ ]]
then
  DATA=$($PSQL "select e.atomic_number, e.symbol, e.name, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius from elements as e join properties as p on p.atomic_number = e.atomic_number join types as t on t.type_id = p.type_id where e.atomic_number = $1")
elif [[ ${#1} -le 2 ]]; then
  DATA=$($PSQL "select e.atomic_number, e.symbol, e.name, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius from elements as e join properties as p on p.atomic_number = e.atomic_number join types as t on t.type_id = p.type_id where e.symbol = '$1'")
else
  DATA=$($PSQL "select e.atomic_number, e.symbol, e.name, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius from elements as e join properties as p on p.atomic_number = e.atomic_number join types as t on t.type_id = p.type_id where e.name = '$1'")
fi

if [[ -z $DATA ]] 
then
  echo "I could not find that element in the database."
else
  echo $DATA | while IFS="|" read ATOMIC_NUMBER SYMBOL NAME TYPE MASS MELTING_POINT BOILING_POINT
  do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  done
fi
fi
