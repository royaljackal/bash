#!/bin/bash

declare stack_A=(1 2 3 4 5 6 7 8)
declare stack_B=()
declare stack_C=()
declare valid_input=false
declare -i turn_counter=1

trap 'echo "";echo "Для завершения игры введите q или Q."' SIGINT

while (:) do
    i=0
    while ((i<8))
    do
        echo "|${stack_A[i]:- }| |${stack_B[i]:- }| |${stack_C[i]:- }|"
        i=$((i+1))
    done
    echo "+-+ +-+ +-+"
    echo " A   B   C "
    echo ""

    echo "A =  ${stack_A[*]}"
    echo "B = ${stack_B[*]}"
    echo "C = ${stack_C[*]}"

    if $valid_input
        then
            turn_counter+=1
    fi
    valid_input=false    
    read -r -p "Ход № {$turn_counter} (откуда, куда): " input
    echo ""

    input=$(echo "$input" | tr -d ' ' | tr '[:lower:]' '[:upper:]')
    case "${input}" in
        [qQ])
            exit 1
        ;;
        [a-cA-C][a-cA-C])
            from=${input:0:1}
            to=${input:1:1}
            stack_from="stack_$from[*]"
            stack_to="stack_$to[*]"

            echo $from
            echo $to

            if [[ $from == "$to" ]]
            then
                echo "Одинаковые башни!"

            elif [[ -z ${!stack_from} ]]
            then
                echo "Cтек $from пуст!"
            elif [[ ${!stack_to:0:1} -gt 0 && ${!stack_from:0:1} -gt ${!stack_to:0:1} ]]
            then
                echo "Такое перемещение запрещено!"
            else
                valid_input=true

                eval "stack_$to=(${!stack_from:0:1} ${!stack_to})"
                eval "stack_$from=(${!stack_from:1})"

                if [[ "${stack_B[*]}" == "1 2 3 4 5 6 7 8" || "${stack_C[*]}" == "1 2 3 4 5 6 7 8" ]]; then
                    echo "Поздравляем! Вы выиграли!"
                    exit 0
                fi
            fi           
        ;;
        *)
            echo "Ошибка ввода."
        ;;
    esac
done