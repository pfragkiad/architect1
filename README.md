# 1η Εργασία Αρχιτεκτονικής Υπολογιστών
_Παύλος Φραγκιαδουλάκης, ΑΕΜ: 8389_

_Ραφαήλ Μπουλογεώργος, ΑΕΜ: 9186_

## Ερώτημα 1: Παράμετροι του starter_se.py

Στο πρώτο ερώτημα ζητείται η διερεύνηση παραμέτρων που χρησιμοποιούνται από το python script με όνομα starter_se.py. Το αρχείο βρίσκεται μέσα στον υποφάκελο configs/eample/arm, ο οποίος με την σειρά του βρίσκεται στον τοπικό φάκελο εγκατάστασης του gem5.
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
* MinorCPU: Είναι ένας in-order επεξεργαστής ο οποίος πρωτογενώς αναπτύχθηκε για την υποστήριξη της αρχιτεκτονικής ARM ISA ([System Modeling using gem5](https://raw.githubusercontent.com/arm-university/arm-gem5-rsk/master/gem5_rsk.pdf)). Περιλαμβάνει μία σωλήνωση 4 σταδίων. Αποτελεί την βάση για τη μελέτη επεξεργαστή με χρήση cache μνημών.

![MinorCPU pipeline](/img/minorcpu_pipeline.png)

* SimpleCPU: περιλαμβάνει απλοποιημένες εκδοχές επεξεργαστών των οποίων η χρήση ενδείκνυται για απλές δοκιμές, όταν μας ενδιαφέρει ένα συγκεκριμένο κομμάτι της προσομοίωσης ([System Modeling using gem5](https://raw.githubusercontent.com/arm-university/arm-gem5-rsk/master/gem5_rsk.pdf))
  * AtomicSimpleCPU:   ([gem5.org](http://gem5.org/SimpleCPU))

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
Για τον σκοπό του ερωτήματος (α) δημιουργήθηκε ένα bash script ([runsimulations.sh](runsimulations.sh)) στο οποίο εκτελέστηκε με δυο διαφορετικές CPU, το πρόγραμμα του bubble sort:
```bash
#!/bin/bash
./build/ARM/gem5.opt -d bubble_sort_minorcpu configs/example/se.py --cpu-type=MinorCPU --caches -c "tests/my_progs/bubble_sort_arm"
./build/ARM/gem5.opt -d bubble_sort_timingsimplecpu configs/example/se.py --cpu-type=TimingSimpleCPU --caches -c "tests/my_progs/bubble_sort_arm"
```
Μετά την εκτέλεση δημιουργήθηκαν 2 φάκελοι με τα ονόματα _bubble\_sort\_minorcpu_ και _bubble\_sort\_timingsimplecpu_ για MinorCPU και TimingSimpleCPU αντίστοιχα. Ακολουθεί το πρώτο κομμάτι του αρχείου stats.txt για τον επεξεργαστή τύπου MinorCPU: 
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
Στη συνέχεια ακολουθε το πρώτο κομμάτι του αρχείου stats.txt για τον επεξεργαστή τύπου TimingSimpleCPU:
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
β) Διαφορές των τρεξιμάτων στις 2 CPU
Παρατηρούμε ότι το τρέξιμο για το MinorCPU ολοκληρώθηκε στα 218 μs, έναντι των 532 μs του TimingSimpleCPU. Η διαφορά είναι αναμενόμενη, γιατί η MinorCPU χρησιμοποιεί pipeline 4 σταδίων
//http://learning.gem5.org/book/part1/example_configs.html


