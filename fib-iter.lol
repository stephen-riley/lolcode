
HAI

HOW DUZ I DO_FIBZ WIF YR COWNT
	IZ COWNT SMALR THAN 2?
	YARLY!
		FOUND UR 1
		
	NOWAI!
		I HAS A NUM
		I HAS A NUTHERNUM
		I HAS A TOOMANYNUMZ
		
		LOL NUM R 1
		LOL NUTHERNUM R 1
		
		IM IN YR LOOPZ
			LOL TOOMANYNUMZ R ( NUM UP NUTHERNUM )
			LOL NUM R NUTHERNUM
			LOL NUTHERNUM R TOOMANYNUMZ
			COWNT NERFZ!!
			IZ COWNT SMALR THAN 2?
			YARLY!
				GTFO
			KTHX
		IM OUTTA YR LOOPZ
		
		FOUND UR TOOMANYNUMZ
	KTHX
IF U SAY SO

I HAS A COWNT
I HAS A REZULTZ

I SEZ "Gimmeh a numbr!"
GIMMEH NUMBR COWNT
LOL REZULTZ R WUT U SAY? DO_FIBZ WIF COWNT

I SEZ "Teh anser iz " WIF REZULTZ

KTHXBYE

__NOMORZ__

Iterative solution.

int fib( n ) {
	if( n < 2 ) {
		return 1;
	} else {
		int a=1, b=1, c;
		while( n > 1 ) {
			c = a + b;
			a = b;
			b = c;
			n--;
		}
		return c;
	}
}
