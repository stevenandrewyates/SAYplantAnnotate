#!/usr/bin/perl
use strict;
use warnings;

########################################
## get AT names
########################################
my %names;
open(AT, $ARGV[0]) or die "could not open file";

### go through the fasta file
while (<AT>) 
{
chomp;
if ($_ =~ /^>/)
	{
	my @line = split /\|/, $_ ;
	my $AT = substr($line[0],1,9);
	my @TI = split /;/,$line[2];
	my $DESC = $TI[0];
	$names{$AT} = $DESC;
	}
}
#my @line = split /\t+/, $_ ;
#while (my ($key, $value) = each(%names)){
#     print $key."\t".$value."\n";
close AT;


#########################################
## get the GO terms 
##########################################

my %GOTERMS;
open(GO, $ARGV[1]) or die "could not open file";

### go through the sam file
while (<GO>) 
{
chomp;
my @line = split /\t/, $_ ;
my $ATG = $line[0];
my $GO = $line[5];
if (exists($GOTERMS{$ATG})) {$GOTERMS{$ATG} = $GOTERMS{$ATG} . ", ". $GO;}
else {$GOTERMS{$ATG} = $GO;}
#print $ATG ,"\t",$GO,"\n";
}

#while (my ($key, $value) = each(%GOTERMS)){
#     print $key."\t".$value."\n";}
close GO;

#########################################
## get the BLASTHITS 
##########################################

my %BLAST;
my $contig = 0;
open(BL, $ARGV[2]) or die "could not open file";

### go through the BLAST file
while (<BL>) 
{
chomp;
my @line = split /\t/, $_ ;

if ($contig =~ $line[0]) {$contig = $line[0]}
else 	{ $BLAST{$line[0]} = substr($line[1],0,9) ; $contig = $line[0] }

}


close(BL);
open (FA, $ARGV[3]) or die "could not open file";

while (<FA>)
{
chomp;

my @line = split / /, $_ ;
my $AT = $line[0];
#print "found ID\t",$AT,"\n";
if (exists $BLAST{$AT}) {print "\"".$AT."\"\t\"".$BLAST{$AT}."\"\t\"".$names{$BLAST{$AT}}."\"\t\"".$GOTERMS{$BLAST{$AT}}."\"\n";}
else {print "\"$AT\"\t\"NA\"\t\"NA\"\tNA\"\n";}

}

#while (my ($key, $value) = each(%BLAST)){     print $key."\t".$value."\t".$names{$value}."\t".$GOTERMS{$value}."\n";}



