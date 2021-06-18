# SAYplantAnnotate

A pipeline for assigning functional annotation to plant proteins.

# Description
Much of my job is searching for what genes do. It's fun looking them up on TAIR and seeing if they match the phenotype I'm working on. But sometimes this isn't enough you need to annotate a whole bunch of them. Maybe a whole genome of them. This repository will annotate proteins using TAIR, arabidopsis. Why TAIR you ask? Most work in plants is done in Arabidopsis, in fact > 37% of protein annotation comes from direct experimental evidence. Meaning somebody in a labcoat has actually worked on this. So why not use this? Everything else is inferred from TAIR, so cut out the middle man/woman/plant and go directly to the source of the annotation. The pipeline below works on Euler and will make a nice table with the corresponding best BLAST hit from TAIR and its associated GOterms (ready formatted for TopGO).

# Annotating using TAIR

First navigate (`cd`) to your *SCRATCH* directory (on euler) the make a directory (`mkdir`) for your data; finally change into this directory.
```
cd $SCRATCH
mkdir annotate
cd annotate/
```

Next let's download (`wget`) and install (`module load`) the things we need: this includes `blast` and this `git` repository. Also we need the gene ontology (*ATH_GO_GOSLIM.txt*) data and proteins (*TAIR10_pep_20101214*) for arabidopsis.

```
module load blast
module load git
git clone https://github.com/stevenandrewyates/SAYplantAnnotate
wget https://www.arabidopsis.org/download_files/Public_Data_Releases/TAIR_Data_20140630/ATH_GO_GOSLIM.txt
wget https://www.arabidopsis.org/download_files/Proteins/TAIR10_protein_lists/TAIR10_pep_20101214
```

Once downloaded we can prepare a protein (`-dbtype 'prot'`) `blast` database.

```
makeblastdb -in TAIR10_pep_20101214 -dbtype 'prot' -parse_seqids -out AT
```

The next part takes a bit of time, but patience will prevail. You need to `blastp` your *proteins(.fa)* against the arabidopsis protein database (*AT*) 

```
blastp -db AT -evalue 1e-15 -query proteins.fa -outfmt 6 > PEP.hits
```

Finally a little *perl* script I prepared puts everything together, but we need a list of the protein names beforehand. Which is extracted using the `cut`command with a few pipes (`|`). After pass the list of arabidopsis proteins (*TAIR10_pep_20101214*, which contains the names), the GO data (*ATH_GO_GOSLIM.txt*), and the `blastp` results (*PEP.hits*) to the script. Don't forget to redirect (`>`) the results to an output file (*IDs_for_genes.txt*)  

```
cut -f1 PEP.hits  | sort | uniq > names
perl SAYplantAnnotate/ATnames.pl TAIR10_pep_20101214 ATH_GO_GOSLIM.txt PEP.hits names > IDs_for_genes.txt
```

# Example

In the example below, to test everything works, six coffee genes will be annotated.

```
cd $SCRATCH
mkdir Coffee
cd Coffee/
module load blast
module load git
git clone https://github.com/stevenandrewyates/SAYplantAnnotate
wget https://www.arabidopsis.org/download_files/Public_Data_Releases/TAIR_Data_20140630/ATH_GO_GOSLIM.txt
wget https://www.arabidopsis.org/download_files/Proteins/TAIR10_protein_lists/TAIR10_pep_20101214
makeblastdb -in TAIR10_pep_20101214 -dbtype 'prot' -parse_seqids -out AT
blastp -db AT -evalue 1e-15 -query SAYplantAnnotate/CoffeeGenes.fasta -outfmt 6 > PEP.hits
cut -f1 PEP.hits  | sort | uniq > names
perl SAYplantAnnotate/ATnames.pl TAIR10_pep_20101214 ATH_GO_GOSLIM.txt PEP.hits names > CoffeeAnnotate.txt
```

Voila


# Interproscan

Previously proteins were functionally annotated based on similarity with other proteins (arabidopsis). However, arabidopsis doesn't have everything, plants evolve and diverge. So to get a holistic overview of protein function we will use a motif scanning tool to find functional domains in the proteins: using [Interproscan](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3998142/). There are many different kinds of motifs (types of proteins) and different ways of scanning these motifs. InterProscan provides a one-stop-shop for protein classification, where all the signatures produced by the different member databases are placed into entries within the InterPro database


For this work I was using a linux workstation (the one ending in 2). Unfortunatley I couldn't get this to work on the Euler computer (this process is not run often so it was difficult to justify spending extra time on getting it to work on Euler). Anyway to begin we will download the tools needed, they include: Java version 11, Interproscan and this repository.

```
sudo dnf install java-11-openjdk.x86_64
wget ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/5.52-86.0/interproscan-5.52-86.0-64-bit.tar.gz
wget ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/5.52-86.0/interproscan-5.52-86.0-64-bit.tar.gz.md5
md5sum -c interproscan-5.52-86.0-64-bit.tar.gz.md5
tar -pxvzf interproscan-5.52-86.0-*-bit.tar.gz
cd interproscan-5.52-86.0/
python3 initial_setup.py
git clone https://github.com/stevenandrewyates/SAYplantAnnotate
```

In addition three lookup databases are needed to assign [Gene Ontology (GOterms)](http://geneontology.org/docs/ontology-documentation/), they can be downloaded easily.
```
wget http://www.geneontology.org/external2go/hamap2go
wget ftp://ftp.ebi.ac.uk/pub/databases/GO/goa/external2go/pirsf2go
wget ftp://ftp.ebi.ac.uk/pub/databases/GO/goa/external2go/pfam2go
```

Interproscan (v.5.52-86.0) requires Java 11, which was downloaded above. However you may need to change to Java 11, this can be done using:
```
sudo alternatives --config java
```

Now interproscan can be used. In this case using the six coffeee genes included in this repository.
```
./interproscan.sh -i  SAYplantAnnotate/CoffeeGenes.fasta -o Interout.txt -f tsv
```

Now we can use some simple commands to clean up the output. This will prevent parsing errors later.

```
sed 's/_(..)//' Interout.txt > interpro.annot2.txt
cut -f 1-6 interpro.annot2.txt | sort | uniq > temp2
```

The results are in a long format, each line contains an annotation. Instead we will make a table with one line per protein: using the *Perl* script below.

```
perl SAYplantAnnotate/Uniprotannot.pl temp2 > INterANNOT.txt
```

Next we can merge the data from the arabidopsis BLAST annotation above using *Perl*.

```
perl SAYplantAnnotate/mergeAnnot2.pl IDs_for_gene INterANNOT.txt > AllAnnot.txt
```

Finally, the last *Perl* script will search the GO terms from both annotation sources and provide a non redundant list.
```
perl SAYplantAnnotate/GOprocess.pl AllAnnot.txt | sed 's/^\"Ge/Ge/g' |grep -v 'NA.NA.NA.NA.NA.NA.NA.NA.NA.NA.NA.NA.NA.NA.NA.NA.NA' > AllGo.txt 
```
Voila


