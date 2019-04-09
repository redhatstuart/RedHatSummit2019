#!/bin/bash
RANDNUM="`shuf -i 20000-50000 -n 1`"
cp vars.yml vars-myvars.yml
sed -i "s/RANDOM/$RANDNUM/g" vars-myvars.yml
echo "Your random number vars file is vars-myvars.yml"
