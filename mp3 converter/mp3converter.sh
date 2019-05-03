#!/bin/bash

inputfile=""
declare -a inputarray
trap '{exit 1;}' INT

function exit2shell {
	clear
	exit 0
}

# Get input audio file from user
inputfile=$(dialog --stdout --title "Please Select Audio File" --fselect "" 10 100)

# If input is empty or canceled, then clear and exit
if [ -z $inputfile ]
then
	exit2shell
fi

# Print dialog screen while input file is not empty or not audio file
while [ ! -z $inputfile ] || [ -z $isAudio ]
do
	# Check the file is an audio file
	isAudio=$(file $inputfile | grep audio)

	# Get new input if previous input file is not an audio file
	if [ -z $isAudio ]
	then
		inputfile=$(dialog --stdout --title "Input file is invalid. Please Select Valid Audio File" --fselect "" 10 100)

		# Clear and exit if input is empty
		if [ -z $inputfile ]
		then
			exit2shell
		fi
	
	# If input file is an audio file, break the loop
	else
		break
	fi	
done

# Get the MP3 output file name
outputfile=$(dialog --stdout --title "Please Write MP3 Filename" --inputbox "Output File Name:" 10 100 "output")
output=${outputfile%.*}

# If output file name is empty, clear and exit
if [ -z $outputfile ]
then
	exit2shell
fi

# Firstly, convert input file to wav file then convert temporary wav file to mp3 file and print
# percentage bar
ffmpeg -y -loglevel panic -i $inputfile mp3converter.wav | dialog --gauge "Converting..." 10 100 0
convertWAV=$?
ffmpeg -y -loglevel panic -i mp3converter.wav $output.mp3 | dialog --gauge "Converting..." 10 100 50
convertMP3=$?
sleep 1 | dialog --gauge "Converting..." 10 100 100


echo "WAV: " $convertWAV
echo "MP3: " $convertMP3
# Print the result to user
if [ convertWAV==0 ] && [ convertMP3==0 ]
then
	dialog --infobox "File is converted successfully!" 10 100
else
	dialog --infobox "File could not be converted!" 10 100
fi
sleep 5

# Remove temp wav file and clear terminal
rm mp3converter.wav
clear

