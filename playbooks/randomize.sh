#!/bin/bash
RANDNUM="`shuf -i 20000-50000 -n 1`"
cp vars.yml vars-$RANDNUM.yml
sed -i "s/RANDOM/$RANDNUM/g" vars-$RANDNUM.yml
echo "Your random number vars file is vars-$RANDNUM.yml"
