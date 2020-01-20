#! /bin/bash

#program meta information
authorX="Anthony G. Kerr"
contactX="a2kerr@hotmail.com"
dateOG="July 08, 2018"
dateX="January 16, 2020"
productX="Flasher and Erase Helper Program"
statementX="A little \"esptool\" helper script for:\nESP82666 and ESP32 "

#set argument list globally
declare -A config_meta 
config_meta[port]=$1
config_meta[baud]=$2
config_meta[firmware]=$3
config_meta[fail]="Make sure your MCU is plugged in"

if [[ ${config_meta[port]} = "" ]]; then config_meta[port]="???"; fi 
if [[ ${config_meta[baud]} = "" ]]; then config_meta[baud]="115200"; fi 
if [[ ${config_meta[firmware]} = "" ]]; then config_meta[firmware]="???"; fi 

#greeting
function show_Greeting(){
	printf "Free-ware: ${productX}\n"
	printf "Author: ${authorX}\n"
	printf "email: ${contactX}\n"
	printf "Date: ${dateX}\n"
	printf "${statementX}\n"
}

#ask user decision to continue, quit or start again?
function get_UserContinue(){
	printf "\nTo CONTINUE enter y?\n"
	printf "To RESTART enter r?\n"
	printf "To Quit enter q?\n"
	read continueY
	if [ "$continueY" == "y" ]
		then return 0
	elif [ "$continueY" == "q" ]
    	then show_Exit
	else
		return 1
	fi
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

# show user instruction message on how to put the device in flash mode
function show_FlashModeInstuction(){
	local callbackX=$1
	printf "\nYOU MUST PUT DEVICE IN FLASH MODE:\n"
	printf "\n1) Hold FLASH button/pin down while...\n"
	printf "\n2) Toggling REST button/pin\n"
	printf "\nNote) The RED Led will dim indicating FLASH MODE set\n"
	get_UserContinue
	local continueY=$?
	if [ "$continueY" == 0 ]
		then
			return 0
	else
		clear
		#get_chipInfo
		$callbackX
	fi
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
	        \n** ${1:-"Hello World!"} **
	        \n**************************\n"
}

#get the work directory information and other file related stuff
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
	printf "\nesptool.py --port ${portX_Meta[port]} --baud 115200 erase_flash\n"
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

# Erase MCU Flash
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

#get chip information
function get_chipInfo(){
	show_header "Getting Chip Information"
	show_FlashModeInstuction get_chipInfo
	esptool.py --port ${config_meta[port]} --baud ${config_meta[baud]} chip_id
}

#get USB Port
function get_usbPort(){
	local -A meta 
		meta[menu]=$1
		meta[header]="Menu: Configure Port"
		meta[search]="/dev/ttyUSB*"
		meta[pass]="\nPort is now set too: "
		meta[fail]="No port found!\nMake sure your MCU is plugged in\n"
	show_header "${meta[header]}"
	usbPortList=( $(ls -1 ${meta[search]} 2> /dev/null))
	getLastCommandStatus=$(echo $?)
	if [ $getLastCommandStatus != 0 ]; then
			printf "${meta[fail]}"
			return
		else 
		for indexX in ${!usbPortList[@]}; do
			printf "$indexX) ${usbPortList[$indexX]}\n"
		done
	fi
	printf "\nSelect Port: "
	read selectionY
	config_meta[port]=${usbPortList[$selectionY]}
	if [ "${config_meta[port]}" != "" ]
	then
		printf "${meta[pass]}${config_meta[port]}"
		return ${selectionY}
	else
		config_meta[port]="???"
		printf "\n*** Something went wrong! Check your selection"
		return 255
	fi
}

# Get Baud rate of MCU 
function get_Buad(){
	show_header "Getting Baud Rate"
	usbPortX="./*.bin"
	usbPortList=( $(ls $usbPortX))
	getLastCommandStatus=$(echo $?)
	if [ $getLastCommandStatus != 0 ]; then
			printf "\nNO PORT NOT FOUND"
		else 
		for indexX in ${!usbPortList[@]}; do
			printf "$indexX) ${usbPortList[$indexX]}\n"
		done
	fi
	read selectionY
	#if [ $selectionY == "q" ] || [ $selectionY -le 5 ]
	if [ "$selectionY" != "" ]
	then
		portX=${usbPortList[$selectionY]}
		printf "Port = ${usbPortList[$selectionY]}" 
		return ${selectionY}
	else
		portX="???"
		return 255
	fi
}

#Get firmware
function get_Firmware(){
	show_header "Getting Firmware"
	usbPortX="/dev/ttyUSB*"
	usbPortList=( $(ls $usbPortX))
	getLastCommandStatus=$(echo $?)
	if [ $getLastCommandStatus != 0 ]; then
			printf "\nNO PORT NOT FOUND"
		else 
		for indexX in ${!usbPortList[@]}; do
			printf "$indexX) ${usbPortList[$indexX]}\n"
		done
	fi
	read selectionY
	#if [ $selectionY == "q" ] || [ $selectionY -le 5 ]
	if [ "$selectionY" != "" ]
	then
		portX=${usbPortList[$selectionY]}
		printf "Port = ${usbPortList[$selectionY]}" 
		return ${selectionY}
	else
		portX="???"
		return 255
	fi
}

# Get config status
function get_configuration_status(){
	if [[ ${config_meta[port]} = "???" ]]; then 
		printf "Checkxx Port ${config_meta[port]}"
		return 1 
	elif [[ ${config_meta[baud]} = "" ]]; then 
		printf "Check Baud Rate ${config_meta[baud]}"
		return 2
	elif [[ ${config_meta[firmware]} = "???" ]]; then 
		printf "Checkx Firmware ${config_meta[firmware]}"
		return 3
	else 
		printf "All Good"
		return 0
	fi 
}

#graceful exit
function show_Exit(){
	clear
	show_header "Hit ANY! key to exit"
	#read exitY
	exit
}
#esptool.py --port /dev/ttyUSB0 --baud 115200 write_flash --flash_freq 80m --flash_mode qio --flash_size 4MB 0x0000 espruino_1v93_esp8266_4mb_combined_4096.bin
#printf "hello \n${portX},    ${test2} and ${test3}\n"

#initialize code, add as needed
function set_Init(){
	printf "IN set_Init: "
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

#Flash 4mb continious
function flash4mbCombine(){
	show_header "IN: flash4mbCombine"
	#esptool.py --port ${portX} --baud 115200 write_flash --flash_freq 80m --flash_mode qio --flash_size 4MB 0x0000 espruino_1v93_esp8266_4mb_combined_4096.bin 
	esptool.py --port /dev/ttyUSB0 --baud 115200 write_flash --flash_freq 80m --flash_mode qio --flash_size 4MB 0x0000 ./bin/espruino_1v93_esp8266_4mb_combined_4096.bin
}

#Flash 4mb segment
function flash4mbSegment(){
	show_header "IN: flash4mbSegment()"
	#esptool.py --port ${portX} --baud 115200 write_flash --flash_freq 80m --flash_mode qio --flash_size 4MB 0x0000 espruino_1v93_esp8266_4mb_combined_4096.bin 
}

#**** Main Menu ****
function show_MainMenu(){
	show_header "MAIN MENU"
	printf "\nPort = ${config_meta[port]}"
	printf "\nBaud = ${config_meta[baud]}"
	printf "\nFirmware = ${config_meta[firmware]}"
	printf "\n\nPlease make a selection\n"
	printf "\n1) Device information: "
	printf "\n2) Erase Flash:"
	printf "\n3) Program Flash: Combine 4MB"
	printf "\n4) Program Flash: Segment 4MB"
	printf "\n5) Program Flash: BLANK!"
	printf "\n6) List Files: *.bin"
	printf "\n7) Test Item: for test"
	printf "\n8) Set USB Port: "
	printf "\n *** HIT q TO QUIT! ***\n"
	read selectionY
	#if [ $selectionY == "q" ] || [ $selectionY -le 5 ]
	if [ "$selectionY" != "q" ]
	then 
		return ${selectionY}
	else
		return 255
	fi
}


# Test Function
function test(){
	for i in ????:??:??.? ; do
		printf "$i"
  	done
}

#Parse Menu
function set_ParseMenu(){
	clear
	local selectionY=$1
	#show_header "IN: set_ParseMenu($selectionY)"
	case $selectionY in
		1)	printf "1) Device information:\n" #1) Device information:
			#printf "= ${selectionY}\n"
			get_configuration_status
			local returnX=$1
			printf "\n return value ${returnX}"
			if (( ${returnX} > 2 )); then 
				get_chipInfo
			else 
				# read continueY
				return 255
			fi;; 
		2)  printf "2) Erase Flash:\n" #2) Erase Flash:
			printf "= ${selectionY}\n"
			get_EraseFlash;; 
		3)  printf "3) Program Flash: Combine 4MB\n" #3) Program Flash: Combine 4MB
			printf "= ${selectionY}\n"
			flash4mbCombine;; 
		4)  printf "Program Flash: Segment 4MB\n" #4) Program Flash: Segment 4MB
			printf "= ${selectionY}\n"
			flash4mbSegment\n;; 
		5)  printf "Program Flash: BLANK!\n" #5) Program Flash: BLANK!
			printf "= ${selectionY}\n";; 
		6)  printf "List Files: *.bin\n" #6) List Files: *.bin\n
			printf "= ${selectionY}\n"
			ls -1 ./bin
			;;
		7)  printf "Test Item: for test\n" #7) used as test function
			printf "= ${selectionY}\n"
			test
			;; 
		8)  printf "Set USB Port:\n" #8) list available USB ports
			printf "= ${selectionY}\n"
			get_usbPort
			;; 
	  255) 	printf "Goodbye :)\n" #q) quit/exit
			printf "= ${selectionY}\n"
			show_Exit;; 			
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

#RUN *******************************************************************
	while [ 1 ] 
	do
		clear
		main
	done
#on Asus Tinker
#from git