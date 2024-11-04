#!/bin/bash

declare valid_input=false
declare -a matrix
declare -i matrix_size=4
declare -i counter=1
declare -i empty=$((matrix_size*matrix_size))
declare -i turn_counter=1
declare input

for ((row = 0; row < matrix_size; row+=1))
do
    for ((column = 0; column < matrix_size; column+=1))
    do
        matrix[row*matrix_size+column]=${counter}
        counter+=1
    done
done
matrix=( $(shuf -e "${matrix[@]}") )

while (:) do
    if $valid_input
        then
            turn_counter+=1
    fi
    valid_input=false    
    echo "Ход: ${turn_counter}"
    echo ""

    echo "+-------------------+"
    for ((row = 0; row < matrix_size; row+=1)) do
        echo -n "| "
        for ((column = 0; column < matrix_size; column+=1)) do
            if [[ "${matrix[row*matrix_size+column]}" == "${empty}" ]]
                then
                    echo -n " "
                else
                    echo -n "${matrix[row*matrix_size+column]}"
            fi

            if [[ "${column}" == "$((matrix_size-1))" ]]
                then
                    echo " |"
                else
                    if [[ "${#matrix[row*matrix_size+column]}" == 1 ]]
                        then
                            echo -n "  | "
                        else
                            echo -n " | "
                fi
            fi
        done

        if [[ "${row}" == "$((matrix_size-1))" ]]
            then
                echo "+-------------------+"
            else
                echo "|-------------------|"
        fi
    done

    echo ""

    matrix_ordered=true
    for ((i = 0; i < matrix_size ; i+=1)) do
        if [[ "${matrix[i]}" != $((i+1)) ]]
            then
                matrix_ordered=false
                break
        fi
    done

    if [[ ${matrix_ordered} == true ]]
        then
            echo "ура победа!!11!"
            break
    fi

    read -p "Ваш ход (q - выход): " input

    case "${input}" in
        *[0-9])
            if ((input < 1 || input > matrix_size*matrix_size-1))
                then
                    echo "Число вне границ пятнашек"
                else
                    for i in "${!matrix[@]}"; do
                        if [[ "${matrix[$i]}" = "${input}" ]]; then
                            index="${i}";
                        fi
                    done
                    
                    index_row=$((index/matrix_size))
                    index_column=$((index%matrix_size))

                    if [[ "${index_row}" != 0 && "${matrix[index-matrix_size]}" == "${empty}" ]] 
                        then
                            matrix[index-matrix_size]=${matrix[index]}
                            matrix[index]=${empty}
                            valid_input=true
                        else
                            if [[ "${index_row}" != $((matrix_size-1)) && "${matrix[index+matrix_size]}" == "${empty}" ]] 
                                then
                                    matrix[index+matrix_size]=${matrix[index]}
                                    matrix[index]=${empty}
                                    valid_input=true
                            fi
                    fi

                    if [[ "${index_column}" != 0 && "${matrix[index-1]}" == "${empty}" ]] 
                        then
                            matrix[index-1]=${matrix[index]}
                            matrix[index]=${empty}
                            valid_input=true
                        else
                            if [[ "${index_column}" != $((matrix_size-1)) && "${matrix[index+1]}" == "${empty}" ]] 
                                then
                                    matrix[index+1]=${matrix[index]}
                                    matrix[index]=${empty}
                                    valid_input=true
                            fi
                    fi

                    if  [[ ${valid_input} != true ]]
                        then
                            echo "Неверный ход"
                            echo "Невозможно костяшку ${input} передвинуть на пустую ячейку."

                            declare -a allowed_turns=()

                            for i in "${!matrix[@]}"; do
                                if [[ "${matrix[$i]}" = "${empty}" ]]; then
                                    empty_index="${i}";
                                fi
                            done

                            empty_row=$((empty_index/matrix_size))
                            empty_column=$((empty_index%matrix_size))

                            if [[ "${empty_row}" != 0 ]] 
                                then
                                    allowed_turns+=(${matrix[empty_index-matrix_size]}) 
                            fi

                            if [[ "${empty_row}" != $((matrix_size-1)) ]] 
                                then
                                    allowed_turns+=(${matrix[empty_index+matrix_size]}) 
                            fi

                            if [[ "${empty_column}" != 0 ]] 
                                then
                                    allowed_turns+=(${matrix[empty_index-1]}) 
                            fi

                            if [[ "${empty_column}" != $((matrix_size-1)) ]] 
                                then
                                    allowed_turns+=(${matrix[empty_index+1]}) 
                            fi

                            echo "Можно выбрать: $(IFS=", " ; echo "${allowed_turns[*]}")"       
                                           
                    fi
            fi
            
        ;;
        q)
            echo "Exit..."
            break
        ;;
        *)
            echo "Not valid input"
        ;;
    esac
done


