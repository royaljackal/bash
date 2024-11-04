#!/bin/bash

declare input
declare valid_input=false
declare -i step_counter=1
declare -i guess_counter=0
declare -i random_number
declare -i guess_precent
declare -a numbers
while :
do
    if $valid_input
        then
            step_counter+=1
    fi
    echo "Step: ${step_counter}"
    read -p "Please enter number from 0 to 9 (q - quit): " input
    case "${input}" in
        [0-9])
            valid_input=true
            random_number=${RANDOM: -1}
            numbers+=(${random_number})
            if [[ "${input}" == "${random_number}" ]]
                then
                    echo "Hit! My number: ${random_number}"
                    guess_counter+=1
                else
                    echo "Miss! My number: ${random_number}"
            fi

            guess_precent=$((guess_counter*100/step_counter))
            echo "Hit: ${guess_precent}%" "Miss: $((100-guess_precent))%"
            echo -e "Numbers: ${numbers[@]}"
        ;;
        q)
            echo "Exit..."
            break
        ;;
        *)
            echo "Not valid input"
            valid_input=false
        ;;
    esac
done