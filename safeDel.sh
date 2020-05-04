#!/bin/bash
USAGE="usage: $0 <fill in correct usage>" 

# usage function
# create file function
# man function

TRASHCAN_PATH=~/.trashCan


: '
-------------------------------------------------------------------

Function Name: checkFolderExist

Purpose: To check if the trashCan folder exist and if not, it creates 
the folder in the home directory.

------------------------------------------------------------------'

function checkFolderExist(){
    if [[ ! -d ~/.trashCan ]] #Checking if folder exist. If not, then
    then
        mkdir -p  ~/.trashCan #Creates a hidden folder called trashCan
        echo "Folder $(tput setaf 3) $(tput bold).trashCan $(tput sgr 0)created" #Informs the user that the folder .trashCan was created
    fi
}


: '
-------------------------------------------------------------------

Function Name: usage

Purpose: Informs the users how to use the command

------------------------------------------------------------------'

function usage(){

    echo "Usage: safeDel file [file ...]"

    echo "Usage: safeDel [option]"

    echo "[Options]"
    echo   '-l     output  a  list on screen of the contents of the trashCan direc-
           tory; output should be properly formatted as file name  (without
           path),  size (in bytes) and type for each file (e.g. "safeDel.sh
           -l").'

    echo '-r [file]
           recover i.e. get a specified file, from the  trashCan  directory
           and place it in the current directory'

    echo '-d     delete  interactively  the  contents  of  the trashCan directory
           (e.g. "safeDel.sh -d").'

    echo '-t     display total usage in bytes of the trashCan directory  for  the
           user of the trashcan (e.g. "safeDel.sh t")'

    echo '-m     start  monitor  script  process  (see  requirements  below  e.g.
           "safeDel.sh m")'

    echo '-k     kill current users monitor script  processes  (e.g.  "safeDel.sh
           k") -c option.'

}


: '
-------------------------------------------------------------------

Function Name: listTrashCanFiles

Purpose: Listing files in the trashCan folder with an output formatted as "file name" (without path), "size" (in bytes) and "type" for

Arguments: none

Arguments purpose: 

Returns: 

------------------------------------------------------------------'

