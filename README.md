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

# Example

A picture is worth a thousand words.  Here's a recursive version of Fibonacci:

```
HAI

HOW DUZ I DO_FIBZ WIF YR COWNT
	IZ COWNT SMALR THAN 2?
	YARLY!
		FOUND UR 1
		
	NOWAI!
		I HAS A NUM
		I HAS A NUTHERNUM
		LOL NUM R WUT U SAY? DO_FIBZ WIF ( COWNT NERF 1 )
		LOL NUTHERNUM R WUT U SAY? DO_FIBZ WIF ( COWNT NERF 2 )
		
		FOUND UR ( NUM UP NUTHERNUM )
	KTHX
IF U SAY SO

I HAS A COWNT
I HAS A REZULTZ

I SEZ "Gimmeh a numbr!"
GIMMEH NUMBR COWNT
LOL REZULTZ R WUT U SAY? DO_FIBZ WIF COWNT

I SEZ "Teh anser iz " WIF REZULTZ

KTHXBYE
```

and here's the lolcodez that result:

```
    new.namespace

    goto _skip_2
_func_DO_FIBZ:
    new.namespace
    push.sym COWNT
    bind

    push.sym COWNT
    push.numbr 2
    lt
    branch.false __next_4
    push.numbr 1
    resolve
    return
    goto __endif_3
__next_4:
    alloc NUM
    alloc NUTHERNUM
    push.sym NUM
    push.sym COWNT
    push.numbr 1
    sub
    call _func_DO_FIBZ
    swap
    store
    push.sym NUTHERNUM
    push.sym COWNT
    push.numbr 2
    sub
    call _func_DO_FIBZ
    swap
    store
    push.sym NUM
    push.sym NUTHERNUM
    add
    resolve
    return
__endif_3:

_exit_block_1:
    return
_skip_2:

    alloc COWNT
    alloc REZULTZ
    push.yarn "Gimmeh a numbr!"
    print
    print.nl
    push.sym COWNT
    input.numbr
    swap
    store
    push.sym REZULTZ
    push.sym COWNT
    call _func_DO_FIBZ
    swap
    store
    push.yarn "Teh anser iz "
    push.sym REZULTZ
    concat
    print
    print.nl
    exit
```