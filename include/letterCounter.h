#pragma once

struct CounterArrayItem {
	size_t count;
	char letter;
};

struct CounterArray {
	size_t size;
	size_t used;
	struct CounterArrayItem* array;
};

extern int isValidLetter(const char letterCandidate);
extern char uppercaseLetter(char letter);
extern void addLetterToCounter(struct CounterArray *counter, char letter);
extern void expandArrayIfNeeded(struct CounterArray *counterArray);