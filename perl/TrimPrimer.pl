#!/usr/bin/env perl
use strict;


my ($fastq, $primer, $mismatch, $MAXP, $output, $summary);
$fastq=$ARGV[0];
$primer= $ARGV[1];
$mismatch=$ARGV[2];
$MAXP=$ARGV[3];
$output=$ARGV[4];
$summary=$ARGV[5];

if(!$fastq || !$primer){
	die "No sequence file or primer provided\n";
}

$primer=~s/^\s+|\s+$//g;
my $length=length($primer);
my $primer_pattern=&IUPAC($primer);

open(IN, "$fastq") or die;
open(OUT, ">$output") or die;
my %stat;
my %mis;
while(<IN>){
	if(/^(@\S*)/){
		my $hit=0;
		my $id=$_;
		my $seq=<IN>;
		my $qid=<IN>;
		my $qsc=<IN>;

		my ($position,$mismatch)=&findPrimer($primer, $seq);
		if($position != -1){
			my $trim=$position+$length;
			$stat{$trim}=0 if !exists $stat{$trim};
			$stat{$trim}++;
			$mis{$mismatch}=0 if !exists $mis{$mismatch};
			$mis{$mismatch}++;
			print OUT $id;
			print OUT substr($seq, $trim);
			print OUT $qid;
			print OUT substr($qsc, $trim);
		}else{
			$stat{"N/A"}=0 if !exists $stat{"N/A"};
			$stat{"N/A"}++;
			$mis{"N/A"}=0 if !exists $mis{"N/A"};
			$mis{"N/A"}++;
		}
	}else{
		my $temp =<IN>;
	}
}
close OUT;
close IN;

open(S, ">$summary") or die;
print S "Trim position\tcount\n";
foreach my $p(sort keys(%stat)){
	print S $p."\t".$stat{$p}."\n";
}
print S "\n\t************\n\n";
print S "mismatch\tcount\n";
foreach my $p(sort keys(%mis)){
	print S $p."\t".$mis{$p}."\n";
}
close S;


sub findPrimer(){ #return startposition and mismatch
	my ($primer, $stored_seq)=@_;

	my %stretch;
	for(my $j=0;$j<=$MAXP;$j++){
		my $target=substr($stored_seq, $j, $length);
		if($target=~/$primer_pattern/){
			return($j,0);
		}
	}
	for(my $j=0;$j<=$MAXP;$j++){
		my $target=substr($stored_seq, $j, $length);
		my @n1 = split( "", $target);
		my @n2 = split( "", $primer );
		my $stretch;
		for ( my $i = 0; $i <= $#n1 and $i<=$#n2; $i++ ) {
			my $c=$n2[$i];
			$c=&IUPAC($c);
			if ( $n1[$i] !~ $c ) {
				$stretch++;
			}
		}
		$stretch{$j} = $stretch;
	}

	my @startp = sort { $stretch{$a} <=> $stretch{$b} } ( keys %stretch );
	if($stretch{$startp[0]}<=$mismatch){
		return ($startp[0], $stretch{$startp[0]});
	}else{
		return (-1, -1);
	}
}

sub IUPAC(){
	my ($str)=@_;
	$str=~s/R/[A|G]/g;
	$str=~s/Y/[C|T]/g;
	$str=~s/S/[G|C]/g;
	$str=~s/W/[A|T]/g;
	$str=~s/K/[G|T]/g;
	$str=~s/M/[A|C]/g;
	$str=~s/B/[C|G|T]/g;
	$str=~s/D/[A|G|T]/g;
	$str=~s/H/[A|C|T]/g;
	$str=~s/V/[A|C|G]/g;
	$str=~s/X/[A|C|T|G]/g;
	$str=~s/N/[A|C|T|G]/g;
	return $str;
}
