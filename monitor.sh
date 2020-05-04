#!/bin/bash
USAGE="usage: $0 <fill in correct usage>" 

TRASHCAN_PATH=~/.trashCan

echo ""
echo "-----------------------------------------------------------------------------"
echo "   Name: Tício Victoriano         " 
echo "   Student ID: S1803453                  "
echo "   Assignment: Monitor Script     "
echo "   Module: Systems Programming    "
echo "-----------------------------------------------------------------------------"
echo ""

n_old_files=(~/.trashCan/*)
n_files_deleted=0
n_files_created=0

declare -A file_hash_array=()

function deleteHashArrays(){
  for j in ${file_hash_array[@]}; do
      unset file_hash_array["$j"]
  done
}

function file_hash_array_init(){
  deleteHashArrays
  for j in ${n_old_files[@]}; do
      hash=$(md5sum "$j")
      file_hash_array["$j"]=$hash
  done
}

function checkingChangesInFile(){
  for j in ${n_old_files[@]}; do
      if [ ${file_hash_array["$j"]+abc} ]; then
         
         newhash=$(md5sum "$j")
         
         if [[ "$newhash" != "${file_hash_array["$j"]}" ]]; then
            echo "The file $j was recently changed"
         fi

      fi
  done
}

function checkingNewFiles(){
  local currentFilesInFolder=( ~/.trashCan/* )
  local found=false
  local filename=""

  for i in ${currentFilesInFolder[@]}; do
    for j in ${n_old_files[@]}; do
        if [[ "$j" == "$i" ]]; then
            found=true
        fi
        filename="$i"
    done

    if ! $found ; then
        echo "$(tput bold)$(date +%H:%M:%S):: $(tput sgr 0)$(tput setaf 3) File $filename is a new file added into the trashCan folder $(tput sgr 0)"
        n_old_files+=("$filename")
        ((n_files_created+=1))
    else 
       found=false
    fi
  done
}

function checkingDeletedFiles(){
  local currentFilesInFolder=( ~/.trashCan/* )
  local found=false
  local filename=""

  for i in ${n_old_files[@]}; do
    for j in ${currentFilesInFolder[@]}; do
        if [[ "$i" == "$j" ]]; then
              found=true
        fi
        filename="$i"
    done

    if ! $found ; then
        echo "$(tput bold)$(date +%H:%M:%S) $(tput sgr 0)$(tput setaf 2) File $filename was recovered or deleted from the trashCan folder $(tput sgr 0)"
        update
        ((n_files_deleted+=1))
    else 
       found=false
    fi
  done
}

function printStats(){
    files=( ~/.trashCan/* )

    echo "$(tput bold)"
    printf "Nº of files in folder: %-5s Nº of files deleted: %-5s Nº of new files added: %-5s \n" "${#files[@]}" "$n_files_deleted" "$n_files_created"
    echo "$(tput sgr 0)"
}

trap trapCtrlC SIGINT

trap trapEndScript EXIT

trapCtrlC(){

    echo -e "\r\n Closing the monitor subprocess"
    
    # The trap should indicate the current total number of regular files in the user’s trashCan directory in an appropriate message and then terminate the script.
    exit 130
}

trapEndScript(){
    echo -e "Goodbye $USER! "
}

function update(){
    n_old_files=( ~/.trashCan/* )
    file_hash_array_init
}

file_hash_array_init

while true; do
  printStats

  checkingNewFiles
  checkingDeletedFiles
  checkingChangesInFile

  sleep 15
done