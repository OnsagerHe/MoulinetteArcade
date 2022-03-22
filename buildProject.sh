#!/bin/bash
# Path: buildProject.sh

ROOT_DIR=$PWD

_start=1
_end=100

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BOLD=$(tput bold)
REGULAR=$(tput sgr0)
BLINK=$(tput blink)
END='\e[27m'
CYAN='\033[0;36m'

MAKE=0

trap "echo ' Trapped Ctrl-C'" SIGINT
function ProgressBar {
    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done
    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")

    printf "\rProgress : [${_fill// /#}${_empty// /-}] ${_progress}%%"
}

# for number in $(seq ${_start} ${_end})
# do
#     sleep 0.01
#     ProgressBar ${number} ${_end}
# done

function removedBin {
    if [[ -f ${ROOT_DIR}/arcade ]]
        then
            #echo -e "${GREEN}arcade binary succefully removed${NC}"
            rm -f ${ROOT_DIR}/arcade
        else
            echo -e "${RED}arcade binary doesn't exist${NC}"
            echo -e "${RED}${BOLD}Did you execute ./buildProject ?${NC}${REGULAR}"
    fi
    rm -f ${ROOT_DIR}/*.bak || true
    rm -f ${ROOT_DIR}/lib/*.so || true
}

function removedBuild {
    if [[ -d ${ROOT_DIR}/build ]]
        then
            #echo -e "${GREEN}Build removed successfully${NC}"
            rm -rf ${ROOT_DIR}/build
        else
            echo -e "${RED}Build folder doesn't exist${NC}"
    fi
}

function usage {
    echo -e "${GREEN}${BOLD}Usage:${NC}${REGULAR}"
    echo -e "${GREEN} --- buildProject.sh${NC}"
    echo -e "${GREEN} --- buildProject.sh --help${NC}"
    echo -e "${GREEN} --- buildProject.sh --documentation || -d${NC}"
    echo -e "${GREEN} --- buildProject.sh --clean || -c${NC}"
    echo -e "${GREEN} --- buildProject.sh --version || -v${NC}"
}

center() {
    termwidth="$(tput cols)"
    padding="$(printf '%0.1s' ={1..500})"
    printf '%*.*s %s %*.*s\n' 0 "$(((termwidth-2-${#1})/2))" "$padding" "$1" 0 "$(((termwidth-1-${#1})/2))" "$padding"
}

function checkLib {
    declare -i counter=0
    notFound=()
    array=(arcade_sfml.so arcade_sdl.so arcade_ncurses.so arcade_pacman.so arcade_nibbler.so documenation.pdf)
    declare -i size=$(( ${#array[@]} ))

    echo -e "${CYAN}${BOLD}--- Checking libraries ---${NC}${REGULAR}"
    echo
    if [[ -d ./lib ]]
        then
            for i in "${array[@]}"
            do
                if [[ -f ${ROOT_DIR}/lib/$i ]]
                    then
                        counter=$((counter + 1))
                        sleep 0.5
                        ProgressBar ${counter} $size
                elif [[ -f ${ROOT_DIR}/doc/$i ]]
                    then
                        counter=$((counter + 1))
                        sleep 0.5
                        ProgressBar ${counter} $size
                else
                    notFound+=($i)
                    # echo
                    # echo -e "${RED}${BOLD}[-]${NC} ./lib/$i folder not found"
                fi
            done
        else
            echo -e "${RED}${BOLD}Library files or documentation not found${NC}"
            echo -e "${RED}${BOLD}Please, run the script from the project root directory${NC}"
            exit 1
    fi
    declare -i sizeNotFound=$(( ${#notFound[@]} ))
    if [ $sizeNotFound -ne 0 ]
    then
        echo -e "\n"
        echo -e "${RED}--- ${BOLD}$sizeNotFound${REGULAR}${RED} file(s) not found ---${NC}"
        for value in "${notFound[@]}"
            do
                echo -e "${RED}${BOLD}[-]${NC} ./lib/$value folder not found"

        done
    fi
    
    echo -e "${GREEN}${BOLD}[+]${NC} ${counter}/$size libraries and documentation found"
}

function checkCompil {
    if [ -f ./CMakeLists.txt ]
        then
            $MAKE=0
    elif [ -f ./Makefile ]
        then
            $MAKE=1
    else
        echo -e "${RED}${BOLD}CMakeLists.txt or Makefile not found${NC}"
        echo -e "${RED}${BOLD}Please, run the script from the project root directory${NC}"
        exit 1
    fi
}

function doCompilation {
    mkdir -p build
    if [ $MAKE -eq 0 ]
        then
            echo -e "${CYAN}${BOLD}--- Compilation with CMake ---${NC}${REGULAR}"
            echo
            if [[ -d ./build ]]
                then
                    cd ./build
                    cmake ..
                    make
                else
                    echo -e "${RED}${BOLD}Build directory not found${NC}"
                    echo -e "${RED}${BOLD}Please, run the script from the project root directory${NC}"
                    exit 1
            fi
        else
            echo -e "${CYAN}${BOLD}--- Compilation with Makefile ---${NC}${REGULAR}"
            echo
                    make re
    fi
}

function checkArgument {
    ${ROOT_DIR}/arcade > /dev/null 2>&1
    returnValue=$?
    defaultValue=84

    if [[ $returnValue -eq $defaultValue ]]
        then
            echo -e "${GREEN}${BOLD}[+]${NC} Arcade with no arguments"
        else 
            echo -e "${RED}${BOLD}[-]${NC} Arcade with no arguments"
    fi
    ${ROOT_DIR}/arcade ${ROOT_DIR}/lib/arcade_libcaca.so > /dev/null 2>&1
    returnValue=$?
    if [[ $returnValue -eq $defaultValue ]]
        then
            echo -e "${GREEN}${BOLD}[+]${NC} Arcade with wrong arguments"
        else
            echo -e "${RED}${BOLD}[-]${NC} Arcade with wrong arguments"
    fi
    ${ROOT_DIR}/arcade ${ROOT_DIR}/lib/arcade_sfml.so Hello > /dev/null 2>&1
    returnValue=$?
    if [[ $returnValue -eq $defaultValue ]]
        then
            echo -e "${GREEN}${BOLD}[+]${NC} Arcade length arguments different than 1"
            else
            echo -e "${RED}${BOLD}[-]${NC} Arcade length arguments different than 1"
    fi
    # ${ROOT_DIR}/arcade ${ROOT_DIR}/lib/arcade_sfml.so > /dev/null 2>&1
    # returnValue=$?
    # defaultValue=0
    # if [[ $returnValue -eq $defaultValue ]]
    #     then
    #         echo -e "${GREEN}${BOLD}[+]${NC} Arcade with great arguments"
    #         else
    #         echo -e "${RED}${BOLD}[-]${NC} Arcade with great arguments"
    # fi
}

function moulinette {
    echo -e "${CYAN}${BOLD}--- {Moulinette} ---${NC}${REGULAR}"
    if [ $MAKE -eq 0 ]
        then
        mkdir ./build/ && cd ./build/
        cmake .. -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release
        cmake --build .
        cd ..
    else
        make re
    fi
    ls ./arcade ./lib/ > /dev/null 2>&1
    checkLib
    checkArgument
    removedBin
    removedBuild
}

function createDocumentation {
    if [ -f Doxyfile ]
        then
            doxygen Doxyfile
            make -C ./doc/latex
            mv ./doc/latex/refman.pdf ./doc/documenation.pdf
            rm -rf ./doc/latex
            rm -rf ./doc/html
        else
            echo -e "${RED}${BOLD}Doxyfile not found${NC}"
            echo -e "${RED}${BOLD}Please, run the script from the project root directory${NC}"
            exit 1
    fi
}

function mainProgram {
    if [ $# -eq 0 ]
        then
            doCompilation
        elif [ $# -eq 1 ]
            then
                if [ $1 == "--help" ] || [ $1 == "-h" ]
                    then
                        usage
                elif [ $1 == "--clean" ] || [ $1 == "-c" ]
                    then
                        removedBuild
                        removedBin
                elif [ $1 == "--documentation" ] || [ $1 == "-d" ]
                    then
                        echo -e "${CYAN}${BOLD}--- {Documentation} ---${NC}${REGULAR}"
                            createDocumentation
                elif [ $1 == "--version" ] || [ $1 == "-v" ]
                    then
                        echo -e "${CYAN}${BOLD}--- {Version} ---${NC}${REGULAR}"
                        echo -e " arcade-build-script v0.1.3"
                elif [ $1 == "--moulinette" ] || [ $1 == "-m" ]
                    then
                        moulinette
                else
                    usage
                fi
        else
            echo -e "${RED}${BOLD}Invalid argument${NC}${REGULAR}"
            usage
    fi
}

mainProgram