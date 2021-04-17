#!/bin/sh

# repeat process for the same kind of files in directory 
#
# Usage: repeater.sh [target command] [directory include target preprocess input files]
# target command: any command filter process applicated to [preprocess input files]
# directory: [preprocess input files] exists to applicate [target command] 


# OPTIONS
################################################# input method option #######################################################
# [-p]:flag parameter input ---------------------------- [target command] [pre process input file] 	       [defaule FALSE]
# [-r]:flag file redirect input ------------------------ [target command] < [pre process input file]           [default TRUE]
# [-f]:flag file output -------------------------------- [target command] [file] > [post process output file]  [default FALSE]
#############################################################################################################################

################################################# output file option ########################################################
# [-h value]: head_tag for file name  after process indicator
# [-t value]: tail_tag for file name  after process indicator
# [-a]: flag data add to exist file  --------------------- [command]
#############################################################################################################################



PARM=FALSE
REDICT=FALSE
OUTF=FALSE
FILEADD=FALSE
HEAD=""
TAIL=""
OPT=
which getopts > /dev/null 2>&1
if [ $? -eq 0 ] ;then
	while getopts prfah:t: OPT
	do
	   case $OPT in
		p) PARM=TRUE   
			;;
		r) REDICT=TRUE
			;;
		f) OUTF=TRUE
			;;
		a) FILEADD=TRUE
			;;
		h) HEAD=$OPTARG
			;; 
		t) TAIL=$OPTARG
			;;
		\?) echo "Usage: $0 [-p] [-r] [-t tail_tag]" 1>&2
		    exit 1
			;;
	   esac
	done
	shift `expr $OPTIND - 1`
else 
	while [ $# -gt 0 ] 
	do
	   case $1 in
		-p) PARM=TRUE
		    shift   
			;;
		-r) REDICT=TRUE
		    shift
			;;
		-f) OUTF=TRUE
		    shift
			;;
		-a) FILEADD=TRUE
		    shift
			;;
		-h) HEAD=$2
		    shift 2
			;;	
		-t) TAIL=$2
		    shift 2
			;;
		-t*) TAIL=`echo "$1" | sed 's/^..//'`
		     shift
			;;
		--) shift
		    break
			;;
		-*) echo "Usage: $0 [-p] [-r] [-t tail_tag]" 1>&2
		    exit 1
			;;
		*) break
			;;
	    esac
	done
fi

if [ "$PARM" = "TRUE" -a "$REDICT" = "TRUE" ] ;then
	echo "Usage: $0------ OPTION [-x] must be either [-p] or [-r] [-t tail_tag]" 1>&2
	exit 1
elif [ "$PARM" = "TRUE" -o "$REDICT" = "TRUE" ] ;then
	:
else
	REDICT=TRUE
fi
########################################################################################
########################################################################################

export PATH=${PATH}:`pwd`
COMND=$1
PREFILES=$2
PREFILE=
POSTFILE=
POSTFILES=`pwd`/${PREFILES}_post
LF=$(printf '\n_');LF=${LF%_}

if [ "$OUTF" = "TRUE" ] ;then
	echo "$POSTFILES  <--- Directory include post-process-files "
fi


# write preprocess files name in fileslist.txt to read file by 1 row
ls -l ${PREFILES} | awk 'NR>=2 { print $9 }' > filelist.txt

if [ "$OUTF" = "FALSE" ] ;then
	if [ "$TAIL" != "" ] ;then
		TAIL=${LF}${TAIL}
	fi

	if [ "$HEAD" != "" ] ;then
		HEAD=${HEAD}${LF}
	fi

	if [ "$REDICT" = "TRUE" ] ;then

		# read file by 1 row	 
		while read PREFILE 
		do
			echo "${HEAD}`${COMND} < ${PREFILES}/${PREFILE}`${TAIL}" 
		done < filelist.txt


	elif [ "$PARM" = "TRUE" ] ;then

		# read file by 1 row	 	
		while read PREFILE 
		do
			echo "${HEAD}`${COMND} ${PREFILES}/${PREFILE}`${TAIL}" 
		done < filelist.txt

	else
		echo "Usage: process command directory(files in), check command Usage!!"

	fi
elif [ "$OUTF" =  "TRUE" -a "$FILEADD" = "FALSE" ] ;then
	if [ ! -e {$POSTFILES} ]; then
		mkdir ${POSTFILES}
	fi

	if [ "$REDICT" = "TRUE" ] ;then
		# read file by 1 row	 
		while read PREFILE 
		do
			POSTFILE=$(echo "$PREFILE" | sed 's/^/'"${HEAD}"'/g' | sed 's%\.[^\.]*$%'"${TAIL}"'%g')
			echo "`${COMND} < ${PREFILES}/${PREFILE}`" > ${POSTFILES}/${POSTFILE}
		done < filelist.txt


	elif [ "$PARM" = "TRUE" ] ;then
		# read file by 1 row	 	
		while read PREFILE 
		do
			POSTFILE=$(echo "$PREFILE" | sed 's/^/'"${HEAD}"'/g' | sed 's%\.[^\.]*$%'"${TAIL}"'%g')
			echo "`${COMND} ${PREFILES}/${PREFILE}`"  >  ${POSTFILES}/${POSTFILE}
		done < filelist.txt

	else
		echo "Usage: process command directory(files in), check command Usage!!"

	fi

elif [ "$OUTF" =  "TRUE" -a "$FILEADD" = "TRUE" ] ;then
	if [ ! -e {$POSTFILES} ]; then
		mkdir ${POSTFILES}
	fi

	if [ "$REDICT" = "TRUE" ] ;then
		# read file by 1 row	 
		while read PREFILE 
		do
			POSTFILE=$(echo "$PREFILE" | sed 's/^/'"${HEAD}"'/g' | sed 's%\.[^\.]*$%'"${TAIL}"'%g')
			echo "`${COMND} < ${PREFILES}/${PREFILE}`" >> ${POSTFILES}/${POSTFILE}
		done < filelist.txt


	elif [ "$PARM" = "TRUE" ] ;then
		# read file by 1 row	 	
		while read PREFILE 
		do
			POSTFILE=$(echo "$PREFILE" | sed 's/^/'"${HEAD}"'/g' | sed 's%\.[^\.]*$%'"${TAIL}"'%g')
			echo "`${COMND} ${PREFILES}/${PREFILE}`"  >>  ${POSTFILES}/${POSTFILE}
		done < filelist.txt

	else
		echo "Usage: process command directory(files in), check command Usage!!"

	fi
fi




# delete temporary files 
rm filelist.txt
