# Crop-Wild Introgression in Rice

Wild: [Oryza glumaepatula](http://plants.ensembl.org/Oryza_sativa/Info/Index)

Domesticated(Crop): [Oryza sativa ssp. japonica](http://plants.ensembl.org/Oryza_glumaepatula/Info/Index)

This project aims to see the effects of [introgression](http://en.wikipedia.org/wiki/Introgression) between Costa Rican populations of O. glumaepatula and O. sativa, using sequencing data from 8 O.glum genomes and 1 genome of an individual produced from an O.glum/O.sativa hybrid backcrossed with O.sativa.

###`Scripts:`

`Preprocessing_and_Alignment_Pipeline.sh` is an ongoing attempt to run a pileline (closely following the pipeline made by Vince aka [vsbuffalo](https://github.com/RILAB/paap/blob/master/README.md)) that will do:

 1). Sort reads using [NGSUtils -fastqtils](http://ngsutils.org/modules/fastqutils/).
 
 2). Run reads through [seqqs](https://github.com/vsbuffalo/seqqs), which records metrics on read quality, length, base composition.
 
 3). Trim adapter sequences off of reads using [scythe](https://github.com/vsbuffalo/scythe).
 
 4). Quality-based trimming with [seqtk's](https://github.com/lh3/seqtk) trimfq.
 
 5). Aligng with Align with [BWA-MEM](https://github.com/lh3/bwa).


## O. glumaepatula VS O. sativa Reference Genomes 

**Comparisons:**
On a per chromosome basis between reference genomes on the following criteria in order to gauge their relative quality.

Chromosome from [O.glum](ftp://ftp.ensemblgenomes.org/pub/plants/release-23/fasta/oryza_glumaepatula/dna/) and [O.sat](ftp://ftp.ensemblgenomes.org/pub/plants/release-23/fasta/oryza_sativa/dna/): 1-12

Line Count, Character Count, “N” Count, %N of total Character Count

`Command Line Input:`

*Headerless Character Count:*

		less Oryza_glumaepatula.ALNU02000000.23.dna.chromosome.*.fa | sed 's/^>.*//g' | wc -c


*Headerless Line Count:*

		same as above, but wc -l instead.
	
*N Count:*

		less Oryza_glumaepatula.ALNU02000000.23.dna.chromosome.*.fa | grep "N" | wc -c


**Conclusions:** 
Assembly and sequencing of O. glumaepatula is not the best quality reference genome. O. sativa is of good quality (v7 is the 2nd best ref gen out there). Since there are so many more N’s in O. glum, it will be a problem for alignments and SNP calling.

