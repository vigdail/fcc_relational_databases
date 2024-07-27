if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit 0
fi

PSQL="psql -U freecodecamp --db=periodic_table --tuples-only -c"

if [[ $1 =~ ^[0-9]+$ ]]
then
  WHERE="atomic_number = $1"
else
  WHERE="symbol = '$1' OR name = '$1'"
fi

SELECT_RESULT=$($PSQL "
  SELECT atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type
   FROM elements
  INNER JOIN properties USING(atomic_number)
  INNER JOIN types USING(type_id)
  WHERE $WHERE
")
if [[ -z $SELECT_RESULT ]]
then
  echo "I could not find that element in the database."
  exit 0
fi
echo $SELECT_RESULT | while read ATOMIC_NUMBER BAR SYMBOL BAR NAME BAR ATOMIC_MASS BAR MELTING_POINT BAR BOILING_POINT BAR TYPE
do
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
done
