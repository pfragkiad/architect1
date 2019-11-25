#!/bin/bash

./build/ARM/gem5.opt -d bubble_sort_minorcpu_DDR3 configs/example/se.py --cpu-type=MinorCPU --mem-type=DDR3_1600_8x8 --caches -c "tests/my_progs/bubble_sort_arm"
./build/ARM/gem5.opt -d bubble_sort_minorcpu_DDR4 configs/example/se.py --cpu-type=MinorCPU --mem-type=DDR4_2400_8x8  --caches -c "tests/my_progs/bubble_sort_arm"
./build/ARM/gem5.opt -d bubble_sort_timingsimplecpu_DDR3 configs/example/se.py --cpu-type=TimingSimpleCPU --mem-type=DDR3_1600_8x8 --caches -c "tests/my_progs/bubble_sort_arm"
./build/ARM/gem5.opt -d bubble_sort_timingsimplecpu_DDR4 configs/example/se.py --cpu-type=TimingSimpleCPU --mem-type=DDR4_2400_8x8 --caches -c "tests/my_progs/bubble_sort_arm"


