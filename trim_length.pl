# !/usr/bin/perl -w
#

use strict;

my $inputfile	= $ARGV[0];
my $min 		= $ARGV[1];
my $trimdelete  = $ARGV[2];
my $max 		= $ARGV[3];
my $outputfile	= $ARGV[4];
my $summaryfile	= $ARGV[5];


my $eligible_seq=0;
my $removed=0;
my $total=0;
my $trimed=0;

open (TRIMSEQ, ">$outputfile") or die "cannot open trimmed $outputfile";
my @storedLines=();
open(TF,"<$inputfile");
open(O,">$outputfile");
my $n=0;
while(my $line=<TF>){
	if($line=~/^>/ or ($line=~/^[@+]/ and !($n%2))){
		$total++;
		$n++;
		if(@storedLines){
			my $sid=shift(@storedLines); #=$storedLines[0];
			my $seq=join("",@storedLines);
			$seq=~s/\s+//g;	
			if(length($seq)> $min and length($seq)<=$max){
				print O "$sid";
				print O "$seq\n";
				$eligible_seq++;
			}elsif(length($seq)>$max){
				if($trimdelete eq "Trim" ){
					if($seq=~m/^(.{$max})/){
					$seq=$1;
					print O "$sid";
					print O "$seq\n";
					$trimed++;
					$eligible_seq++;}
				}else{
					$removed++
				}
			}else{
				$removed++;
			}
		}
		@storedLines=();
		push (@storedLines, $line);
	}else{
		if($line =~ /\S/){
			$n++;
			chomp($line);
			push (@storedLines, $line);
		}
	}			
}
close TF;
if(@storedLines){
	my $sid=shift(@storedLines); #=$storedLines[0];
	my $seq=join("",@storedLines);
	$seq=~s/\s+//g;	
	if(length($seq)> $min and length($seq)<=$max){
		print O "$sid";
		print O "$seq\n";
		$eligible_seq++;
	}elsif(length($seq)>$max){
		if($trimdelete eq "Trim"){
			if($seq=~m/^(.{$max})/){
			$seq=$1;
			print O "$sid";
			print O "$seq\n";
			$trimed++;
			$eligible_seq++;}
			}else{
				$removed++
			}
	}else{
		$removed++;
	}
}
close TRIMSEQ;
open(S, ">$summaryfile");
print S "# Program:\ttrim_length.pl\n";
print S "# Parameters:\n\tMinimum length:\t$min\n\tMaximum length:\t$max\n";
print S "\n# Totoal sequence number:\t $total\n";
print S "# Sequence number left:\t $eligible_seq\n";
print S "# Removed sequence number:\t$removed\n";
print S "# Trimed sequence number:\t$trimed\n";
close S;
