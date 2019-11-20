Παύλος Φραγκιαδουλάκης, ΑΕΜ: 8389
Ραφαήλ Μπουλογεώργος, ΑΕΜ: 9186


# 1η Εργασία Αρχιτεκτονικής Υπολογιστών
## Ερώτημα 1: Παράμετροι του starter_se.py

Στο πρώτο ερώτημα ζητείται η διερεύνηση παραμέτρων που χρησιμοποιούνται από το python script με όνομα starter_se.py. Το αρχείο βρίσκεται μέσα στον υποφάκελο configs/eample/arm, ο οποίος με την σειρά του βρίσκεται στον τοπικό φάκελο εγκατάστασης του gem5.
Όπως φαίνεται και από το παρακάτω screenshot, στο σημείο εισόδου του script (συνάρτηση main), προστίθενται στον parser παράμετροι που περιγράφουν το υπολογιστικό σύστημα: 

![starter_se.py](/screenshots/starter_se.png)

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

Στον κώδικα του ίδιου αρχείου στον constructor της κλάσης SimpleSeSystem (```def __init__()```), βλέπουμε ότι χρησιμοποιείται μία ιεραρχία μνημών cache που συμπεριλαμβάνει L1 και L2 μνήμη εκ των οποίων η πρώτη είναι private ενώ η δεύτερη είναι shared ανάμεσα στους πυρήνες (σε περίπτωση που επιλεχθεί αριθμός πυρήνων μεγαλύτερος του 1). Η εντολή με την οποία πέρασε το script στον προσομοιωτή του gem5 (gem5.opt) πέρασε με το όρισμα *cpu="minor"* το οποίο σημαίνει ότι παρακάμφθηκε η default επιλογή του Atomic που αναφέρεται παραπάνω και επιλέχθηκε ο τύπος Minor (δηλαδή Minor CPU). Τόσο η επιλογή του Atomic όσο και η επιλογή του Minor CPU ανήκουν στην κατηγορία των in-order CPU models ([CPU models](https://raw.githubusercontent.com/arm-university/arm-gem5-rsk/master/gem5_rsk.pdf)).

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

### α) Πρόγραμμα σε C
Για τον σκοπό της ανάλυσης, γράφτηκε ένα πρόγραμμα το οποίο υλοποιεί την Bubble Sort  ([code](/code/bubble_sort.c)) σε έναν πίνακα που αποτελείται από τυχαίους ακέραιους αριθμούς. Για λόγους παραμετροποίησης, αν δοθεί ως παράμετρος μία τιμή π.χ. 200 τότε αυτή υποδηλώνει το μέγεθος του πίνακα προς ταξινόμηση. Αν δεν δοθεί παράμετρος στην κλήση, τότε θεωρείται ως default τιμή το 100. Συνήθη benchmarks είναι ο πολλαπλασιασμός πινάκων, η bubble sort και η quick sort (βλ. [Sajjan G. Shiva - Computer Organization, Design, and Architecture, Fifth Edition](https://books.google.gr/books?id=m5KlAgAAQBAJ&pg=PA656&lpg=PA656&dq=benchmarks+bubblesort+matrix+multiplication&source=bl&ots=KpOh2HSryS&sig=ACfU3U0Puw-jreZoyFZjayeqLBcDKBXslA&hl=en&sa=X&ved=2ahUKEwjw2vq7kPjlAhXBZ1AKHfN0C5UQ6AEwBHoECAkQAQ#v=onepage&q=benchmarks%20bubblesort%20matrix%20multiplication&f=false))


//http://learning.gem5.org/book/part1/example_configs.html


