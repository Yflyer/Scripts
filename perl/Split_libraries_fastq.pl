#!/usr/bin/env perl
# -*- coding:utf-8 -*-

use strict;
use Getopt::Long;

my ($fastq1,$fastq2,$map, $indexfile,$output1, $output2, $error);
&GetOptions (
"f1=s" => \$fastq1,
"f2=s" => \$fastq2,
 "map=s" => \$map,
 "index=s" => \$indexfile,
 "o1=s" => \$output1,
 "o2=s" => \$output2,
 "e=f" => \$error
);


if(!$fastq1 || !$fastq2 || !$map || !$indexfile){
	die "Not enough input files.";
}

# read map file
my %map;
open(M, $map) or die;
while (<M>){
	if(/(\S*)\s*(\S*)/){
		my $s=$1;
		my $seq=$2;
		$map{$seq}=$s;
		my $reversed=&reverse($seq);
		$map{$reversed}=$s;
	}
}
close M;

# read index barcodes file
my %sample;
my %dis; $dis{0}=0;
my $total=0;
my $remain=0;
open(I, $indexfile) or die;
while (<I>){
	if(/^@(\S*)/){
		$total++;
		my $id=$1;
		my $seq=<I>;
		$seq=~s/\s*//g;

		if(exists $map{$seq}){
			$dis{0}++;
			$sample{$id}=$map{$seq};
			$remain++;
		}elsif($error>=1){
			my ($samp, $stretch ) = &CorrectBarcode( $seq, \%map );
			$dis{$stretch}=0 if !exists $dis{$stretch};
			$dis{$stretch}++;
			if($stretch<=$error){
				$sample{$id}=$samp;
				$remain++;
			}
		}
	}elsif(/^\+\s/){
		<I>;
	}
}
close I;

open(T,">Split_lib_summary.txt");
print T "Total sequences:\t$total\nRemain (found barcods with error < $error):\t$remain\n\nBarcode error distribution:\n";
foreach my $s(sort {$a <=> $b} (keys %dis)){
print T "$s\t".$dis{$s}."\n";
}
close T;

# read fastq files and remove sequences without barcode

open(F1, $fastq1);
open (O1, ">$output1");
while(<F1>){
	if(/^(@(\S*))/){
		if(exists $sample{$2}){
			print O1 $1."--".$sample{$2}."\n";
			my $line=<F1>;
			print O1 $line;
			$line=<F1>;
			print O1 $line;
			$line=<F1>;
			print O1 $line;
		}
	}
}

close F1;
close O1;

open(F2, $fastq2);
open (O2, ">$output2");
while(<F2>){
	if(/^(@(\S*))/){
		if(exists $sample{$2}){
			print O2 $1."--".$sample{$2}."\n";
			my $line=<F2>;
			print O2 $line;
			$line=<F2>;
			print O2 $line;
			$line=<F2>;
			print O2 $line;
		}
	}
}

close F2;
close O2;


sub reverse(){
	my ($seq)=@_;
	$seq=~tr/ATGCatgc/TACGtacg/;
	$seq = reverse($seq);
	return $seq;
}

sub CorrectBarcode() {
  my ( $seq, $tagref) = @_;
  my %tag = %{$tagref};
  my %stretch;
  foreach my $bc ( keys %tag ) {
    next if($bc=~/^\s*$/);
    my @n1 = split( "", $seq );
    my @n2 = split( "", $bc );
    my $stretch;
    for ( my $i = 0; $i <= $#n1 and $i<=$#n2; $i++ ) {
      if ( $n1[$i] ne $n2[$i] ) {
        $stretch++;
      }
    }
    $stretch{$bc} = $stretch;
  }
  my @bc = sort { $stretch{$a} <=> $stretch{$b} } ( keys %stretch );
  return ( $tag{$bc[0]}, $stretch{ $bc[0] } );
}
