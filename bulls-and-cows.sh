#!/bin/bash

declare valid_input=false
declare -i turn_counter=1
declare -i bulls
declare -i cows
declare -i secret
declare input
declare history

trap 'echo "";echo "Для завершения игры введите q или Q."' SIGINT

while (:) do
    secret=$((RANDOM % 9000 + 1000))  # Генерация числа от 1000 до 9999
    if [[ $(echo "$secret" | grep -o . | sort | uniq -d | wc -l) == 0 ]]; then
        break
    fi
done

echo $secret

echo "********************************************************************************
* Я загадал 4-значное число с неповторяющимися цифрами. На каждом ходу делайте *
* попытку отгадать загаданное число. Попытка - это 4-значное число с           *
* неповторяющимися цифрами.                                                    *
********************************************************************************"

while (:) do
    if $valid_input
        then
            turn_counter+=1
    fi
    valid_input=false    
    read -r -p "Попытка ${turn_counter}: " input
    echo ""

    case "${input}" in
        [qQ])
            exit 1
        ;;
        *[!0-9]*)
            echo "Ошибка ввода."
        ;;
        *)
            if [[ ${#input} == 4 ]] && [[ $(echo "$input" | grep -o . | sort | uniq -d | wc -l) == 0 ]] 
            then
                valid_input=true
                bulls=0
                cows=0
                for ((i=0; i<4; i++)); do
                    if [[ "${secret:$i:1}" == "${input:$i:1}" ]]; then
                        ((bulls++))
                    elif [[ "$secret" == *${input:$i:1}* ]]; then
                        ((cows++))
                    fi
                done

                history+=("$turn_counter. $input (Коров -  $cows Быков - $bulls)")

                if [[ $bulls == 4 ]]; then
                    echo "Поздравляем! Вы угадали число $secret."
                    exit 0
                else
                    echo "Коров -  $cows, Быков - $bulls"
                fi

                echo "История ходов:"
                    for line in "${history[@]}"; do
                        echo "$line"
                    done

                echo ""
            else
                echo "Ошибка ввода."
            fi
        ;;
    esac
done