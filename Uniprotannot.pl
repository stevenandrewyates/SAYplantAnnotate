#!/usr/bin/perl
use strict;
use warnings;

my %ANNOT;
my $current = "NA";
#########################################
## get the ATG terms 
##########################################

# example read in 
# TCONS_00100230	b755b60927891665105650510773894d	615	SUPERFAMILY	SSF51126		299	609	7.63E-106	T	13-06-2016


open(GO, $ARGV[0]) or die "could not open file";

### go through the sam file
while (<GO>) 
{
chomp;
my @line = split /\t/, $_ ;
# print $line[0];
my $TCONS = $line[0];
my $type = $line[3];
my $value = $line[4];

if($current !~ $TCONS)
{
#print "$TCONS\t$type\t$value\n";
$ANNOT{$TCONS}{Coils} = 'NA';
$ANNOT{$TCONS}{Gene3D} = "NA";
$ANNOT{$TCONS}{Hamap} = "NA";
$ANNOT{$TCONS}{Pfam} = "NA";
$ANNOT{$TCONS}{PIRSF} = "NA";
$ANNOT{$TCONS}{PRINTS} = "NA";
$ANNOT{$TCONS}{ProDom} = "NA";
$ANNOT{$TCONS}{ProSitePatterns} = "NA";
$ANNOT{$TCONS}{ProSiteProfiles} = "NA";
$ANNOT{$TCONS}{SMART} = "NA";
$ANNOT{$TCONS}{SUPERFAMILY} = "NA";
$ANNOT{$TCONS}{TIGRFAM} = "NA";
$ANNOT{$TCONS}{Name} = "NA";
}

if($ANNOT{$TCONS}{$type} =~ m/NA/) {$ANNOT{$TCONS}{$type} = $value;}
else {$ANNOT{$TCONS}{$type} = $ANNOT{$TCONS}{$type}.",".$value;}

if ($type =~ m/Pfam/) 	
	{
	if($ANNOT{$TCONS}{Name} =~ m/NA/) {$ANNOT{$TCONS}{Name} = $line[5];}
	else {$ANNOT{$TCONS}{Name} = $ANNOT{$TCONS}{Name}.", ".$line[5];}
	}
$current = $TCONS;



}


# read in the hap map data
open(GO, "hamap2go") or die "could not open file"; 
# Pfam:PF00001 7tm_1 > GO:G-protein coupled receptor activity ; GO:0004930

my %HAPGO;
while (<GO>) 
{
chomp;
if($_ =~ m/^\!/) {next}
my @line = split / ; /, $_ ;
my $MF = substr($_,6,8);
my $GO = $line[1];

if (exists($HAPGO{$MF}))
{ $HAPGO{$MF} = $HAPGO{$MF} . "," .$GO}
else {$HAPGO{$MF} = $GO}
}

close(GO);

# read in the pfam 2 go data
open(GO, "pfam2go") or die "could not open file"; 
# Pfam:PF00001 7tm_1 > GO:G-protein coupled receptor activity ; GO:0004930

my %PFGO;
while (<GO>) 
{
chomp;
if($_ =~ m/^\!/) {next}
my @line = split / ; /, $_ ;
my $PF = substr($_,5,7);
my $GO = $line[1];

if (exists($PFGO{$PF}))
{ $PFGO{$PF} = $PFGO{$PF} . "," .$GO}
else {$PFGO{$PF} = $GO}
}

close(GO);

# read in the pirsf2go data
open(GO, "pirsf2go") or die "could not open file"; 
# PIRSF:PIRSF000005 Cytochrome_c4 > GO:iron ion binding ; GO:0005506


my %PIGO;
while (<GO>) 
{
chomp;
if($_ =~ m/^\!/) {next}
my @line = split / ; /, $_ ;
my $PF = substr($_,4,9);
my $GO = $line[1];

if (exists($PIGO{$PF}))
{ $PIGO{$PF} = $PIGO{$PF} . "," .$GO}
else {$PIGO{$PF} = $GO}
}



#for my $HP (keys %PIGO) {
#    print "$HP\t$PFGO{$HP}\n";
#}



######################################3
# print the data


 while (my ($key) = each(%ANNOT)){
	my %go_out;

# get the GO from Hapmap2go
if ($ANNOT{$key}{Hamap} !~ 'NA') 
	{
	my @haps = split /,/,$ANNOT{$key}{Hamap};
	foreach my $h (@haps) 
		{
		if(exists($HAPGO{$h}))
			{
			my @ko = split /,/, $HAPGO{$h};
			foreach my $g (@ko) {$go_out{$g} = 1}
			}
		}
	}
# get the GO from PFAM2go
if ($ANNOT{$key}{Pfam} !~ 'NA') 
	{
	my @pfs = split /,/,$ANNOT{$key}{Pfam};
	foreach my $p (@pfs) 
		{
		if(exists($PFGO{$p}))
			{
			my @ko = split /,/, $PFGO{$p};
			foreach my $g (@ko) {$go_out{$g} = 1}
			}
		}
	}
# get the GO from PFAM2go
if ($ANNOT{$key}{PIRSF} !~ 'NA') 
	{
	my @pis = split /,/,$ANNOT{$key}{PIRSF};
	foreach my $p (@pis) 
		{
		if(exists($PIGO{$p}))
			{
			my @ko = split /,/, $PIGO{$p};
			foreach my $g (@ko) {$go_out{$g} = 1}
			}
		}
}

     print "\"".$key."\"\t\"";
     print "\"\t\"". $ANNOT{$key}{Name};
     print "\"\t\"". $ANNOT{$key}{Coils};
     print "\"\t\"". $ANNOT{$key}{Gene3D};
     print "\"\t\"". $ANNOT{$key}{Hamap};
     print "\"\t\"". $ANNOT{$key}{Pfam};
     print "\"\t\"". $ANNOT{$key}{PIRSF};
     print "\"\t\"". $ANNOT{$key}{PRINTS};
     print "\"\t\"". $ANNOT{$key}{ProDom};
     print "\"\t\"". $ANNOT{$key}{ProSitePatterns};
     print "\"\t\"". $ANNOT{$key}{ProSiteProfiles};
     print "\"\t\"". $ANNOT{$key}{SMART};
     print "\"\t\"". $ANNOT{$key}{SUPERFAMILY};
     print "\"\t\"". $ANNOT{$key}{TIGRFAM};
     print "\"\t\"";
if (!%go_out) { 
    print "NA";
} 
else 
{
     foreach my $lp (keys %go_out) {print $lp,"\,"};
}
     print "\"\n";

# cut -f 1-6 temp1 | sort | uniq > temp2


}

