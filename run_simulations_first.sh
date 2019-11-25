#!/bin/bash

#check for help
#./build/ARM/gem5.opt configs/example/se.py -h

./build/ARM/gem5.opt -d bubble_sort_minorcpu configs/example/se.py --cpu-type=MinorCPU --caches -c "tests/my_progs/bubble_sort_arm"
./build/ARM/gem5.opt -d bubble_sort_timingsimplecpu configs/example/se.py --cpu-type=TimingSimpleCPU --caches -c "tests/my_progs/bubble_sort_arm"


