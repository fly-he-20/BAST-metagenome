
## metagenom analysis of BATS deep metagenome sequencing.

#  our raw data in the data file

# FastQC Quality Assessment

nohup fastqc data/*.gz -t 30 &

## quality control

java -jar $TRIMMOMATIC_PATH PE \
  -threads 20 \
  -phred33 \
  $INPUT_R1 $INPUT_R2 \
  $OUTPUT_R1_PAIRED $OUTPUT_R1_UNPAIRED \
  $OUTPUT_R2_PAIRED $OUTPUT_R2_UNPAIRED \
  ILLUMINACLIP:$ADAPTERS_PATH:2:30:10 \
  LEADING:3 \
  TRAILING:3 \
  SLIDINGWINDOW:4:15 \
  MINLEN:36


## assembly with megahit

# set variable
MEGAHIT_PATH=/path/to/megahit
INPUT_DIR=/path/to/fastq_files
OUTPUT_DIR=/path/to/output_directory

# build content
mkdir -p $OUTPUT_DIR

# assemble
for sample in sample1 sample2 sample3  # 你可以添加更多的样本名
do
  INPUT_R1=$INPUT_DIR/${sample}_R1.fastq
  INPUT_R2=$INPUT_DIR/${sample}_R2.fastq
  SAMPLE_OUTPUT_DIR=$OUTPUT_DIR/${sample}_megahit_output

  echo "begining assemble：$sample"

  # run MEGAHIT
  $MEGAHIT_PATH -1 $INPUT_R1 -2 $INPUT_R2 -o $SAMPLE_OUTPUT_DIR


## binning analysis

echo  "binning"
  mkdir -p $SAMPLE_OUTPUT_DIR/binning
  metawrap binning -o $SAMPLE_OUTPUT_DIR/binning -t $THREADS -a $SAMPLE_OUTPUT_DIR/assembly/final_assembly.fasta $INPUT_R1 $INPUT_R2

  # 步骤3：bin优化
  echo "bin check"
  mkdir -p $SAMPLE_OUTPUT_DIR/bin_refinement
  metawrap bin_refinement -o $SAMPLE_OUTPUT_DIR/bin_refinement -t $THREADS -A $SAMPLE_OUTPUT_DIR/binning/metabat2_bins -B $SAMPLE_OUTPUT_DIR/binning/maxbin2_bins -C $SAMPLE_OUTPUT_DIR/binning/concoct_bins -c 70 -x 10

  # bin check
  echo "bin check"
  mkdir -p $SAMPLE_OUTPUT_DIR/bin_stats
  metawrap bin_stats -o $SAMPLE_OUTPUT_DIR/bin_stats -t $THREADS $SAMPLE_OUTPUT_DIR/bin_refinement/metawrap_50_10_bins

  echo "sample $sample result in $SAMPLE_OUTPUT_DIR"
done

echo "finish"
















































