# Letter Counter for GT:NH Letter Mark "Signs"

Yeah, I was doing a build where I wanted to write the name of the build on every floor, on every side, so I needed a calculator for that.

LOL

MIT License

Fixes and contributions are always welcome, unless it's very slop.

[Jump to Compiling section](#Compiling)
[Jump to Usage section](#Usage)

## Compiling

I use `gcc` on linux.
This program has no dependencies except for libc, so you don't need an extra package.

Run `make` to apply the C Compiler Flags automatically or just type it every time, whatever floats your boat.

```sh
make
```

```sh
gcc -Wall -Werror -Wextra -pedantic-errors -pedantic -g -DPOSIX_SOURCE -DPOSIX_C_SOURCE=200809L -o bin/letterCounter src/letterCounter.c
```

## Usage

Run the program with giving strings **as arguments**. (Does not support stdin for now.)

```sh
./letterCounter "cavemen rise up"
```

You can also not quote the strings.

```sh
./letterCounter this is stupid
```

<!-- TODO: Update this part once once STDIN support is made, as this will be irrelevant -->

You can work around the STDIN issue by using subshells.

```sh
./letterCounter $(<./bee-script.txt)
./letterCounter $(curl https://cat-name-api.example.com/get-daily-name)
```

The output is formatted in a way to be ingested easily:

- The letter surrounded by quotation marks: `"J"`
- a TAB character (`\t`) to seperate letter from count
- how many times that letter has appeared: `15`
- a new line to seperate entries

So, if you need to extract it with a regex, then you can use something like `^"(.+?)"\t+(\d+?)$`.

### Example input output

```plaintext
$ ./letterCounter kofteistkofte
Results:
"K"	2
"O"	2
"F"	2
"T"	3
"E"	2
"I"	1
"S"	1
Total:	13
```

(The lines with the "Results" and "Total" text are written to stderr instead of stdout.)
