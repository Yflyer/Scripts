# !/usr/bin/perl -w
#

use strict;
use autodie;

my $type = $ARGV[0];
my $input = $ARGV[1];
my $output=$ARGV[2];
my $report = $ARGV[3];
my @inputs = split(",",$input);
my %names;
for(my $i=5;$i<=scalar(@ARGV);$i++){
	my $whole_name = $ARGV[$i-1];
	if($whole_name =~ /(\w+)\.f/){
		$names{$inputs[$i-5]} = $1;
	}
}
open(RE,">$report");
open(OUT,">$output");
foreach my $input(@inputs){
	open(IN,"<$input");
	my $s_number=0;
	unless(exists $names{"$input"}){ 
		die "The selected $input did not contain its corresponding name.";
	}
	if($type =~ /fasta/){
		while(<IN>){
			if(/^(>\w+)/){
				$s_number++;
				chomp();
				print OUT $_."--$names{$input}\n";
			}else{
				print OUT "$_";
			}
		}
	}elsif($type=~/fastq/){
		while(<IN>){
			if(/^(@\S+)/){
				$s_number++;
				chomp();
				print OUT $_."--$names{$input}\n";
				my $sec = <IN>;
				my $third = <IN>;
				my $fourth = <IN>;
				print OUT "$sec"."$third"."$fourth";
			}			
		}		
	}
	print RE "$names{$input}\t$s_number\n";
	close(IN);
}
