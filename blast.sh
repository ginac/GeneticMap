#!/bin/sh

FILES=`ls -1 fasta`
for FILE in $FILES
do
echo $FILE
#will remove everything after the first .
PREFIX=$(echo $FILE |cut -d'.' -f 1)
echo $PREFIX

#blastn -db /home/cannarozzi/genomes/Peax400/HIC_post_Chicago/Peax500.fasta -query fasta/$FILE -out blast_Peax500/blastn.$PREFIX.Pax500 -evalue 1e-70 -outfmt 6 
blastn -db /home/cannarozzi/genomes/Peax400/HIC_post_Chicago/Peax501.fasta -query fasta/$FILE -out blast_Peax501/blastn.$PREFIX.Pax501 -evalue 1e-70 -outfmt 6 
#blastn -db /home/cannarozzi/genomes/Peax400/hicassembly/Peax400.fasta -query fasta/$FILE -out blast_Peax400/blastn.$PREFIX.Pax400 -evalue 1e-70 -outfmt 6 
#blastn -db /home/cannarozzi/genomes/Peax400/hicassembly/Peax401.fasta -query fasta/$FILE -out blast_Peax401/blastn.$PREFIX.Pax401 -evalue 1e-70 -outfmt 6 
#blastn -db /home/cannarozzi/Storage/genomes/paxillaris/P.axillaris.v.3_HIC/Peax304.fasta -query $FILE -out blastn.$PREFIX.Pax304 -evalue 1e-70 -outfmt 6 
#blastn -db /home/cannarozzi/Storage/genomes/pexserta/Pexserta.v3_HIC/Petunia_exserta.v3.0.3.fasta -query $FILE -out blastn.$PREFIX.Pex303 -evalue 1e-70 -outfmt 6 

done;
