#include <stdio.h> //printf
#include <stdlib.h> //atoi, rand(), malloc, free, EXIT_SUCCESS

//Utility function for array printing
void printArray(int* arr, int size) 
{ 
  for (int i=0; i < size; i++) 
    printf("%d ", arr[i]); 
  printf("\n"); 
} 

//Utility function for swapping 2 int values
void swap(int *xp, int *yp) 
{ 
  int temp = *xp; 
  *xp = *yp; 
  *yp = temp; 
} 

  
//Bubble sort function
void bubbleSort(int* arr, int n) 
{ 
  for (int i = 0; i < n - 1; i++)       
    for (int j = 0; j < n - i - 1; j++)  
      if (arr[j] > arr[j + 1]) 
        swap(&arr[j], &arr[j + 1]); 
} 
  

//Driver program
int main(int argc, char** argv) 
{ 
   //we allow the user to give a custom size for the array
   size_t n = argc == 2 ? atoi(argv[1]) : 100;
  
   //fill with random values between 0 and 99
   int* arr = (int*)malloc(n * sizeof(int));
   for(size_t i = 0; i < n; i++)
     arr[i] = rand() % 100;

   //print unsorted array
   puts("Unsorted array:"); 
   printArray(arr, n); 

   //sort the array and print the results
   bubbleSort(arr, n); 
   puts("Sorted array:"); 
   printArray(arr, n); 

   //release the array
   free(arr);
   return EXIT_SUCCESS; 
} 
