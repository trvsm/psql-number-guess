#!/bin/bash
#psql variable to enter one command then exit
PSQL="psql --username=freecodecamp --dbname=number_game -t --no-align -c"\

#generate random number
SECRET=$((1+RANDOM%1000))

#ask for username then read input
echo "Enter your username:"
read USERNAME

#is user in database?
PREV_USER=$($PSQL "SELECT * FROM records WHERE name='$USERNAME'")
#if existing username show previous stats
if [ $PREV_USER ]
then
    echo "$PREV_USER" | while IFS="|" read ID NAME PLAYED BEST
    do
        echo "Welcome back, $NAME! You have played $PLAYED games, and your best game took $BEST guesses."
    done
    #if new user welcome new user
elif [ -z $PREV_USER]
then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
fi

#after welcoming user prompt user to guess then read input
echo "Guess the secret number between 1 and 1000:"
read GUESS
COUNT=1

#function to continue prompting user for guess until correct answer guessed
PROMPT(){
    if [[ $1 =~ ^[0-9]+$ ]]
    then
        if [[ $1 > $SECRET ]]
        then
            echo "It's lower than that, guess again:"
            read GUESS
            COUNT=$(($COUNT+1))
            PROMPT $GUESS
        elif [[ $1 < $SECRET ]]
        then
            echo "It's higher than that, guess again:"
            read GUESS
            COUNT=$(($COUNT+1))
            PROMPT $GUESS
        elif [ $1 == $SECRET ]
        then
            #insert into database
            echo "$PREV_USER" | while IFS="|" read ID NAME PLAYED BEST
            do
                if [ -z $PREV_USER ]
                then
                    #echo "updating"
                    RESULT=$($PSQL "insert into records(name, games_played, best_game) values('$USERNAME', 1, $COUNT)")
                elif [[ $COUNT < $BEST ]]
                then
                    #echo "updating"
                    RESULT=$($PSQL "UPDATE records SET games_played=$PLAYED+1, best_game=$COUNT WHERE name='$USERNAME'")
                    
                else
                    #echo "updating"
                    RESULT=$($PSQL "UPDATE records SET games_played=$PLAYED+1 WHERE name='$USERNAME'")
                    
                fi
            done
            echo "You guessed it in $COUNT tries. The secret number was $SECRET. Nice job!"
        fi
    else
        echo "That is not an integer, guess again:"
        read GUESS
        COUNT=$(($COUNT+1))
        PROMPT $GUESS
    fi
}


PROMPT $GUESS