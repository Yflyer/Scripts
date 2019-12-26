#! c:\perl\bin\perl -w
#
# -------------------------------------------------------
# INPUT: 
#	THE RESAMPLE SIZE (2000, BY DEFAULT): $RESAMPLE_SIZE
#	THE TABLE TO BE RESAMPLED: $file2Bresampled
# OUTPUT:
#	THE RESAMPLED TABLE
# -------------------------------------------------------
#

use strict;
use warnings;

my $file2Bresampled=$ARGV[0];
my $RESAMPLE_SIZE=$ARGV[1];
my $outputfile=$ARGV[2];

open(I, $file2Bresampled);
my @tags;
my @otus;
my %all;
my $line_num=0;
while(my $line=<I>){
	chomp $line;
	if(!$line){
		next;
	}
	$line_num++;
	if($line_num==1){	#first line
		@tags=split(/\t/,$line);
	}else{
		my @temp=split(/\t/,$line);
		my $otu=$temp[0];
		push(@otus,$otu);
		for(my $i=1; $i<=$#temp;$i++){
			my $tag=$tags[$i];
			if(!exists $all{$tag}{"total"}){
				$all{$tag}{"total"}=0;
			}
			$all{$tag}{$otu}=$temp[$i];
			$all{$tag}{"total"}+=$temp[$i];
		}
	}
}
close I;
shift(@tags); ## delete "ID" in tags

#for (my $i=0;$i<10;$i++){
my %rsp_all;
foreach my $tag(@tags){
	my $total=$all{$tag}{"total"};
	if($total<=$RESAMPLE_SIZE){	
		# the tag has less seqs than the resample size
		# keep all the seqs belong to this tag
		%{$rsp_all{$tag}}=%{$all{$tag}};
	}else{
		my %temp; # the index-OTU pairs
		my $i=0;
		foreach my $otu(@otus){
			for(my $j=1; $j<=$all{$tag}{$otu};$j++){
				$temp{$i+$j}=$otu;
			}
			$i+=$all{$tag}{$otu};
		}
		#print "$total\t$i\n";
		
		my %rands;
		my $count=0; ### sequence # already chosen
		while($count<$RESAMPLE_SIZE){
			my $random_number=int(rand($total))+1;
			if(!exists $rands{$random_number}){
				$rands{$random_number}=1;
				my $otu=$temp{$random_number};
				if(!exists $rsp_all{$tag}{$otu}){
					$rsp_all{$tag}{$otu}=0;
				}
				$rsp_all{$tag}{$otu}++;
				$count++;
			}
		}
	}
}

open(O,">$outputfile") or die "cannot open $outputfile !";
print O " OTUID\t".join("\t",@tags)."\n";
foreach my $otu(@otus){
	print O $otu;
	foreach my $tag(@tags){
		if(!exists $rsp_all{$tag}{$otu}){
			$rsp_all{$tag}{$otu}=0;
		}
		print O "\t".$rsp_all{$tag}{$otu};
	}
	print O "\n";
}
close O ;
#}