function listTrashCanFiles(){


    echo "$(tput bold)============================================================= $(tput sgr 0)" 
    echo "$(tput bold)            Listing files in trashCan folder: $(tput sgr 0)" 
    echo "$(tput bold)============================================================= $(tput sgr 0)" 

    if [[ $(ls -A ~/.trashCan/) ]]; then
        for file in ~/.trashCan/*
        do 
            ((total+=$( ls -l $file | awk '{print $5}' )))
        done

        echo ""
        echo "$(tput setaf 3) $(tput bold)     File type        Filename    Size in bytes$(tput sgr 0)" #Informs the user that the folder .trashCan was created
        echo "" 
    
        ls -l $TRASHCAN_PATH | awk 'NF>2 { 
                                        if ( substr($1,1,1) == "-") printf "  %c regular file", $1 
                                        else if ( substr($1,1,1) == "d") printf "  %c directory", $1
                                        else if ( substr($1,1,1) == "c") printf "  %c character device file", $1
                                        else if ( substr($1,1,1) == "b") printf "  %c block device file", $1
                                        else if ( substr($1,1,1) == "s") printf "  %c local socket file", $1
                                        else if ( substr($1,1,1) == "p") printf "  %c named pipe", $1
                                        else if ( substr($1,1,1) == "l") printf "  %c symbolic link", $1

                                        printf  "%15s %10s\n", $9, $5
                                }' | more
    else
        echo ""
        echo ""
        echo "$(tput bold)$(tput setaf 1) .trashCan folder is empty $(tput sgr 0)"
        echo ""
    fi

    echo ""
    echo "$(tput bold)============================================================= $(tput sgr 0)" 
}

function monitor(){
    # gnome-terminal -- "bash ./monitor.sh"
    x-terminal-emulator -e "bash ./monitor.sh"
}

function kill_monitor(){
    monitor_id=$(ps -eaf | pgrep -f monitor.sh)
    kill -9 $monitor_id
}

function recoverFile(){
    if [[ -f "$TRASHCAN_PATH"/"$1" ]] || [[ -d "$TRASHCAN_PATH"/"$1" ]]
    then
        result=$(mv "$TRASHCAN_PATH"/"$1" .)
        echo "$(tput bold)$(tput setaf 3) File $1 recovered successfully and moved to $(pwd) $(tput sgr 0)"
    else
        echo "$(tput bold)$(tput setaf 1)Error recovering the file. Ensure the file $1 exists and it is the file to be recovered $(tput sgr 0)"
        printf "\n\n"

        echo "$(tput sgr 0)"
        listTrashCanFiles
    fi
}

function folderUsage(){
    clear

    echo "$(tput bold)============================================================= $(tput sgr 0)" 
    echo "$(tput bold)       Total usage in bytes for the trashCan folder:  $(tput sgr 0)" 
    echo "$(tput bold)============================================================= $(tput sgr 0)" 

    local total

    if [[ $(ls -A ~/.trashCan/) ]]; then
        for file in ~/.trashCan/*
        do 
            ((total+=$( ls -l $file | awk '{print $5}' )))
        done

        echo ""
        echo "$(tput bold) Total space usage: $(tput setaf 3)"$total"$(tput sgr 0)"
        echo "" 
    else
        echo ""
        echo "$(tput bold)$(tput setaf 1) .trashCan folder is empty $(tput sgr 0)"
        echo ""
    fi

    echo "$(tput bold)============================================================= $(tput sgr 0)"

    printf "\n"
}

function deleteFiles(){
    listTrashCanFiles

    select menu_list in one many exit
    do case $menu_list in
         "one") echo "$(tput setaf 3) $(tput bold) "
                read -p "Enter the filename to delete: " filename
                if [[ -f "$TRASHCAN_PATH"/"$filename" ]]; then
                    rm "$TRASHCAN_PATH"/"$filename"
                    echo "$(tput setaf 2)File $(tput setaf 3)$filename $(tput setaf 2)removed successfully"
                    echo "$(tput sgr 0)"
                    break
                else  
                    echo "$(tput setaf 1)$(tput bold) File doesn't exist. Ensure the file $filename exists and it is the file you want to delete $(tput sgr 0)"
                    print_again_delete_menu
                fi;;
         "many")
                echo "" 
                echo "$(tput bold)Enter Y to delete a file and N to not delete the file$(tput sgr 0)"
                rm -i $TRASHCAN_PATH/*
                break;;
         "exit") break;;
         *) echo "unknown option";;
        esac
    done
}

trap trapCtrlC SIGINT

trap trapEndScript EXIT

trapCtrlC(){
    total_files=(~/.trashCan/*)

    echo ""
    echo -e "\r\nThanks for using the safeDel script."
    echo "The total number of current files in trashCan folder is: ${#total_files[@]})"
    
    # The trap should indicate the current total number of regular files in the user’s trashCan directory in an appropriate message and then terminate the script.
    exit 130
}

trapEndScript(){
    echo -e "Goodbye $USER! "
}

function print_again_menu(){
    printf "\n\n1) list  2) recover  3) delete  4) total  5) watch  6) kill  7) exit \n"
}

function print_again_delete_menu(){
    printf "1) list  2) recover  3) exit \n"
}

function main(){
    checkFolderExist

    if [[ ! -z "$1" ]]; then
        if [[ "$(echo $1 | head -c 1)" != "-" ]]; then
            for i in $@; do
                if test -f "$i"; then
                    result=$(mv $i $TRASHCAN_PATH)
                    echo "File $i deleted successfully"
                else
                    echo "File $i doesn't exist"
                fi
            done
        else

            if [[ $# -gt 2 ]]; then

                echo "Too many arguments! Please check the usage or manual page"
                usage

                echo "Opening menu"

            else

                OPTIND=1
                        
                while getopts ':lr:dtmk' args; do
                  case ${args} in
                     l) listTrashCanFiles;; 
                     r) recoverFile $OPTARG;; 
                     d) deleteFiles;; 
                     t) folderUsage;; 
                     m) monitor;; 
                     k) kill_monitor;;    
                     :) echo "data missing, option -$OPTARG\n"
                        Usage;;
                    \?) echo "$USAGE";;
                  esac
                done

            fi
            
            # shift $((OPTIND-1))
        fi
    fi
 
    PS3="Enter option: "

    printf "\n\n"
    set -o posix
        select menu_list in list recover delete total watch kill exit
        do case $menu_list in
             "list") listTrashCanFiles
                     print_again_menu;;
             "recover") 
                        echo "$(tput setaf 3) $(tput bold) "
                        read -p "Enter filename to recover: " filename
                        echo "$(tput sgr 0)"

                        recoverFile $filename
                        print_again_menu
                        ;;
             "delete") deleteFiles
                       print_again_menu;;
             "total") folderUsage
                      print_again_menu;;
             "watch") monitor;;
             "kill") kill_monitor;;
             "exit") exit 0;;
             *) echo "unknown option";;
            esac
        done
    set +o posix
}

main $@