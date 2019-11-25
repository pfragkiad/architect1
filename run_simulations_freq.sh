#!/bin/bash

./build/ARM/gem5.opt -d bubble_sort_minorcpu_1MHz configs/example/se.py --cpu-type=MinorCPU --cpu-clock=1000000 --caches -c "tests/my_progs/bubble_sort_arm"
./build/ARM/gem5.opt -d bubble_sort_minorcpu_2MHz configs/example/se.py --cpu-type=MinorCPU --cpu-clock=2000000  --caches -c "tests/my_progs/bubble_sort_arm"
./build/ARM/gem5.opt -d bubble_sort_timingsimplecpu_1MHz configs/example/se.py --cpu-type=TimingSimpleCPU --cpu-clock=1000000 --caches -c "tests/my_progs/bubble_sort_arm"
./build/ARM/gem5.opt -d bubble_sort_timingsimplecpu_2MHz configs/example/se.py --cpu-type=TimingSimpleCPU --cpu-clock=2000000 --caches -c "tests/my_progs/bubble_sort_arm"


