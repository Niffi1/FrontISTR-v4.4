#!/bin/sh

test=test_exM
prg=../test_heat_sub.sh
test_log="test.log"

run_2d () {
	echo "NO 2D MODEL"
}


run_3d () {
	${prg} ${test_log} MA361 A
	${prg} ${test_log} MB361 B
	${prg} ${test_log} MC361 C
	${prg} ${test_log} MD361 D
	${prg} ${test_log} ME361 E
	${prg} ${test_log} MF361 F
	${prg} ${test_log} MG361 G
}

run_shell() {
	echo "NO SHELL MODEL"
}


help () {
	echo "FrontSTR executing test"
	echo "[usage] ${test} (options)"
	echo " -h      : help (this message)"
	echo "  2d     : 2 dimentional model"
	echo "  3d     : 3 dimentional model"
	echo "  shell  : shell model"
	echo "  all or no options : all model" 
}


############################# MAIN ################################

echo "Max/Min Temperature" > ${test_log}

if [ $# -lt 1 -o "${1}" = "all" ]; then
	run_2d
	run_3d
	run_shell
	exit
fi

for i in $*
do
	if   [ "${i}" = "-h"    ]; then
		help
		exit
	elif [ "${i}" = "-l"    ]; then
		list_up
		exit
	elif [ "${i}" = "2d"    ]; then run_2d
	elif [ "${i}" = "3d"    ]; then run_3d
	elif [ "${i}" = "shell" ]; then run_shell
	else
		echo "## Error in ${0}: unknown parameter ${i}"
		echo "   show help with -h"
		exit
	fi
done
