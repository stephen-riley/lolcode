
use warnings;

my @instructions;
my $ip = 0;
my %labels;

my @stack;
my @call_stack;
my @namespaces;

my $DEBUG = undef;

while( <> ) {
	chomp;
	next if /^\s*$/;
	
	if( /^([^\"]*):/ ) {
		$labels{$1} = $ip;
	} else {
		s/^\s*//;
		$instructions[$ip] = $_;
		$ip++;
	}
}

$ip = 0;
while( 1 ) {
	last if $ip > $#instructions;
	
	my $instruction = $instructions[$ip];
	my( $opcode, $rest ) = $instruction =~ /^(.+?)(?:\s+(.*))?$/;
	
	$opcode =~ s/\./_/g;
	print "Executing instruction $ip, $instruction\n" if $DEBUG;
	&$opcode( $rest );

	if( $DEBUG ) {
		print "After $opcode:\n";
		_dump_stack();
		print "\n";
	}
}

sub _dump_stack {
	for( 0..$#stack ) {
		print "$_: ", $stack[$#stack-$_], "\n";
	}
}

sub _resolve {
	my( $sym, $frame ) = @_;
	$frame ||= 0;
	$frame = $#namespaces + $frame;
	
	return $sym unless $sym =~ /^@/;
	$sym =~ s/^\@//;
	
	if( $sym =~ /\[/ ) {
		my( $name, $index ) = $sym =~ /(.*?)\[(\d+)\]/;
		$name .= '_array';
		die( "$sym doesn't exist\n" ) unless exists $namespaces[$frame]->{$name}->[$index];
		return $namespaces[$frame]->{$name}->[$index];
	} else {
		die( "$sym doesn't exist\n" ) unless exists $namespaces[$frame]->{$sym};
		return $namespaces[$frame]->{$sym};
	}
}

sub _strip {
	return $_[0] unless $_[0] =~ /^\".*\"$/;
	my( $r ) = $_[0] =~ /^\"(.*)\"$/;
	return $r;
}

##
## Instructions
##

sub new_namespace {
	push @namespaces, {};
	$ip++;
}

sub alloc {
	my( $sym ) = @_;
	$namespaces[$#namespaces]->{$sym} = '';
	$namespaces[$#namespaces]->{"${sym}_array"} = [];
	$ip++;
}

sub push_sym {
	my( $s ) = @_;
	push @stack, ( "\@$s" );
	$ip++;
}

sub push_numbr {
	my( $n ) = @_;
	push @stack, ( $n + 0 );
	$ip++;
}

sub push_numbar {
	my( $n ) = @_;
	push @stack, ( $n + 0.0 );
	$ip++;
}

sub push_yarn {
	my( $s ) = @_;
	push @stack, $s;
	$ip++;
}

sub array_access {
	my $t0 = pop @stack;
	my $t1 = _resolve( pop @stack );
	
	if( $t1 !~ /\d+/ ) {
		$t1 = ( _resolve( $t1 ) + 0 );
	}
	
	push @stack, "$t0\[$t1\]";
	$ip++;
}

sub print {
	my $t0 = _strip( _resolve( pop @stack ) );
	print "$t0";
	$ip++;
}

sub print_nl {
	print "\n";
	$ip++;
}

sub store {
	my $t0 = pop @stack;	# var name
	my $t1 = _resolve( pop @stack );	# value
	
	$t0 =~ s/^\@//;
	
	if( $t0 =~ /\[/ ) {
		my( $name, $index ) = $t0 =~ /(.*?)\[(\d+)\]/;
		$namespaces[$#namespaces]->{"${name}_array"}->[$index] = $t1;
	} else {
		$namespaces[$#namespaces]->{$t0} = $t1;
	}
	$ip++;
}

sub bind {
	my $t0 = pop @stack;	# var name
	my $t1 = _resolve( pop @stack, -1 );	# value from previous namespace
	
	$t0 =~ s/^\@//;
	
	if( $t0 =~ /\[/ ) {
		my( $name, $index ) = $t0 =~ /(.*?)\[\d+\]/;
		$namespaces[$#namespaces]->{"${name}_array"}->[$index] = $t1;
	} else {
		$namespaces[$#namespaces]->{$t0} = $t1;
	}
	$ip++;
}

sub swap {
	my $t0 = pop @stack;
	my $t1 = pop @stack;
	push @stack, $t0;
	push @stack, $t1;
	$ip++;
}

sub resolve {
	my $t0 = _resolve( pop @stack );
	push @stack, $t0;
	$ip++;
}

sub concat {
	my $t0 = _strip( _resolve( pop @stack ) );
	my $t1 = _strip( _resolve( pop @stack ) );
	push @stack, "$t1$t0";
	$ip++;
}

sub call {
	my( $label ) = @_;
	push @call_stack, $ip+1;
	$ip = $labels{$label};
	die( "No label '$label'\n" ) unless $ip;
}

sub return {
	pop @namespaces;
	$ip = pop @call_stack;
}

sub exit {
	exit( 0 );
}

sub goto {
	my( $label ) = @_;
	$ip = $labels{$label};
	die( "No label $label\n" ) unless $ip;
}

sub branch_false {
	my( $label ) = @_;
	my $t0 = _resolve( pop @stack );
	
	if( $t0 eq '' || $t0 == 0 ) {
		$ip = $labels{$label};
		die( "No label $label\n" ) unless $ip;
	} else {
		$ip++;
	}
}

sub lt {
	my $t0 = _resolve( pop @stack );
	my $t1 = _resolve( pop @stack );
	
	if( $t1 < $t0 ) {
		push @stack, 1;
	} else {
		push @stack, 0;
	}
	$ip++;
}

sub gt {
	my $t0 = _resolve( pop @stack );
	my $t1 = _resolve( pop @stack );
	
	if( $t1 > $t0 ) {
		push @stack, 1;
	} else {
		push @stack, 0;
	}
	$ip++;
}

sub eq {
	my $t0 = _resolve( pop @stack );
	my $t1 = _resolve( pop @stack );
	
	if( $t1 == $t0 ) {
		push @stack, 1;
	} else {
		push @stack, 0;
	}
	$ip++;
}

sub add {
	my $t0 = _resolve( pop @stack );
	my $t1 = _resolve( pop @stack );
	
	push @stack, $t1 + $t0;
	$ip++;
}

sub sub {
	my $t0 = _resolve( pop @stack );
	my $t1 = _resolve( pop @stack );
	
	push @stack, $t1 - $t0;
	$ip++;
}

sub mul {
	my $t0 = _resolve( pop @stack );
	my $t1 = _resolve( pop @stack );
	
	push @stack, $t1 * $t0;
	$ip++;
}

sub div {
	my $t0 = _resolve( pop @stack );
	my $t1 = _resolve( pop @stack );
	
	push @stack, $t1 / $t0;
	$ip++;
}

sub input_yarn {
	my $in = <STDIN>;
	chomp $in;
	push @stack, "\"$in\"";
	$ip++;
}

sub input_numbr {
	my $in = <STDIN>;
	chomp $in;
	push @stack, $in;
	$ip++;
}

sub input_numbar {
	my $in = <STDIN>;
	chomp $in;
	push @stack, $in;
	$ip++;
}
