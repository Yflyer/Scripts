#! usr/bin/perl -w
use strict;
use Getopt::Long;

my ($fastq1, $output1);
&GetOptions (
 "f1=s" => \$fastq1,
 "o1=s" => \$output1
);


if(!$fastq1){
	die "Not enough input files.";
}

open(F1, $fastq1) or die;

my (%samp2reads, %content);
my $total = 0;
while(<F1>){
	if(/^(@.*)--(\S+)/){
		$total++;
		if(!exists($samp2reads{$2})){
			@{$samp2reads{$2}} = ($1);
		}
		else{
			push @{$samp2reads{$2}}, $1;
		}
		my $str = "";
		for(my $i=0;$i<3;$i++){
			my $line = <F1>;
			$str.=$line;
		}
		$content{$1} = $str;
	}
}
close F1;

if($total==0){die "The fastq format doesn't fit our program";}

for my $samp(sort keys %samp2reads){
	open(F, ">$samp.fastq") or die "Can't open $samp to write";
	foreach my $read(@{$samp2reads{$samp}}){
		print F"$read\n$content{$read}";
	}
	close(F);
}

# zip all fastq files together
my $commend = "tar -cvzf $output1 *.fastq";
system($commend);

# end ...




