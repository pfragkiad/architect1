# 1η Εργασία Αρχιτεκτονικής Υπολογιστών (Ομάδα 2)

_Παύλος Φραγκιαδουλάκης, ΑΕΜ: 8389_

_Ραφαήλ Μπουλογεώργος, ΑΕΜ: 9186_

## Ερώτημα 1: Παράμετροι του starter_se.py

Στο πρώτο ερώτημα ζητείται η διερεύνηση παραμέτρων που χρησιμοποιούνται από το python script με όνομα starter_se.py. Το αρχείο βρίσκεται μέσα στον υποφάκελο configs/example/arm, ο οποίος με την σειρά του βρίσκεται στον τοπικό φάκελο εγκατάστασης του gem5.
Όπως φαίνεται και από το παρακάτω απόσπασμα του _starter_se.py_, στο σημείο εισόδου του script (συνάρτηση main), προστίθενται στον parser παράμετροι που περιγράφουν το υπολογιστικό σύστημα: 

```python
def main():
    parser = argparse.ArgumentParser(epilog=__doc__)

    parser.add_argument("commands_to_run", metavar="command(s)", nargs='*',
                        help="Command(s) to run")
    parser.add_argument("--cpu", type=str, choices=cpu_types.keys(),
                        default="atomic",
                        help="CPU model to use")
    parser.add_argument("--cpu-freq", type=str, default="4GHz")
    parser.add_argument("--num-cores", type=int, default=1,
                        help="Number of CPU cores")
    parser.add_argument("--mem-type", default="DDR3_1600_8x8",
                        choices=ObjectList.mem_list.get_names(),
                        help = "type of memory to use")
    parser.add_argument("--mem-channels", type=int, default=2,
                        help = "number of memory channels")
    parser.add_argument("--mem-ranks", type=int, default=None,
                        help = "number of memory ranks per channel")
    parser.add_argument("--mem-size", action="store", type=str,
                        default="2GB",
                        help="Specify the physical memory size")
```

Στην συγκεκριμένη περίπτωση απαντώνται τα εξής χαρακτηριστικά (ως προεπιλογές-defaults):
* Τύπος CPU: Atomic (υπονοείται Atomic Simple CPU)
* Συχνότητα CPU: 4 GHz
* Αριθμός πυρήνων: 1
* Τύπος μνήμης: DDR3 με χρονισμό 1600 MHz
* Κανάλια μνήμης: 2
* Μέγεθος μνήμης: 2 GB
* Μέγεθος cache line: 64 bytes
* Clock domain: 1 GHz
* Voltage domain: 3.3 V
* Full system: False

