#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <inttypes.h>
#include "letterCounter.h"

const char validLetters[]= "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"; //TODO: update after checking the available textures.

int main (int argc, char **argv){

	if (argc < 2) {
		fprintf(stderr, "Error: Not enough arguments.\nUsage: %s \"words to count letters of\"\n", argv[0]);
		exit(-1);
	}

	struct CounterArray counter = {.size=1, .used=0, .array=calloc(1,sizeof(struct CounterArrayItem))};

	for(size_t remainingArgs = argc -1; remainingArgs > 0; remainingArgs--)
	{
		for(char *letter = argv[argc-remainingArgs]; *letter!=0; letter++){
			char upLetter = uppercaseLetter(*letter);
			if(!isValidLetter(upLetter)) continue;
			addLetterToCounter(&counter,upLetter);
		}

		if (remainingArgs -1 > 0 && isValidLetter(' ')) addLetterToCounter(&counter,' ');
	}

	//TODO:sort array

	struct CounterArrayItem *printEndPos = &(counter.array[counter.used]);
	struct CounterArrayItem *printLookup = counter.array;

	fprintf(stderr,"Results:\n");
	size_t total = 0;
	while(printLookup!= printEndPos && printLookup->letter != 0){
		printf("\"%c\"\t%zu\n",printLookup->letter,printLookup->count);
		total += printLookup->count;
		printLookup++;
	}
	fprintf(stderr,"Total: %zu\n",total);

}

inline void expandArrayIfNeeded(struct CounterArray *counterArray){

	if(counterArray->size > counterArray->used)
		return;

	size_t newSize = counterArray->size *2;
	struct CounterArrayItem *newPtr = realloc(counterArray->array,sizeof(struct CounterArrayItem)*newSize);

	if(newPtr == NULL) {
		fprintf(stderr, "Couldn't allocate %zu bytes of memory, quitting.",sizeof(struct CounterArrayItem)*newSize);
		exit(-2);
	}

	memset(&(newPtr[counterArray->size]), 0, counterArray->size * sizeof(struct CounterArrayItem)); //Make sure to initialize to zero
	counterArray->array = newPtr;
	counterArray->size = newSize;
}

inline void addLetterToCounter(struct CounterArray *counter, char letter){

	struct CounterArrayItem *lookupPos = counter->array;
	struct CounterArrayItem *lookupEndPos = &(counter->array[counter->used]);

	for (;lookupPos != lookupEndPos; lookupPos++){
		if(lookupPos->letter != letter) continue;
		lookupPos->count++;
		return;
	}

	//couldn't find, try to append.
	expandArrayIfNeeded(counter);
	struct CounterArrayItem *newCtr=&(counter->array[counter->used]);
	newCtr->letter = letter;
	newCtr->count = 1;
	counter->used++;
}

inline char uppercaseLetter(char letter){
if (letter < 'a' || letter > 'z') return letter;
return (letter - 'a' + 'A');
}

inline int isValidLetter(const char letterCandidate){ //TODO: for optimizing for large lookups and large inputs: sort the lookup and do binary search.
	const char* letterLookup = validLetters;
	while(*letterLookup != 0){
		if(letterCandidate == *letterLookup) return 1;
		letterLookup++;
	}
	return 0;
}

