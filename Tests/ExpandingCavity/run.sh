#!/bin/bash
#set -x


./run-2dtest.sh 0.5e-4 16 1 F
#rm -fr *.gif
./gnmovie.sh
./volumeplot.sh
