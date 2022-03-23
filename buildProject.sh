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
    echo -e "${CYAN}${BOLD}Usage:${NC}${REGULAR}"
    echo -e "${GREEN} --- buildProject.sh${NC}"
    echo -e "${GREEN} --- buildProject.sh --help${NC}"
    echo -e "${GREEN} --- buildProject.sh --documentation || -d${NC}"
    echo -e "${GREEN} --- buildProject.sh --clean || -c${NC}"
    echo -e "${GREEN} --- buildProject.sh --version || -v${NC}"
    echo -e "${GREEN} --- buildProject.sh --moulinette || -m${NC}"
}

function mandatoryFunction {
    arr=("$@")

    if [[ ${arr} =~ "arcade_ncurses.so" ]] 
        then
            echo -e "${RED}${BOLD}[-]${NC} ./lib/arcade_ncurses.so folder not found"
        else
            echo -e "${GREEN}${BOLD}[+]${NC} ./lib/arcade_ncurses.so folder found"
    fi

    if [[ ${arr} =~ "arcade_sdl2.so" ]] 
        then
            echo -e "${RED}${BOLD}[-]${NC} ./lib/arcade_sdl2.so folder not found"
        else
            echo -e "${GREEN}${BOLD}[+]${NC} ./lib/arcade_sdl2.so folder found"
    fi
}

function lenCounterGraphical {
        # If counter < 3 print error
    name=$1[@]
    counter=$2
    notFound=("${!name}")

    if [ $counter -lt 3 ]
        then
            echo -e "${RED}${BOLD}[-]${NC} You must have at least 3 libraries"
            echo -e "${RED}${BOLD}[-]${NC} You have only $counter libraries"
            echo -e "${RED}${BOLD}[-]${NC} Choose another graphic library in this list :"
            echo -e "${RED}${BOLD}[-]${NC} ${notFound[@]}"
            exit 1
    fi
    notFound=""
}

function lenCounterGame {
    name=$1[@]
    counter=$2
    notFountGame=("${!name}")

    if [ $counter -lt 2 ]
        then
            echo -e "${RED}${BOLD}[-]${NC} You must have at least 2 libraries game."
            echo -e "${RED}${BOLD}[-]${NC} You have only $counter libraries game."
            echo -e "${RED}${BOLD}[-]${NC} Choose another game library in this list :"
            echo -e "${RED}${BOLD}[-]${NC} ${notFountGame[@]}"
            exit 1
    fi
}

function checkLibGame {
    notFountGame=()
    array=(arcade_nibbler.so arcade_pacman.so arcade_qix.so arcade_centipede.so arcade_solarfox.so)
    declare -i counter=0
    declare -i count=0
    declare -i size=$(( ${#array[@]} ))

    echo -e "${CYAN}${BOLD}--- Checking libraries game ---${NC}${REGULAR}"
    echo
    if [[ -d ./lib ]]
        then
            for i in "${array[@]}"
            do
                if [[ -f ${ROOT_DIR}/lib/$i ]]
                    then
                        counter+=1
                else
                    notFountGame+=($i)
                fi
                count+=1
                sleep 0.2
                ProgressBar ${count} $size
            done
        else
            echo -e "${RED}${BOLD}Library files game not found.${NC}"
            echo -e "${RED}${BOLD}Please, run the script from the project root directory${NC}"
            exit 1
    fi
    echo
    lenCounterGame notFountGame "${counter}"
    echo -e "${GREEN}${BOLD}[+]${NC} ${counter}/$size libraries game found."
}

function checkLibGraphic {
    notFound=()
    array=(arcade_ncurses.so arcade_sdl2.so arcade_ndk++.so arcade_aalib.so arcade_libcaca.so
    arcade_allegro5.so arcade_xlib.so arcade_gtk+.so arcade_sfml.so arcade_irrlicht.so 
    arcade_opengl.so arcade_vulkan.so arcade_qt5.so)
    declare -i counter=0
    declare -i count=0
    declare -i size=$(( ${#array[@]} ))

    echo -e "${CYAN}${BOLD}--- Checking libraries graphical ---${NC}${REGULAR}"
    echo
    if [[ -d ./lib ]]
        then
            for i in "${array[@]}"
            do
                if [[ -f ${ROOT_DIR}/lib/$i ]]
                    then
                        counter+=1
                else
                    notFound+=($i)
                    # echo
                    # echo -e "${RED}${BOLD}[-]${NC} ./lib/$i folder not found"
                fi
                count+=1
                sleep 0.2
                ProgressBar ${count} $size
            done
        else
            echo -e "${RED}${BOLD}Library files graphical not found.${NC}"
            echo -e "${RED}${BOLD}Please, run the script from the project root directory${NC}"
            exit 1
    fi
    echo
    lenCounterGraphical notFound "${counter}"
    mandatoryFunction "${notFound[@]}"
    echo -e "${GREEN}${BOLD}[+]${NC} ${counter}/$size libraries graphical found."
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

    echo
    echo -e "${CYAN}${BOLD}--- Checking arguments ---${NC}${REGULAR}"

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
    # ls ./arcade ./lib/ > /dev/null 2>&1
    #checkLib
    checkArgument
    checkLibGraphic
    checkLibGame
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

# mainProgram
