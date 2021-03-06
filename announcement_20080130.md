To: //REDACTED//

Date: Wed, Jan 30, 2008 at 6:05pm

I wanted a fun little project last weekend, so I decided to write a LOLCode compiler in Perl.  (I figured it was appropriate to implement a language that was hell to code in due to grammatical inconsistency and idiosyncrasy in a language that was hell to code in due to grammatical inconsistency and idiosyncrasy.)

(Yes, //REDACTED//, I really did it.  mwa ha ha.)

(For those not familiar with LOLCode, it is of course a programming language based on the lingua franca of lolcats.  See http://www.lolcode.com.)

Attached you'll find a zip containing two perl scripts and a few .lol files.  (And you'll find an adorable kitty.)  (Who is a better coder than //REDACTED//.)  (For rilz.)  You will need to install Damian Conway's brilliant parser generator library, called Parser::RecDescent.  If you're using ActiveState, ppm has it.  If you're using some other distribution, YMMV.

`lolc.pl` is the compiler.  It takes a `.lol` file and outputs a primitive assembly language, called `lolcodez`, to STDOUT.

`lol.pl` is the lolcodez interpreter.  It takes input from STDIN, though through the magic of perl you can just specify a `.lolz` file on the command line.

Here's a typical usage pattern:

```bash
    perl lolc.pl script.lol | perl lol.pl
```

HOWEVER, if your script takes input (through the `GIMMEH` statement), you have to break it up into separate compile and run steps (due to the remapping of STDIN in the pipe model):

```bash
    perl lolc.pl script.lol > script.lolz
    perl lol.pl script.lolz
```

I took several liberties with the language as specified on lolcode.com.  (The spec got increasingly unfunny as it marched from 1.0 to 1.2.)

The basics are demonstrated in the examples in the zip.  The biggest examples are [fib-recurse.lol](fib-recurse.lol) and [fib-iter.lol](fib-iter.lol), two solutions to Fibonacci's sequence.  Both ask the user for the number of iterations, and both return the sequence number at that iteration.

Here are some of my changes from the spec:

* I added parenthetical support in expressions.  It's tough to read lolcode, much less write it!  This makes it a little easier to understand.

* Calling a function: `WUT U SAY? function [ WIF arg1 [ AN arg2 [ AN arg-n ] ] ] ` (Funny to read, and gave me a convenient function call token.)

* Printing: `I SEZ expression [ ! ]`  (bang prevents newline, like semicolon in Basic)  (`VISIBLE` just isn't funny.)

* Input: `GIMMEH ( NUMBR | NUMBAR | YARN ) var`    (`NUMBR`s are integers, `NUMBAR`s are floats, `YARN`s are strings)

* Loops don't have built-in iteration yet.  They're just infinite loops with a break statement of `GTFO`.

* `elseif` is done with `MEBBE`.

* No comment support yet, either BTW or OBTW...TLDR.

Any other questions will be answered in the source.


About [RecDescent](https://metacpan.org/pod/Parse::RecDescent): it's not as good as ANTLR, but I was amazed at how close it is!  This thing is ridiculously powerful for mere perl scripts.