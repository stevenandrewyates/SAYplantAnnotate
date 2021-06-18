#!/usr/bin/perl
use strict;
use warnings;


#########################################
## get the ATG terms 
##########################################

# example read in 
# "TCONS_00000001"	"AT3G18270"	" cytochrome P450, family 77, subfamily A, polypeptide 5 pseudogene "	"GO:0005739, GO:0008152, GO:0003824, GO:0009507"	"TCONS_00000001"	"B9I2J6"	"GO:0000287, GO:0003824, GO:0006518, GO:0008152, GO:0016853, GO:0016854, GO:0046872"	"IPR001354, "	"L-Ala-D/L-amino acid epimerase"	" 294" 

# 10 columns

my %ANNOT;
open(GO, $ARGV[0]) or die "could not open file";

### go through the sam file
while (<GO>) 
{
chomp;
my @line = split /\t/, $_ ;
# print $line[0];
my $TCONS = $line[0];
$ANNOT{$TCONS}{ATG} = $_;
#print $ATG ,"\t",$_,"\n";
}

# while (my ($key, $value) = each(%ANNOT)){
#     print $key."\t".$ANNOT{$key}{ATG}."\n";}



#########################################
## get the UNIprot terms 
##########################################

# example read in 
# "TCONS_00009964"	""	"Plant mobile domain"	"NA"	"NA"	"NA"	"PF10536"	"NA"	"NA"	"NA"	"NA"	"NA"	"NA"	"NA"	"NA"	"NA"
# 16 columns

open(GO, $ARGV[1]) or die "could not open file";
my $blank = "\t\"NA\"";
### go through the sam file
while (<GO>) 
{
chomp;
my @line = split /\t/, $_ ;
# print $line[0];
my $TCONS = $line[0];
$ANNOT{$TCONS}{UNI} = $_;
#print $ATG ,"\t",$_,"\n";
if (exists($ANNOT{$TCONS}{ATG})) { print $ANNOT{$TCONS}{ATG},"\t",$_,"\n";}
else {print $TCONS, $blank x 8,"\t", $_,"\n";}
}

# now print the rest
 while (my ($key, $value) = each(%ANNOT)){
if (exists($ANNOT{$key}{UNI})) {next;}
else {    print $ANNOT{$key}{ATG}.$blank x 16,"\n" ;}
}



