# lolcode
A [LOLCODE](https://en.wikipedia.org/wiki/LOLCODE) compiler I wrote back in 2008.  The compiler writes out bytecode (apparently I called it "lolcodez") and then the bytecode interpreter runs it.  Of course, all of this is written in Perl just to turn the [esoteric factor](https://en.wikipedia.org/wiki/Esoteric_programming_language) up to 11.

![oh hai](o-hai-i-can-has-c0dez.jpg)

# Installation

You'll need a standard Perl, probably already on your system.  You'll also need to install the `Parse::RecDescent` perl module from CPAN:

```
cpan install Parse::RecDescent
```

# Usage

```bash
perl lolc.pl helloworld.lol > helloworld.lolz
perl lol.pl helloworld.lolz

# or, more compactly (if you aren't expecting input from the user)

perl lolc.pl helloworld.lol | perl lol.pl
```

`lolc.pl <file.lol>` is the compiler, which outputs the bytecode to STDOUT.

`lol.pl` reads bytecode from STDIN and outputs to STDOUT.  You can also specify a `.lolz` file on the command line.