Στον κώδικα του ίδιου αρχείου στον constructor της κλάσης SimpleSeSystem (```def __init__()```), βλέπουμε ότι χρησιμοποιείται μία ιεραρχία μνημών cache που συμπεριλαμβάνει L1 και L2 μνήμη εκ των οποίων η πρώτη είναι private ενώ η δεύτερη είναι shared ανάμεσα στους πυρήνες (σε περίπτωση που επιλεχθεί αριθμός πυρήνων μεγαλύτερος του 1). Η εντολή με την οποία πέρασε το script στον προσομοιωτή του gem5 (gem5.opt) πέρασε με το όρισμα *cpu="minor"* το οποίο σημαίνει ότι παρακάμφθηκε η default επιλογή του Atomic που αναφέρεται παραπάνω και επιλέχθηκε ο τύπος Minor (δηλαδή Minor CPU). Τόσο η επιλογή του Atomic όσο και η επιλογή του Minor CPU ανήκουν στην κατηγορία των in-order [CPU models](https://raw.githubusercontent.com/arm-university/arm-gem5-rsk/master/gem5_rsk.pdf).

## Ερώτημα 2: Ανάλυση των αρχείων config.ini και config.json

Τα αρχεία αυτά παράγονται στον default φάκελο m5out, εκτός αν δοθεί άλλος φάκελος μέσω της παραμέτρου -d κατά την κλήση του gem5. Στην συγκεκριμένη περίπτωση με βάση την παρακάτω κλήση η έξοδος ήταν στον φάκελο myprog_result (ο οποίος βρίσκεται μέσα στον φάκελο εγκατάστασης του gem5):
```bash
./build/ARM/gem5.opt -d myprog_result configs/example/arm/starter_se.py --cpu="minor" "tests/my_progs/myprog_arm"
```
Στο αρχείο config.ini απαντώνται οι παρακάτω τιμές για παραμέτρους που αντιστοιχούν σε εκείνες του Ερωτήματος 1:
* [root/full_system] false
* [system/mem_ranges] 0:2147483647 (αριθμός θέσεων = 2^31 = 2 GB)
* [system/cache_line_size] 64
* [system.clk_domain/clock] 1000 
* [system.cpu_cluster.cpus] MinorCPU

## Ερώτημα 3: Δοκιμή με custom πρόγραμμα σε C και αναφορά στα in-order μοντέλα
Τα in-order CPU μοντέλα, όπως χρησιμοποιούνται από το gem5 είναι τα παρακάτω:
* Minor CPU: Είναι ένας in-order επεξεργαστής ο οποίος πρωτογενώς αναπτύχθηκε για την υποστήριξη της αρχιτεκτονικής ARM ISA ([System Modeling using gem5](https://raw.githubusercontent.com/arm-university/arm-gem5-rsk/master/gem5_rsk.pdf)). Περιλαμβάνει ένα pipeline 4 σταδίων. Αποτελεί την βάση για τη μελέτη επεξεργαστή με χρήση cache μνημών.

![MinorCPU pipeline](/img/minorcpu_pipeline.png)

* Base Simple CPU: περιλαμβάνει απλοποιημένες εκδοχές επεξεργαστών των οποίων η χρήση ενδείκνυται για απλές δοκιμές, όταν μας ενδιαφέρει ένα συγκεκριμένο κομμάτι της προσομοίωσης ([System Modeling using gem5](https://raw.githubusercontent.com/arm-university/arm-gem5-rsk/master/gem5_rsk.pdf)). Στο απλοποιημένο αυτό μοντέλο δεν υπάρχει pipeline. Ανάλογα με τον τύπο πρόσβασης στη μνήμη διακρίνουμε τις παρακάτω δύο περιπτώσεις ([gem5.org](http://gem5.org/SimpleCPU)):
  * Atomic Simple CPU: Δεν χρησιμοποιεί χρονισμό με ουρά και έτσι χρησιμοποιείται για τις περιπτώσεις που μας ενδιαφέρει αμιγώς ο χρόνος εκτέλεσης ενός κώδικα (atomic accesses).
  * Timing Simple CPU: Αποτελεί πιο ρεαλιστική προσέγγιση σε σχέση με την Atomic, επειδή χρησιμοποιείται χρονισμός και έτσι μοντελοποιείται η καθυστέρηση πρόσβασης στη μνήμη λόγω σχηματισμού ουράς και χρήση κοινόχρηστων πόρων.
Μία συγκριτική απεικόνιση των Atomic και Timing Simple προσεγγίσεων εμφανίζεται στην παρακάτω εικόνα:

![Atomic vs TimingSimple](/img/atomic_vs_timingsimple.png)

### α) Πρόγραμμα σε C

Για τον σκοπό της ανάλυσης, γράφτηκε ένα πρόγραμμα το οποίο υλοποιεί την Bubble Sort  ([code](/code/bubble_sort.c)) σε έναν πίνακα που αποτελείται από τυχαίους ακέραιους αριθμούς. Για λόγους παραμετροποίησης, αν δοθεί ως παράμετρος μία τιμή π.χ. 200 τότε αυτή υποδηλώνει το μέγεθος του πίνακα προς ταξινόμηση. Αν δεν δοθεί παράμετρος στην κλήση, τότε θεωρείται ως default τιμή το 100, όπως φαίνεται από το παρακάτω σημείο εκκίνησης του προγράμματος:
```c
//Driver program
int main(int argc, char** argv) 
{ 
   //we allow the user to give a custom size for the array
   size_t n = argc == 2 ? atoi(argv[1]) : 100;
```

Συνήθη benchmarks είναι ο πολλαπλασιασμός πινάκων, η bubble sort και η quick sort (βλ. [Sajjan G. Shiva - Computer Organization, Design, and Architecture, Fifth Edition](https://books.google.gr/books?id=m5KlAgAAQBAJ&pg=PA656&lpg=PA656&dq=benchmarks+bubblesort+matrix+multiplication&source=bl&ots=KpOh2HSryS&sig=ACfU3U0Puw-jreZoyFZjayeqLBcDKBXslA&hl=en&sa=X&ved=2ahUKEwjw2vq7kPjlAhXBZ1AKHfN0C5UQ6AEwBHoECAkQAQ#v=onepage&q=benchmarks%20bubblesort%20matrix%20multiplication&f=false)). Η μεταγλώττιση του προγράμματος έγινε με τον _gcc_ (για λόγους αποσφαλμάτωσης) και με τον cross compiler για ARM _arm-linux-gnueabihf-gcc_ προκειμένου να μπορεί να χρησιμοποιηθεί το εκτελέσιμο από τον προσομοιωτή του ARM:
```bash
gcc bubble_sort.c -o bubble_sort
arm-linux-gnueabihf-gcc --static bubble_sort.c -o bubble_sort_arm
```
Για τον σκοπό του ερωτήματος (α) δημιουργήθηκε ένα bash script ([run_simulations_first.sh](run_simulations_first.sh)) στο οποίο εκτελέστηκε με δυο διαφορετικές CPU, το πρόγραμμα του bubble sort. Η σύνταξη που δέχεται το _se.py_ είναι ελαφρώς διαφορετική από αυτή που αναφέρεται στην διατύπωση της εργασίας. Για την σωστή σύνταξη ερευνήθηκαν οι σωστές παράμετροι με την βοήθεια της παρακάτω εντολής:
```bash
./build/ARM/gem5.opt configs/example/se.py -h
```
Έτσι, για να περαστούν οι σωστές παράμετροι πρέπει να περαστεί η παράμετρος --cpu-type (και όχι --cpu) καθώς και το -c πριν το όνομα του εκτελέσιμου arm προγράμματος. Οι τελικές εντολές που εκτελέστηκαν είναι οι:
```bash
#!/bin/bash
./build/ARM/gem5.opt -d bubble_sort_minorcpu configs/example/se.py --cpu-type=MinorCPU --caches -c "tests/my_progs/bubble_sort_arm"
./build/ARM/gem5.opt -d bubble_sort_timingsimplecpu configs/example/se.py --cpu-type=TimingSimpleCPU --caches -c "tests/my_progs/bubble_sort_arm"
```
Το output του προγράμματος μετά την εκτέλεση του προσομοιωτή gem5 στο stdout ενδεικτικά είναι το παρακάτω:
```
gem5 Simulator System.  http://gem5.org
gem5 is copyrighted software; use the --copyright option for details.

gem5 compiled Nov 12 2019 13:56:04
gem5 started Nov 25 2019 02:48:55
gem5 executing on pavfrang, pid 5460
command line: ./build/ARM/gem5.opt -d bubble_sort_minorcpu configs/example/se.py --cpu-type=MinorCPU --caches -c tests/my_progs/bubble_sort_arm

Global frequency set at 1000000000000 ticks per second
**** REAL SIMULATION ****
Unsorted array:
83 86 77 15 93 35 86 92 49 21 62 27 90 59 63 26 40 26 72 36 11 68 67 29 82 30 62 23 67 35 29 2 22 58 69 67 93 56 11 42 29 73 21 19 84 37 98 24 15 70 13 26 91 80 56 73 62 70 96 81 5 25 84 27 36 5 46 29 13 57 24 95 82 45 14 67 34 64 43 50 87 8 76 78 88 84 3 51 54 99 32 60 76 68 39 12 26 86 94 39 
Sorted array:
2 3 5 5 8 11 11 12 13 13 14 15 15 19 21 21 22 23 24 24 25 26 26 26 26 27 27 29 29 29 29 30 32 34 35 35 36 36 37 39 39 40 42 43 45 46 49 50 51 54 56 56 57 58 59 60 62 62 62 63 64 67 67 67 67 68 68 69 70 70 72 73 73 76 76 77 78 80 81 82 82 83 84 84 84 86 86 86 87 88 90 91 92 93 93 94 95 96 98 99 
Exiting @ tick 218400000 because exiting with last active thread context
```
Μετά την εκτέλεση δημιουργήθηκαν 2 φάκελοι με τα ονόματα _bubble\_sort\_minorcpu_ και _bubble\_sort\_timingsimplecpu_ για Minor CPU και Timing Simple CPU αντίστοιχα. Ακολουθεί το πρώτο κομμάτι του αρχείου stats.txt για τον επεξεργαστή τύπου Minor CPU: 
```
---------- Begin Simulation Statistics ----------
final_tick                                  218400000                       # Number of ticks from beginning of simulation (restored from checkpoints and never reset)
host_inst_rate                                  76867                       # Simulator instruction rate (inst/s)
host_mem_usage                                 702976                       # Number of bytes of host memory used
host_op_rate                                    83400                       # Simulator op (including micro ops) rate (op/s)
host_seconds                                     4.31                       # Real time elapsed on the host
host_tick_rate                               50719244                       # Simulator tick rate (ticks/s)
sim_freq                                 1000000000000                       # Frequency of simulated ticks
sim_insts                                      330975                       # Number of instructions simulated
sim_ops                                        359118                       # Number of ops (including micro ops) simulated
sim_seconds                                  0.000218                       # Number of seconds simulated
sim_ticks                                   218400000                       # Number of ticks simulated
system.cpu.branchPred.BTBCorrect                    0                       # Number of correct BTB predictions (this stat may not work properly.
system.cpu.branchPred.BTBHitPct             59.673032                       # BTB Hit Percentage
system.cpu.branchPred.BTBHits                   22156                       # Number of BTB hits
system.cpu.branchPred.BTBLookups                37129                       # Number of BTB lookups
system.cpu.branchPred.RASInCorrect                  5                       # Number of incorrect RAS predictions.
system.cpu.branchPred.condIncorrect              2036                       # Number of conditional branches incorrect
system.cpu.branchPred.condPredicted             31161                       # Number of conditional branches predicted
system.cpu.branchPred.indirectHits               1223                       # Number of indirect target hits.
system.cpu.branchPred.indirectLookups            2173                       # Number of indirect predictor lookups.
system.cpu.branchPred.indirectMisses              950                       # Number of indirect misses.
system.cpu.branchPred.lookups                   47041                       # Number of BP lookups
system.cpu.branchPred.usedRAS                    5365                       # Number of times the RAS was used to get a target.
system.cpu.branchPredindirectMispredicted           82                       # Number of mispredicted indirect branches.
system.cpu.committedInsts                      330975                       # Number of instructions committed
system.cpu.committedOps                        359118                       # Number of ops (including micro ops) committed
system.cpu.cpi                               1.319737                       # CPI: cycles per instruction
...
...
system.cpu.numCycles                           436800                       # number of cpu cycles simulated

```
Στη συνέχεια ακολουθεί το πρώτο κομμάτι του αρχείου stats.txt για τον επεξεργαστή τύπου Timing Simple CPU:
```
---------- Begin Simulation Statistics ----------
final_tick                                  531754000                       # Number of ticks from beginning of simulation (restored from checkpoints and never reset)
host_inst_rate                                 213628                       # Simulator instruction rate (inst/s)
host_mem_usage                                 701440                       # Number of bytes of host memory used
host_op_rate                                   230986                       # Simulator op (including micro ops) rate (op/s)
host_seconds                                     1.55                       # Real time elapsed on the host
host_tick_rate                              344033032                       # Simulator tick rate (ticks/s)
sim_freq                                 1000000000000                       # Frequency of simulated ticks
sim_insts                                      330132                       # Number of instructions simulated
sim_ops                                        357007                       # Number of ops (including micro ops) simulated
sim_seconds                                  0.000532                       # Number of seconds simulated
sim_ticks                                   531754000                       # Number of ticks simulated
system.cpu.Branches                             43401                       # Number of branches fetched
system.cpu.committedInsts                      330132                       # Number of instructions committed
system.cpu.committedOps                        357007                       # Number of ops (including micro ops) committed
...
...
system.cpu.not_idle_fraction                 1.000000                       # Percentage of non-idle cycles
system.cpu.numCycles                          1063508                       # number of cpu cycles simulated
system.cpu.numWorkItemsCompleted                    0                       # number of work items this cpu completed
system.cpu.numWorkItemsStarted                      0                       # number of work items this cpu started
system.cpu.num_busy_cycles               1063507.998000                       # Number of busy cycles
system.cpu.num_cc_register_reads              1390903                       # number of times the CC registers were read
system.cpu.num_cc_register_writes              229631                       # number of times the CC registers were written
system.cpu.num_conditional_control_insts        29475                       # number of instructions that are conditional controls
system.cpu.num_fp_alu_accesses                      0                       # Number of float alu accesses
system.cpu.num_fp_insts                             0                       # number of float instructions
system.cpu.num_fp_register_reads                    0                       # number of times the floating registers were read
system.cpu.num_fp_register_writes                   0                       # number of times the floating registers were written
system.cpu.num_func_calls                       10448                       # number of times a function call or return occured
system.cpu.num_idle_cycles                   0.002000                       # Number of idle cycles
system.cpu.num_int_alu_accesses                322655                       # Number of integer alu accesses
system.cpu.num_int_insts                       322655                       # number of integer instructions
system.cpu.num_int_register_reads              554656                       # number of times the integer registers were read
system.cpu.num_int_register_writes             246083                       # number of times the integer registers were written
system.cpu.num_load_insts                      109039                       # Number of load instructions
system.cpu.num_mem_refs                        153548                       # number of memory refs
system.cpu.num_store_insts                      44509                       # Number of store instructions
```
### β) Διαφορές των τρεξιμάτων στις 2 CPU
Παρατηρούμε ότι το τρέξιμο για το Minor CPU ολοκληρώθηκε στα 218 μs, έναντι των 532 μs του Timing Simple CPU. Η διαφορά είναι αναμενόμενη, γιατί η Minor CPU χρησιμοποιεί pipeline 4 σταδίων, ενώ η Timing Simple CPU στην πράξη λειτουργεί σειριακά χωρίς pipeline, συνεπώς η τελευταία είναι σίγουρα πιο αργή στην εκτέλεση.
### γ) Παραλλαγές παραμέτρων στις 2 CPU
Εξετάστηκαν δύο διαφορετικές παραλλαγές παραμέτρων:
#### Αλλαγή τεχνολογίας μνήμης
Για τη διερεύνηση των διαφόρων δυνατοτήτων ως προς την επιλογή τύπων μνήμης, κλήθηκε η παρακάτω εντολή:
```bash
./build/ARM/gem5.opt configs/example/se.py --list-mem-types
```
Η έξοδος της εντολής έδωσε τους παρακάτω διαθέσιμους τύπους μνήμης:
```
Available AbstractMemory classes:
	HBM_1000_4H_1x128
	DRAMCtrl
	DDR3_2133_8x8
	HBM_1000_4H_1x64
	GDDR5_4000_2x32
	HMC_2500_1x32
	LPDDR3_1600_1x32
	WideIO_200_1x128
	QoSMemSinkCtrl
	DDR4_2400_8x8
	DDR3_1600_8x8
	DDR4_2400_4x16
	DDR4_2400_16x4
	SimpleMemory
	LPDDR2_S4_1066_1x32
```
Για τις δοκιμές, επιλέχθηκαν οι τύποι _DDR3_1600_8x8_ και _DDR4_2400_8x8_. Συνολικά εκτελέστηκαν 4 σενάρια όπως φαίνεται και από τις παρακάτω εντολές ([run_simulations_mem.sh](run_simulations_mem.sh)):
```bash
#!/bin/bash
./build/ARM/gem5.opt -d bubble_sort_minorcpu_DDR3 configs/example/se.py --cpu-type=MinorCPU --mem-type=DDR3_1600_8x8 --caches -c "tests/my_progs/bubble_sort_arm"
./build/ARM/gem5.opt -d bubble_sort_minorcpu_DDR4 configs/example/se.py --cpu-type=MinorCPU --mem-type=DDR4_2400_8x8  --caches -c "tests/my_progs/bubble_sort_arm"
./build/ARM/gem5.opt -d bubble_sort_timingsimplecpu_DDR3 configs/example/se.py --cpu-type=TimingSimpleCPU --mem-type=DDR3_1600_8x8 --caches -c "tests/my_progs/bubble_sort_arm"
./build/ARM/gem5.opt -d bubble_sort_timingsimplecpu_DDR4 configs/example/se.py --cpu-type=TimingSimpleCPU --mem-type=DDR4_2400_8x8 --caches -c "tests/my_progs/bubble_sort_arm"
```
Τα αποτελέσματα ως προς τους χρόνους εκτέλεσης συνοψίζονται παρακάτω:

CPU Type|Memory|Simulation time [μs]
--------|------|-------------------
MinorCPU|DDR3_1600_8x8|218
MinorCPU|DDR4_2400_8x8|217
TimingSimpleCPU|DDR3_1600_8x8|532
TimingSimpleCPU|DDR4_2400_8x8|531

Παρατηρούμε ότι η αλλαγή της μνήμης από DDR3 σε DDR4 επιφέρει μία αμελητέα βελτίωση στον χρόνο εκτέλεσης και στα δύο μοντέλα, γεγονός που σημαίνει ότι η μνήμη δεν είναι ο κρίσιμος πόρος όσον αφορά το συγκεκριμένο πρόγραμμα που επιλέχθηκε προς εκτέλεση.

#### Αλλαγή συχνότητας CPU
Για την διερεύνηση της επίπτωσης αλλαγής της συχνότητας της CPU χρησιμοποιήθηκε η παράμετρος --cpu-clock. Στα συγκεκριμένα σενάρια, επιλέχθηκαν ταχύτητες 1 MHz και 2 MHz για τους ίδιους επεξεργαστές. Συνολικα εκτελέστηκαν 4 σενάρια όπως φαίνεται και παρακάτω ([run_simulations_freq.sh](run_simulations_freq.sh)):
```bash
#!/bin/bash
./build/ARM/gem5.opt -d bubble_sort_minorcpu_1MHz configs/example/se.py --cpu-type=MinorCPU --cpu-clock=1000000 --caches -c "tests/my_progs/bubble_sort_arm"
./build/ARM/gem5.opt -d bubble_sort_minorcpu_2MHz configs/example/se.py --cpu-type=MinorCPU --cpu-clock=2000000  --caches -c "tests/my_progs/bubble_sort_arm"
./build/ARM/gem5.opt -d bubble_sort_timingsimplecpu_1MHz configs/example/se.py --cpu-type=TimingSimpleCPU --cpu-clock=1000000 --caches -c "tests/my_progs/bubble_sort_arm"
./build/ARM/gem5.opt -d bubble_sort_timingsimplecpu_2MHz configs/example/se.py --cpu-type=TimingSimpleCPU --cpu-clock=2000000 --caches -c "tests/my_progs/bubble_sort_arm"
```
Τα αποτελέσματα ως προς τους χρόνους εκτέλεσης συνοψίζονται παρακάτω:

CPU Type|CPU Frequency [MHz]|Simulation time [s]
--------|------|-------------------
MinorCPU|1|0.378079
MinorCPU|2|0.189039
TimingSimpleCPU|1|1.009204
TimingSimpleCPU|2|0.504602

Σε αντίθεση με την περίπτωση της μνήμης, παρατηρούμε ότι ο διπλασιασμός της συχνότητας της CPU, υποδιπλασιάζει τον χρόνο εκτέλεσης και στους δύο επεξεργαστές, το οποίο σημαίνει ότι ο κρίσιμος πόρος στο συγκεκριμένο πρόγραμμα είναι η συχνότητα της CPU.

## Κριτική για την εργασία
Τα καινούρια θέματα με τα οποία εξοικειωθήκαμε ως συγγραφείς της εργασίας είναι:
* Η cross μεταγλώττιση προγραμμάτων από X86 σε ARM.
* Η γνωριμία με τους βασικούς τύπους επεξεργαστή του gem5.
* Η παραμετροποίηση βασικών παραμέτρων όπως η ταχύτητα του επεξεργαστή και η μνήμη στην προσομοίωση του gem5.
* Η αξιοποίηση βασικών αποτελεσμάτων της προσομοίωσης μέσω των αρχείων stats.txt.

Λοιπές παρατηρήσεις για την εργασία:
* Η εργασία ήταν σχετικά απλή, αλλά είναι σημαντικό να αναφερθεί ότι βρήκαμε το documentation του gem5 αρκετά ελλιπές.
* Γενικά υπάρχει λίγο υλικό στο διαδίκτυο για το gem5, ενώ δεν βρήκαμε κάποια (έντυπη) βιβλιογραφία στην οποία να αναφέρεται πώς χρησιμοποιείται το λογισμικό gem5.
