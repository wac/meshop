#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -S /bin/bash
#$ -v PATH
#$ -l h_vmem=90G
#$ -l h_stack=256M
#

# This script file is for starting the Makefiles using the Sun Grid Engine

#MAX_JOBS=200
MAX_JOBS=50

date
qmake -inherit -- -j $MAX_JOBS $1 $2 $3 $4 $5 $6 $7 $8 $9
#qmake -- -j $MAX_JOBS $1 $2 $3 $4 $5 $6 $7 $8 $9
#qmake -pe meshop $MAX_JOBS-200 -- $1 $2 $3 $4 $5 $6 $7 $8 $9
date
