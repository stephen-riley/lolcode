
use Parse::RecDescent;

while( $ARGV[0] =~ /^-/ ) {
	my $arg = shift @ARGV;
	$::RD_TRACE = 1 if $arg eq '-trace';
	$::RD_HINT = 1 if $arg eq '-hint';
}

my @symbol_stack;

my $grammar = "";
{
	local $/;
	$grammar = <DATA>;
	close DATA;
}

my $code = "";
{
	local $/;
	open( I, $ARGV[0] ) or die( "Could not open file $ARGV[0]: $!\n" );
	$code = <I>;
	close I;
}

$parser = new Parse::RecDescent( $grammar );
$parser->program( $code );

my $_sym_ctr = 0;
sub new_sym {
	my( $type ) = @_;
	$_sym_ctr++;
	my $sym = "_${type}_${_sym_ctr}";
	push @symbol_stack, $sym;
	return $sym;
}


__DATA__

{
	my %ops = (
		'WIF' => 'concat',
		'UP' => 'add',
		'NERF' => 'sub',
		'TIEMZ' => 'mul',
		'OVAR' => 'div',
		'LIEK' => 'eq',
		'BIGR THAN' => 'gt',
		'SMALR THAN' => 'lt',
	);
	
	my %assign_ops = (
		'UPZ!!' => 'add',
		'NERFZ!!' => 'sub',
		'TIEMZD!!' => 'mul',
		'OVARZ!!' => 'div',
	);
	
	my @block_stack = ();
}

program:
	NL(?)
	'HAI' { print "    new.namespace\n"; }
	<skip:'[ \t]*'>
	NL
	stat(s)
	'KTHXBYE' { print "    exit\n" }
	NL(?)
	no_more(?)
	/\Z/

no_more: '__NOMORZ__' /[^\Z]*/

stat: program_stats NL

program_stats: base_stats | function

base_stats: if_block | loop | func_call | decl | assignment
base_stats: print | input | exit_block
base_stats: op_assign

decl: 'I HAS A' identifier {
	print "    alloc $item[2]\n";
}

assignment: 'LOL'
	(
		  identifier { print "    push.sym $item[1]\n" }
		| array_ref
	) 'R' expression {
		print "    swap\n";
		print "    store\n";
	}

print:
	'I SEZ'
	expression { print "    print\n" }
	( '!' | { print "    print.nl\n" } )

function: <rulevar: local $label>
function: <rulevar: local @args>
function:
	'HOW DUZ I' identifier {
		print "\n";
		push @block_stack, &::new_sym( 'exit_block' );
		$label = &::new_sym( 'skip' );
		print "    goto $label\n";
		print "_func_$item[2]:\n";
		print "    new.namespace\n";
	}
	( ( 'WIF' | 'AN' )(?) 'YR' identifier { push @args, $item[3]	} )(s?)
	{
		while( @args ) {
			print "    push.sym ", pop @args, "\n";
			print "    bind\n";
		}
	}
	NL
	( func_stats NL )(s?)
	'IF U SAY SO' {
		print pop @block_stack, ":\n";
		print "    return\n";
		print "$label:\n", "\n";
	}

func_stats: base_stats
func_stats: 'FOUND UR' expression {
	print "    resolve\n";
	print "    return\n";
}

op_assign:
	identifier assign_op <commit>
	{ print "    push.sym $item[1]\n" }
	( expression | { print "    push.numbr 1\n" } )
	{
		print "    ", $assign_ops{$item[2]}, "\n";
		print "    push.sym $item[1]\n";
		print "    store\n";
	}

op_assign:
	array_ref assign_op <commit>
	( expression | { print "    push.numbr 1\n" } )
	{
		print "    ", $assign_ops{$item[2]}, "\n";
		print "    push.sym $item[1]\n";
		print "    store\n";
	}

assign_op: 'UPZ!!' | 'NERFZ!!' | 'TIEMZD!!' | 'OVARZ!!'

array_ref:
	identifier 'IN MAH' identifier
	{
		print "    push.sym $item[1]\n";
		print "    push.sym $item[2]\n";
		print "    array.access\n";
	}

array_ref:
	numbr 'IN MAH' identifier {
		print "    push.numbr $item[1]\n";
		print "    push.sym $item[3]\n";
		print "    array.access\n";
	}

expression: atom ( op expression { print "    ", $ops{$item[1]}, "\n" } )(s?)

atom:
	  func_call
	| array_ref
	| constant
	| identifier { print "    push.sym $item[1]\n" }
	| '(' expression ')'
	
op:	  'WIF'
	| 'UP'
	| 'NERF'
	| 'TIEMZ'
	| 'OVAR'
	| 'BIGR THAN'
	| 'SMALR THAN'
	| 'LIEK'

constant: numbr { print "    push.numbr $item[1]\n" }
constant: numbar { print "    push.numbar $item[1]\n" }
constant: yarn { print "    push.yarn $item[1]\n" }

func_call:
	'WUT U SAY?' identifier (
		'WIF' expression
		( 'AN' expression )(s?)
	)(?)
	{ print "    call _func_$item[2]\n" }

if_block: <rulevar: local @label_stack>
if_block:
	'IZ' { print "\n" } expression '?' NL
	/YARLY[!]?/ NL
	{
		push @label_stack, &::new_sym( '_endif' );
		push @label_stack, &::new_sym( '_next' );
		print "    branch.false ", $label_stack[$#label_stack], "\n";
	}
	( func_stats NL )(s?) { print "    goto ", $label_stack[$#label_stack-1], "\n" }
	(
		'MEBBE' { print pop @label_stack, ":\n" }
		expression '?' NL
		{
			push @label_stack, &::new_sym( 'next_if_clause' );
			print "    branch.false ", $label_stack[$#label_stack], "\n";
		}
		( func_stats NL )(s?) { print "    goto ", $label_stack[$#label_stack-1], "\n" }
	)(s?)
	(
		(
			/NOWAI[!]?/ NL { print pop @label_stack, ":\n" }
			( func_stats NL )(s?)
		)
		|	{ print pop @label_stack, ":\n" }
	)
	'KTHX' { print pop @label_stack, ":\n", "\n" }

input: 'GIMMEH NUMBR' ( identifier { print "    push.sym $item[1]\n" } | array_ref ) {
	print "    input.numbr\n";
	print "    swap\n";
	print "    store\n";
}

input: 'GIMMEH NUMBAR' ( identifier { print "    push.sym $item[1]\n" } | array_ref ) {
	print "    input.numbar\n";
	print "    swap\n";
	print "    store\n";
}

input: 'GIMMEH YARN' ( identifier { print "    push.sym $item[1]\n" } | array_ref ) {
	print "    input.yarn\n";
	print "    swap\n";
	print "    store\n";
}

loop: <rulevar: local $loopname>
loop:
	'IM IN YR' identifier {
		print "\n";
		$loopname = $item[2];
		push @block_stack, $loopname;
		print "_loop_start_$loopname:\n";
	}
	NL
	(
		(
			  base_stats
		) NL
	)(s?)
	'IM OUTTA YR' identifier {
		if( $item[5] ne $loopname ) {
			print "";
		}
		print "    goto _loop_start_$loopname\n";
		print "_end_$loopname:\n", "\n";
	}

exit_block: 'GTFO' { print "    goto _end_", $block_stack[$#block_stack], "\n" }

identifier:	/[A-Za-z][A-Za-z0-9_]*/

numbar: /-?\d+\.\d+/

numbr: /-?\d+/

yarn: /\".*?\"/

NL: ( /[\n,]/ )(s)
