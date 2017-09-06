#!/bin/bash

# move & rename video files to a folder


########## example
#################### Chinese
# [阳光电影www.ygdy8.com].绣春刀II：修罗战场.HD.720p.国语中字.mkv
#################### with space
# Man in steel 2007.mp4
#################### with dot
# Transform.3.2011.1080p.BrRip.x264.YIFY.mp4



# ================================
Space2At(){
	noSpace=$(sed 's# #@#g' <<< $1)
	return $noSpace
}
# ================================
At2Space(){
	path=$1
	path=$(sed 's#@# #g' <<< $path)
	echo $path
}
# ================================
At2Dot(){
	path=$1
	path=$(sed 's#@#.#g' <<< $path)
	echo $path
}
# ================================
addSpaceAfterFileType(){
	# echo $1 $2
	path=$1
	filetypes=$2
	path=$(sed "s# #@#g" <<< $path)
	for filetype in ${filetypes[*]}
	do
		path=$(sed "s#.${filetype}@#.${filetype} #g" <<< $path)
	done
	echo $path
}
# ================================
addSlashBeforeSymb(){
	OgPath=$1
	symbols=$2

	for ((i=0;i<${#symbols[@]};i++))
	do
      s=${symbols[$i]}
      OgPath=$(sed "s#${s}#%${s}#g" <<< $OgPath)
	done
	OgPath=$(sed 's#%#\\#g' <<< $OgPath)
	echo $OgPath
}
# ================================
addSlashBeforeSpace(){
	OgPath=$1
    OgPath=$(sed 's#\ #\\ #g' <<< $OgPath)
	echo $OgPath
}
# ================================
removeSymbols(){
	videoName=$1
	symbols=$2

	for ((i=0;i<${#symbols[@]};i++))
	do
      s=${symbols[$i]}
      videoName=$(sed "s#${s}##g" <<< $videoName)
	done
	echo $videoName
}
# ================================
removeKeywords(){
	videoName=$1
	keywords=$2
	

	for ((i=0;i<${#keywords[@]};i++))
	do
		word=${keywords[$i]}
		videoName=$(sed "s#.${word}##g" <<< $videoName)
	done
	echo $videoName
}

userInputCorrection(){
	userInput=$1
	userInput=`echo $userInput|sed 's#/$##g'`
	echo $userInput
}
# ================================
####	find files
# path="/volume1/Studyz/Downloads"
# dstPath="/volume1/Studyz/Downloads/mv"
# path="/Volumes/Studyz/Downloads"
# dstPath="/Volumes/Studyz/Downloads"

echo "Please enter source folder path: "
read path

if [[ ! -d $path ]];then
	echo "source folder path not exist!"
else
	if [[ $path=~"/$" ]]
	then
		path=`userInputCorrection "$path"`
	fi


	echo "Please enter Destination folder path: "
	read dstPath

	file_count=0

	####	read keywords from external file
	keywords=(`cat keyword.dat`)

	####	read filetypes from external file
	filetypes=(`cat filetypes.dat`)
	####	read symbols from external file
	symbols=(`cat symbols.dat`)


	#### test destnation folder exist or create
	if [[ ! -d $dstPath ]];then
		mkdir "$dstPath"
	fi

	if [[ $dstPath=~"/$" ]]
	then
		dstPath=`userInputCorrection "$dstPath"`
	fi

	dstPathCode=`addSlashBeforeSpace "$dstPath"`

	####	read all file names by file type
	for type in ${filetypes[*]}
	do
		videoPaths+=`find $path -name "*.${type}"`" "
	done



	videoPaths=$(sed "s# #@#g" <<< $videoPaths)

	####	handle string->change 'space' to '@' AND change 'file type' to 'space' for slpit
	# addSpaceAfterFileType "$videoPaths" "${filetypes[*]}"
	PathArray=(`addSpaceAfterFileType "$videoPaths" ${filetypes[*]}`)

	# =====================================

	if [[ ${#PathArray[@]} -eq 0 ]]
	then
		echo "No videos found!"
		break
	else
		printf ""${#PathArray[@]}" videos found!!\n\n"
		printf ""${#keywords[@]}" keywords, "${#symbols[@]}" symbols and "${#filetypes[@]}" filetypes read from database!!\n"
		printf "=================(-_-)===================\n"
	fi

	# =====================================
	for PathName in ${PathArray[*]}
	do
		oldpath=`At2Space "$PathName"`

		oldpath=`addSlashBeforeSpace "$oldpath"`
		
		oldpath=`addSlashBeforeSymb "$oldpath" ${symbols[*]}`

		# echo $oldpath
		
		slashArray=(`echo $PathName | sed 's#/# #g'`)
		for videoFile in ${slashArray[*]}
		do
			# ==============	?	=========================
			# if [[ ${filetypes[*]} =~ "${videoFile}" ]]; then
			for type in ${filetypes[*]}
			do

				if [[ $videoFile =~ $type ]]; then
					((file_count++))
					videoFile=`At2Dot "$videoFile"`
					videoname=`removeSymbols "$videoFile" ${symbols[*]}`
					Nname=`removeKeywords "$videoname" ${keywords[*]}`
					newPath=$dstPathCode/$Nname
					newPath=`addSlashBeforeSymb "$newPath" ${symbols[*]}`
					echo mv $oldpath $newPath
				fi
			done
		done
	done


	if [[ $file_count != 0 ]]
	then
		echo "=========================================="
		echo $file_count found! and will move to $dstPath
		echo "=========================================="
	fi
fi

