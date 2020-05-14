#! usr/bin/perl -w
use strict;
use Getopt::Long;

my $fastq=$ARGV[0];
my $fasta=$ARGV[1];

if(!$fastq || !$fasta){
	die "Please check the input filename and output filename";
}
open(Q,$fastq) or die "cannot open $fastq to read\n";
open(A,">$fasta") or die "cannot open $fasta to write\n";

while(<Q>){
	chomp;
	if(/^@(.*)/){
		print A ">".$1."\n";
		my $line=<Q>;
		print A $line;
		for(my $i=0; $i<2; $i++){
			$line=<Q>;
		}
	}
}
close Q;
close A;
