#!/bin/bash

# Database connection
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if an argument is provided
if [[ -z $1 ]]; then
    echo "Please provide an element as an argument."
    exit 0
fi

# Determine if input is a number (atomic number) or text (name/symbol)
if [[ $1 =~ ^[0-9]+$ ]]; then
    CONDITION="e.atomic_number = $1"
elif [[ $1 =~ ^[A-Za-z]{1,2}$ ]]; then
    CONDITION="e.symbol = '$1'"
else
    CONDITION="e.name = '$1'"
fi

# Query to find element information
QUERY="
SELECT 
    e.atomic_number, 
    e.name, 
    e.symbol, 
    t.type, 
    TRIM(TO_CHAR(p.atomic_mass, 'FM9990.999')) AS mass, 
    p.melting_point_celsius, 
    p.boiling_point_celsius
FROM 
    elements e
JOIN 
    properties p ON e.atomic_number = p.atomic_number
JOIN 
    types t ON p.type_id = t.type_id
WHERE 
    $CONDITION
"

# Execute query
RESULT=$($PSQL "$QUERY")

# Check if element exists
if [[ -z $RESULT ]]; then
    echo "I could not find that element in the database."
    exit 0
fi

# Parse result
IFS='|' read -r ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING <<< "$RESULT"

# Output element information
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."




