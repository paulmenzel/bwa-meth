# wget http://hgdownload.soe.ucsc.edu/goldenPath/mm10/database/snp137Common.txt.gz
PATH=$PATH:.:..
set -e

REF=/data/Schwartz/brentp/mm10/ref/mm10.fa
R1=data/real_R1.fastq.gz
R2=data/real_R2.fastq.gz

fasta-methyl-sim $REF > mm10.meth.fa
fasta-polymorph data/snp137Common.txt.gz mm10.meth.fa mm10.meth.fa > mm10.poly.fa

fasta-paired-chunks -n 1000000 -l 100 mm10.poly.fa sim_R1.fa sim_R2.fa
fasta-bisulf-sim sim_R1.fa > sim.R1.bs.fa
fasta-bisulf-sim sim_R2.fa > sim.R2.bs.fa


fastq-sim sim.R1.bs.fa $R1 | awk 'NR % 4 == 1 { gsub(/ /, ":"); print  }(NR % 4 != 1)' > sim_R1_bs.fastq
fastq-sim sim.R2.bs.fa $R2 | awk 'NR % 4 == 1 { gsub(/ /, ":"); print  }(NR % 4 != 1)' > sim_R2_bs.fastq

python src/fix-names.py sim_R1_bs.fastq sim_R2_bs.fastq
gzip sim_R1.fastq
gzip sim_R2.fastq