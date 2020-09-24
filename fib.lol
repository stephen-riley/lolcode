
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

__NOMORZ__

Recursive solution.

int fib( n ) {
	if( n < 2 ) {
		return 1;
	} else {
		int a = fib( n-1 );
		int b = fib( n-2 );
		return a+b;
	}
}