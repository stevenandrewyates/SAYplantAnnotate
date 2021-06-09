# SAYplantAnnotate

A pipeline for assigning functional annotation to plant proteins.

# Description
Much of my job is searching for what genes do. It's fun looking them up on TAIR and seeing if they match the phenotype I'm working on. But sometimes this isn't enough you need to annotate a whole bunch of them. Maybe a whole genome of them. This repository will annotate proteins using TAIR, arabidopsis (it may include interproscan later). Why TAIR you ask? Most work in plants is done in Arabidopsis, in fact > 37% of protein annotation comes from direct experimental evidence. Meaning somebody in a labcoat has actually worked on this. So why not use this? Everything else is inferred from TAIR, so cut out the middle man/woman/plant and go directly to the source of the annotation. The pipeline below works on Euler and will make a nice table with the corresponding best BLAST hit from TAIR and it's associated GO terms (ready formatted for TopGO).

# Annotating using TAIR

First navigate (`cd`) to your *SCRATCH* directory (on euler) the make a directory (`mkdir`) for your data; finally change into this directory.
```
cd $SCRATCH
mkdir KYUSSannotate
cd KYUSSannotate/
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
