set -e
cd ~/obss2021/genomic_dna/results

genome=~/obss2021/genomic_dna/data/ref_genome/ecoli_rel606.fasta

bwa index $genome

mkdir -p sam bam bcf vcf

for fq1 in ~/obss2021/genomic_dna/data/trimmed_fastq_small/*_1.trim.sub.fastq
    do
    echo "working with file $fq1"

    base=$(basename $fq1 _1.trim.sub.fastq)
    echo "base name is $base"

    fq1=~/obss2021/genomic_dna/data/trimmed_fastq_small/${base}_1.trim.sub.fastq
    fq2=~/obss2021/genomic_dna/data/trimmed_fastq_small/${base}_2.trim.sub.fastq
    sam=~/obss2021/genomic_dna/results/sam/${base}.aligned.sam
    bam=~/obss2021/genomic_dna/results/bam/${base}.aligned.bam
    sorted_bam=~/obss2021/genomic_dna/results/bam/${base}.aligned.sorted.bam
    raw_bcf=~/obss2021/genomic_dna/results/bcf/${base}_raw.bcf
    variants=~/obss2021/genomic_dna/results/bcf/${base}_variants.vcf
    final_variants=~/obss2021/genomic_dna/results/vcf/${base}_final_variants.vcf 

    bwa mem $genome $fq1 $fq2 > $sam
    samtools view -S -b $sam > $bam
    samtools sort -o $sorted_bam $bam 
    samtools index $sorted_bam
    bcftools mpileup -O b -o $raw_bcf -f $genome $sorted_bam
    bcftools call --ploidy 1 -m -v -o $variants $raw_bcf 
    vcfutils.pl varFilter $variants > $final_variants
   
    done
