### Workflow name: GenerateSyntheticReads
##
## This workflow uses the NEAT toolkit to generate synthetic paired-end read data based on a file of input variants
## and a desired mutation rate (can be 0 to not include any random mutation in addition to the input variants).
## It creates an analysis-ready BAM file and a "ground truth" VCF.
##
## NEAT is a toolkit written by Zachary Stephens et al. described in the paper cited below. The source code is
## available on Github at https://github.com/zstephens/neat-genreads
##
## Simulating Next-Generation Sequencing Datasets from Empirical Mutation and Sequencing Models
## Zachary D. Stephens , Matthew E. Hudson, Liudmila S. Mainzer, Morgan Taschuk, Matthew R. Weber, Ravishankar K. Iyer
## Published: November 28, 2016 | https://doi.org/10.1371/journal.pone.0167047
##
#### Main inputs
## - Participant ID or equivalent base name for naming outputs
## - VCF of variant calls to spike into the synthetic reads
## - List of scatter intervals list in BED format
## - Reference genome, index and dictionary
##
#### Important parameters
## - Mutation rate (between 0 and 0.3)
## - Average coverage
## - Read length to generate
## - Fragment length (mean and standard deviation)
## - Data type (for naming output files)
##
#### Outputs
## - Aligned BAM file and its index (generated separately by Picard after cleanup and adding readgroups)
## - Ground truth VCF (sites only, no real genotypes except for WP annotation)
##
#### Workflow notes
## - The workflow is designed to be run per participant.
## - The synthetic data generation is scattered across lists of intervals.
## - A preprocessing task removes complex variant records that would break other tasks.
## - Accessory tasks apply fixes for read names and VCF header issues.
## - Artificial read groups are added after merging.
##
#### Runtime notes
## - Cromwell version support: successfully tested on v34
## - Runtime parameters are optimized for Broad's Google Cloud Platform implementation.
## - For program versions, see docker containers.
##
#### Licensing
##### Copyright Broad Institute, 2018 | BSD-3
## This script is released under the WDL open source code license (BSD-3) (full license text at
## https://github.com/openwdl/wdl/blob/master/LICENSE). Note however that the programs it calls may be subject to
## different licenses. Users are responsible for checking that they are authorized to run all programs before running
## this script.

# WORKFLOW DEFINITION
workflow GenerateSyntheticReads {

  File refFasta
  File refIndex
  File refDict

  String gatk_docker_image
  String gatk_path

  String baseName
  String dataType

  File scatterIntervalsFileList

  Array[File] scatterIntervalsFiles = read_lines(scatterIntervalsFileList)

  call SanitizeVariants {
    input:
      baseName = baseName
  }

  scatter (intervalsListFile in scatterIntervalsFiles) {

      call GenerateReads {
        input:
          baseName = baseName,
          inputVariants = SanitizeVariants.outputVcf,
          targetIntervals = intervalsListFile,
          refFasta = refFasta,
          refIndex = refIndex,
          refDict = refDict
      }

      call FixVcfHeader {
        input:
          inputVcf = GenerateReads.genreadsVcf,
          refFasta = refFasta,
          refIndex = refIndex,
          refDict = refDict,
          docker_image = gatk_docker_image,
          gatk_path = gatk_path
      }

      call FixReadNames {
        input:
          inputBam = GenerateReads.genreadsBam
      }
  }

  call MergeBams {
    input:
      inputBams = FixReadNames.fixedBam,
      baseName = baseName,
      dataType = dataType,
      refFasta = refFasta,
      refIndex = refIndex,
      refDict = refDict,
      docker_image = gatk_docker_image,
      gatk_path = gatk_path
  }

  call AddReadGroups {
    input:
      inputBam = MergeBams.mergedBam,
      baseName = baseName,
      docker_image = gatk_docker_image,
      gatk_path = gatk_path
  }

  call MergeVcfs {
    input:
      inputVcfs = FixVcfHeader.fixedVcf,
      baseName = baseName,
      dataType = dataType,
      refFasta = refFasta,
      refIndex = refIndex,
      refDict = refDict,
      docker_image = gatk_docker_image,
      gatk_path = gatk_path
  }

  output {
    File syntheticBam = AddReadGroups.readGroupedBam
    File syntheticBamIndex = AddReadGroups.readGroupedBamIndex
    File truthVcf = MergeVcfs.mergedVcf
    File truthVcfIndex = MergeVcfs.mergedVcfIndex
  }

}

# TASK DEFINITIONS

# This task sanitizes variant records by removing the rsID field (multiple rsIDs break some operations)
task SanitizeVariants {

  # Command parameters
  File inputVariants
  String baseName

  String outputVcfName = basename(inputVariants, ".vcf") + ".sanitized.vcf"

  # Runtime parameters
  Int preemptible_tries
  String docker_image
  Int machine_mem_gb
  Int disk_space_gb

  command <<<
    awk 'BEGIN{OFS="\t"} {if ((substr($1,1,1) ~ /^#/) || ($10 !~ /2/) ) print}' ${inputVariants} > ${outputVcfName}
  >>>

  runtime {
    preemptible: preemptible_tries
    docker: docker_image
    memory: machine_mem_gb + " GB"
    disks: "local-disk " + disk_space_gb + " HDD"
  }

  output {
    File outputVcf = outputVcfName
  }
}

