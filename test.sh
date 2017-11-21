#! /bin/bash

#program meta information
authorX="Anthony G. Kerr"
contactX="a2kerr@hotmail.com"
dateX="November 20, 2017"
productX="ESP82666 Flasher and Erase Program"
statementX="This is a little help script erase and program the ESP82666 and ESP32"

#set argument list globally
portX=$1
baudX=$2
fileX=$3

#greeting
function show_Greeting(){
	printf "Free-ware: ${productX}\n"
	printf "Author: ${authorX}\n"
	printf "email: ${contactX}\n"
	printf "Date: ${dateX}\n"
	printf "${statementX}\n"
}

#general error message for invalid file parameter
show_InvalidMessage(){
	commandX=$1
	argumentX=$2
	printf "${commandX}: invalid argument: ${argumentX}\n
			Valid arguments are:
		  	- ‘115200’
		  	- ‘19200’
		  	- ‘9600’
			Try '${commandX} --help' for more information."
}

#get system information as needed
function get_SysInfo(){
	printf "\nLast program's return value: $?"
	printf "\nScript's PID: $$"
	printf "\nNumber of arguments passed to script: $#"
	printf "\nAll arguments passed to script: $@"
	printf "\nScript's arguments separated into different variables: $1 $2..."
}

#generic header to be used for user feedback
function show_header(){
#TODO: implement auto formating
	printf "\n**************************
	        \n** ${1:-"baud is MIA"} **
	        \n**************************\n"
}

#get the work directory information and other file lelated stuff
function get_DirInfo(){
	holdX=$1
	#dataX=$($holdX) | grep "\.bin"
	printf "\nIN get_DirInfo():\n"
	printf "\nRUNNING: $holdX\n$($holdX | grep "\.bin")"
	printf "\nthe directory is: $(pwd)"
	printf "\nthe directory is: $PWD\n"
	#printf "\nRUNNING: $holdX\n$dataX"
}

# run flasher tool to wipe clean memory before flashing new data
function run_Erase(){
	show_header "STARTING ERASE PROCESS!"
	#echo -e "esptool.py --port ${portX} --baud 115200 erase_flash\n"
	printf "\nesptool.py --port ${portX} --baud 115200 erase_flash\n"
	printf "\nPUT DEVICE IN FLASH MODE:\n"
	printf "\n1) Hold FLASH button/pin down while toggling REST button\n"
	printf "\n2) Toggling REST button/pin\n"
	printf "\nNote) RED Led should dim when in FLASH MODE\n"
	printf "\nTO CONTINUE ENTER y?\n"
	read continueY
	if [ "$continueY" != "y" ]
	then
    	printf "\nExitting good bye\n"
	   	exit
	else
    	printf "\nERASE STARTING!\n"
		#TODO: add logging file: esptool.py --port ${portX} --baud 115200 erase_flash > "flasherLog.log" 2>&1
		esptool.py --port ${portX} --baud 115200 erase_flash 
		show_header "Erase Completed :)"
	fi
}

function get_EraseFlash(){
	printf "\nDo you want to erase flash memory y/n?"
	read eraseFlashY #note no need to declare new variable
	if [ "$eraseFlashY" != "y" ]
	then
    	printf "\nDo Not Erase Bye :)\n"
	   	get_DirChange
	else
    	printf "\nERASE STARTING!\n"
     	run_Erase
	fi
}

# Use subshells to work across directories
function get_DirChange(){
	(printf "First, I'm here: $PWD\n") && (cd ~/Sandbox; printf "Then, I'm here: $PWD\n")
	pwd # still in first directory
}

#graceful exit
function show_Exit(){
	clear
	show_header "Hit ANY! key to exit"
	read exitY
	exit
}
#esptool.py --port /dev/ttyUSB0 --baud 115200 write_flash --flash_freq 80m --flash_mode qio --flash_size 4MB 0x0000 espruino_1v93_esp8266_4mb_combined_4096.bin
#printf "hello \n${portX},    ${test2} and ${test3}\n"

#initialize code, add as needed
function set_Init(){
	printf "IN set_Init: "
}

function show_MainMenu(){
	show_header "MAIN MENU"
	printf "\nPlease make selection\n"
	printf "\n1) Device information: "
	printf "\n2) Erase Flash:"
	printf "\n3) Program Flash: Combine 4MB"
	printf "\n4) Program Flash: Segment 4MB"
	printf "\n5) Program Flash: BLANK!\n"
	printf "\n *** HIT q TO QUIT! ***\n"
	read selectionY
	if [ $selectionY != "q"] || [ $selectionY -le 5 ]
	then 
		return ${selectionY}
	else 
		show_Exit
	fi
}

#parse batch file arguments and process code flow, low level state machine
function get_State(){
	if [[ "$baudX" =~ ^- && ! "$baudX" == "--" ]]
	then 
		case $baudX in
	    	#List patterns for the conditions you want to meet
	    	-V | --version) echo "paremeter ${baudX} selected!";;
	    	2) echo "There is a 2.";;
	    	*) show_InvalidMessage "test.sh" $baudX;;
		esac
	else
		show_InvalidMessage "test.sh" "NO PARAMETER FOUND"
	fi
}

function set_ParseMenu(){
	clear
	local selectionY=$1
	show_header "IN: set_ParseMenu($selectionY)"
	case $selectionY in
		1)	printf "1) Device information:"
			printf "= ${selectionY}";; #1) Device information:
		2)  printf "2) Erase Flash:"
			printf "= ${selectionY}";; #2) Erase Flash:
		3)  printf "3) Program Flash: Combine 4MB"
			printf "= ${selectionY}";; #3) Program Flash: Combine 4MB
		4)  printf "Program Flash: Segment 4MB"
			printf "= ${selectionY}";; #4) Program Flash: Segment 4MB
		5)  printf "Program Flash: BLANK!"
			printf "= ${selectionY}";; #5) Program Flash: BLANK!\n\n
	  "q") 	printf "Goodbye :)"
			printf "= ${selectionY}";; #5) Program Flash: BLANK!\n\n			
	esac
}

#main function where it all starts
function main(){
	show_header "IN: main()"
	show_Greeting
	show_MainMenu
	local selectionY=$? #get the value of the last returned, i.e. function()
	show_header "SELECTION = ${selectionY}"
	set_ParseMenu $selectionY
	printf "\nContinue ?\n"
	read continueY
	#get_State
	#get_SysInfo
	#get_DirInfo "ls -1"
	#get_EraseFlash
	#hold=$(get_EraseFlash)
	#printf hold

}

#RUN*******************************************************************************************************
	while [ 1 ] 
	do
		clear
		main
	done