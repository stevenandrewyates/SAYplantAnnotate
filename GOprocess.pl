#!/usr/bin/perl
use strict;
use warnings;

print "# TCONS:\tUnique ID for transcript\n
# all ATG prefixes are derived from TAIR10, https://www.arabidopsis.org/ \n
# all Uniprot prefixes are derived from Uniprot (Swiss-Prot) downloaded 14.03.16 ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
# all IPR prefixes are derived from interproscan-5.16-55
# please see https://dendrome.ucdavis.edu/resources/tooldocs/interproscan/Readme.html
# 
# ATG_ID:\t ID number
# Uniprot_ID:\t ID
# AT_Desc:\t Description
# Uniprot_Desc:\t Description
# IPR_Desc:\tDescription
# ATG_GO:\tGene Ontology
# Uniprot_GO:\tGene Ontology
# IPR_GO:\tGene Ontology, taken from http://www.geneontology.org/external2go/hamap2go http://geneontology.org/external2go/pfam2go & http://geneontology.org/external2go/pirsf2go\n
# IPR_coils:\t
# IPR_Gene3D:\t  ftp://ftp.biochem.ucl.ac.uk/pub/
# IPR_Hamap:\t http://hamap.expasy.org/
# IPR_Pfam:\t http://pfam.xfam.org/
# IPR_pirsf:\tPIR SuperFamily: PIR SuperFamily (PIRSF) is a classification system based on evolutionary relationship of whole proteins. 
# IPR_PRINTS:\tThe PRINTS database houses a collection of protein family fingerprints.
# IPR_ProDom:\t  http://prodes.toulouse.inra.fr/prodom/current/html/download.php 
# IPR_PrositePatterns:\tftp://ftp.isrec.isb-sib.ch/sib-isrec/profiles/prosite.dat
# IPR_ProSiteProfiles:\tftp://ftp.isrec.isb-sib.ch/sib-isrec/profiles/prosite.dat
# IPR_SMART:\thttp://smart.embl-heidelberg.de/
# IPR_Superfamily:\t http://supfam.mrc-lmb.cam.ac.uk/SUPERFAMILY/
# IPR_TIGRFAM:\t ftp://ftp.tigr.org/pub/data/TIGRFAMs
# GO_nr:\tNon-redundant GO terms from ATG, Uniport and IPR
# GO_total:\tNumber of non-redundant GO terms from ATG, Uniport and IPR
# GO_single/multiple:\tNumer of unique GO terms / Number of GO terms found more than once\n";

print "#TCONS\t,ATG_ID,\tUniprot_ID\tAT_Desc\tUniprot_Desc\tIPR_Desc\tATG_GO\tUniprot_GO\tIPR_GO\tIPR_coils\tIPR_Gene3D\tIPR_Hamap\tIPR_Pfam\tIPR_pirsf\tIPR_PRINTS\tIPR_Prodom\tIPR_PrositePatterns\tIPR_ProSiteProfiles\tIPR_SMART\tIPR_Superfamily\tIPR_TIGRFAM\tGO_nr\tGO_total\tGO_single/multiple\n";
########################################
## get AT names
########################################
my %names;
open(AT, $ARGV[0]) or die "could not open file";

### go through the fasta file
while (<AT>) 
{
chomp;

#	{
	my @line = split /\"\t\"/, $_ ;
	my $TCONS = $line[0]; 	# good
	my $ATn = $line[1];	# good
	my $ATdesc = $line[2];	# good
	my $ATgo = $line[3];	# good
	my $UNn = $line[5];	# good
#	my $UNd =$line[5];
	my $UNgo =$line[6];	# good
	my $UNipr = $line[7];	# good
	my $UNdesc = $line[8];	# good

	my $HMName = $line[11];	# good
	my $HMCoils = $line[12];	# good
	my $HMGene3D = $line[13];	# good
	my $HMHamap = $line[14];	# good
	my $HMPfam = $line[15];	# good
	my $HMPIRSF = $line[16];	# good
	my $HMPRINTS = $line[17];	# good
	my $HMProDom = $line[18];
	my $HMProSitePatterns = $line[19];
	my $HMProSiteProfiles = $line[20];
	my $HMSMART = $line[21];
	my $HMSUPERFAMILY = $line[22];
	my $HMTIGRFAM = $line[23];
	my $HMgo = $line[24];

my %GO;
# check if the GO terms are empty
#	if ($UNgo =~ m//) {$UNgo = 'NA'; };
#	if ($ATgo =~ m//) {$ATgo = 'NA'; };
# empty white space 
	$ATgo =~ s/\s*//g;
	$UNgo =~ s/\s*//g;
	if($HMgo =~ m//) {$HMgo = "NA";};
	$HMgo =~ s/\s*//g;
# split their GO terms
	my @GOat = split /,/, $ATgo ;
	my @GOun = split /,/, $UNgo ;
	my @HMxx = split /,/, $HMgo ;
foreach (@GOat) {
		if ($_ =~ m/NA/ ) {next};
		$GO{$_} = 1
		}
foreach (@GOun) {
		if ($_ =~ m/NA/ ) {next};		
		if (exists($GO{$_})) {$GO{$_} = 2}
		else {$GO{$_} = 1}
		}

foreach (@HMxx) {
		if ($_ =~ m/NA/ ) {next};		
		if (exists($GO{$_})) {$GO{$_} = 2}
		else {$GO{$_} = 1}
		}


print "$TCONS\t";
print "$ATn\t";
print "$UNn\t";
print "$ATdesc\t";
print "$UNdesc\t";
print "$HMName\t";
print "$ATgo\t";
print "$UNgo\t";
{print "$HMgo\t"};
print "$HMCoils\t";
print "$HMGene3D\t";
print "$HMHamap\t";
print "$HMPfam\t";
print "$HMPIRSF\t";
print "$HMPRINTS\t";
print "$HMProDom\t";
print "$HMProSitePatterns\t";
print "$HMProSiteProfiles\t";
print "$HMSMART\t";
print "$HMSUPERFAMILY\t";
print "$HMTIGRFAM\t";



my $GOsingle = 0;
my $GOdouble = 0;
my $GOtotal = 0;
foreach (sort keys %GO) {
    	print "$_, ";
	if ($GO{$_} == 1) {$GOsingle++;};
	if ($GO{$_} == 2) {$GOdouble++;};
	$GOtotal++;
  }
	print "\t$GOtotal\t";
	print "$GOsingle/$GOdouble"; 
	print "\n";

#	}
}

#TCONS_00000015	AT1G72540	 Protein kinase superfamily protein 	GO:0005886, GO:0004674, GO:0005524, GO:0016772, GO:0016301, GO:0005524, GO:0004672, GO:0006468, GO:0004674, GO:0006468, GO:0006468, GO:0004672	Q9CAH1	Q9CAH1	GO:0000166, GO:0004672, GO:0004674, GO:0005524, GO:0005524, GO:0006468, GO:0016301, GO:0016310, GO:0016740	IPR017441, IPR000719, IPR008271, 	Putative receptor-like protein kinase At1g72540