# This task calls NEAT genreads.py to generate the read data
task GenerateReads {

  # Command parameters
  File refFasta
  File refIndex
  File refDict
  File inputVariants
  File targetIntervals

  String baseName

  Int mutationRate
  Int readLength
  Int coverage
  Int meanFragmentLength
  Int stddevFragmentLength

  String? extra_params

  # Runtime parameters
  Int preemptible_tries
  String docker_image
  String path_to_bin
  Int machine_mem_gb
  Int disk_space_gb

  command {
    python ${path_to_bin}genReads.py \
      -r ${refFasta} \
      -v ${inputVariants} \
      -t ${targetIntervals} \
      -o ${baseName} \
      -M ${mutationRate} \
      -R ${readLength} \
      -c ${coverage} \
      --pe ${meanFragmentLength} ${stddevFragmentLength} \
      --bam \
      --vcf \
      --no-fastq \
      ${extra_params}
  }

  runtime {
    preemptible: preemptible_tries
    docker: docker_image
    memory: machine_mem_gb + " GB"
    disks: "local-disk " + disk_space_gb + " HDD"
  }

  output {
    File genreadsBam = baseName+"_golden.bam"
    File genreadsVcf = baseName+"_golden.vcf"
  }
}

# This task fixes incomplete VCF headers
task FixVcfHeader{

  # Command parameters
  File refFasta
  File refIndex
  File refDict
  File inputVcf
  File newHeader

  String outputVcfName = basename(inputVcf, ".vcf") + ".fixed.vcf"

  # Runtime parameters
  Int preemptible_tries
  String docker_image
  String gatk_path
  Int machine_mem_gb
  Int disk_space_gb

  command {
    ${gatk_path} FixVcfHeader \
      -I ${inputVcf} \
      -H ${newHeader} \
      -O ${outputVcfName}
  }

  runtime {
    preemptible: preemptible_tries
    docker: docker_image
    memory: machine_mem_gb + " GB"
    disks: "local-disk " + disk_space_gb + " HDD"
  }

  output {
    File fixedVcf = outputVcfName
    File fixedVcfIdx = outputVcfName + ".idx"
  }
}

# This task fixes malformed read names with an awk command that strips \1 and \2
task FixReadNames {

  # Command parameters
  File inputBam
  String outputBam = basename(inputBam, ".bam") + ".fixed.bam"

  # Runtime parameters
  Int preemptible_tries
  String docker_image
  Int machine_mem_gb
  Int disk_space_gb

  command <<<
    samtools view -h ${inputBam} | awk 'BEGIN{OFS="\t"} {sub(/\/[12]/,"",$1); print}' | samtools view -h -b > ${outputBam}
  >>>

  runtime {
    preemptible: preemptible_tries
    docker: docker_image
    memory: machine_mem_gb + " GB"
    disks: "local-disk " + disk_space_gb + " HDD"
  }

  output {
    File fixedBam = outputBam
  }
}

# This task merges bams
task MergeBams {

  # Command parameters
  File refFasta
  File refIndex
  File refDict
  Array[File] inputBams

  String baseName
  String dataType

  String outputBamName = baseName + "synthetic."+dataType+".merged.bam"

  File inputList = write_lines(inputBams)

  # Runtime parameters
  Int preemptible_tries
  String docker_image
  String gatk_path
  Int machine_mem_gb
  Int disk_space_gb

  command {
    ${gatk_path} MergeSamFiles \
      -R ${refFasta} \
      -I ${sep=' -I ' inputBams} \
      -O ${outputBamName} \
      --VALIDATION_STRINGENCY SILENT
  }

  runtime {
    preemptible: preemptible_tries
    docker: docker_image
    memory: machine_mem_gb + " GB"
    disks: "local-disk " + disk_space_gb + " HDD"
  }

  output {
    File mergedBam = outputBamName
  }
}

# This task adds read group information
task AddReadGroups {

  # Command parameters
  String baseName
  File inputBam

  String outputBamName = basename(inputBam, ".merged.bam") + ".bam"
  String outputBamIndexName = basename(inputBam, ".merged.bam") + ".bai"

  # Runtime parameters
  Int preemptible_tries
  String docker_image
  String gatk_path
  Int machine_mem_gb
  Int disk_space_gb


  command {
    ${gatk_path} PrintReads \
      -I ${inputBam} \
      -O filtered.bam \
      --disable-read-filter WellformedReadFilter \
      --read-filter GoodCigarReadFilter \
      && \
    ${gatk_path} AddOrReplaceReadGroups \
      --INPUT filtered.bam \
      --OUTPUT ${outputBamName} \
      --RGID ${baseName} \
      --RGSM ${baseName} \
      --RGLB ${baseName} \
      --RGPU ${baseName} \
      --RGPL illumina \
      --CREATE_INDEX TRUE
  }

  runtime {
    preemptible: preemptible_tries
    docker: docker_image
    memory: machine_mem_gb + " GB"
    disks: "local-disk " + disk_space_gb + " HDD"
  }

  output {
    File readGroupedBam = outputBamName
    File readGroupedBamIndex = outputBamIndexName
  }
}

# This task merges vcfs
task MergeVcfs {

  # Command parameters
  File refFasta
  File refIndex
  File refDict
  Array[File] inputVcfs

  String baseName
  String dataType

  String outputVcfName = baseName + ".synthetic."+dataType+".truth.vcf"

  # Runtime parameters
  Int preemptible_tries
  String docker_image
  String gatk_path
  Int machine_mem_gb
  Int disk_space_gb

  command {
    ${gatk_path} MergeVcfs \
      -R ${refFasta} \
      -I ${sep=' -I ' inputVcfs} \
      -O ${outputVcfName} \
      --CREATE_INDEX TRUE
  }

  runtime {
    preemptible: preemptible_tries
    docker: docker_image
    memory: machine_mem_gb + " GB"
    disks: "local-disk " + disk_space_gb + " HDD"
  }

  output {
    File mergedVcf = outputVcfName
    File mergedVcfIndex = outputVcfName + ".idx"
  }
}

