#!/bin/bash

# 2013-10-03 Kishore Bhatia
# The purpose of this script is to check for a new occurence of application 
# startup pattern in a continuous rolling app log within a specific timeout
#

# turn bash script debuging on
set -x

PATTERN=$1
TIMEOUT=$2
LOGFILE=$3
PC=$4
echo "Args - $PATTERN, $TIMEOUT, $LOGFILE, $PC"

#PC is the pattern count in the log before you started the app after a fresh deploy or a restart
#PC=$(grep -o "$PATTERN" $LOGFILE| wc -l)

#we'll have 10 iterations to poll for the occurrence of the pattern with a sleep period proportionate to the TIMEOUT
iterations=10 
sleepPeriod=$(( $TIMEOUT/$iterations ))
x=0 #just a counter
rc=1 #initialized the return status to 1 for "pattern not found"
while [ $x -le $iterations ]
do
  echo "Checking pattern for iteration $x"
  patternCountCurrent=$(grep -o "$PATTERN" $LOGFILE| wc -l)
  if [ $patternCountCurrent -gt $PC ]; then
   rc=0
   echo "found: $patternCountCurrent - returning- $rc"
   break
  else
   x=$(( $x + 1 ))
   echo "not found: $patternCountCurrent - RC is $rc"
   sleep $sleepPeriod
  fi
done
exit $rc
