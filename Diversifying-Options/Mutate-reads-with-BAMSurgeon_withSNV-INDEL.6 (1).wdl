### Workflow name: MutateReadsWithBAMSurgeon
##
## This workflow uses the BAMSurgeon `addsnv.py` and `addindel.py' tool to introduce specific mutations into an analysis-ready BAM file.
##
## BAMSurgeon is a toolkit written by Adam Ewing et al. described in the paper cited below. The source code is
## available on Github at https://github.com/adamewing/bamsurgeon
##
## Combining tumor genome simulation with crowdsourcing to benchmark somatic single-nucleotide-variant detection.
## Adam D Ewing, Kathleen E Houlahan, Yin Hu, Kyle Ellrott, Cristian Caloian, Takafumi N Yamaguchi, J Christopher Bare,
## Christine P’ng, Daryl Waggott, Veronica Y Sabelnykova, ICGC-TCGA DREAM Somatic Mutation Calling Challenge
## participants, Michael R Kellen, Thea C Norman, David Haussler, Stephen H Friend, Gustavo Stolovitzky, Adam A
## Margolin, Joshua M Stuart, Paul C Boutros
## Published: May 18, 2015 | https://dx.doi.org/10.1038%2Fnmeth.3407
##
#### Main inputs
## - One BAM file to mutate
## - One or two files of input variants as described in the BAMSurgeon manual, with desired allele frequency for each
## - Reference genome, index and dictionary, plus BWA indices
##
#### Important parameters
## - None by default; BAMSurgeon parameters can be added using the optional `extra_params` argument.
##
#### Outputs
## - New BAM file with mutated reads with the desired allele(s) at the specified allele frequency
##
#### Workflow notes
## - The workflow is designed to be run per participant.
## - This workflow was designed for a use case where you'd like to add only one variant and/or indel. See the mutation file requirements in the manual.
## - The workflow first will insert a SNP if provided, then an INDEL if provided. 
## - A postprocessing task sorts and indexes the output BAM file as BAMSurgeon sometimes introduces sorting errors.
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
workflow MutateReadsWithBAMSurgeon {
  File? input_SNV_variants
  File? input_INDEL_variants

  File inputBam
  File inputBamIndex

  if(defined(input_SNV_variants)){
    call AddSNV { input: inputBam = inputBam }

    call SortAndIndexBam as SortAndIndexSNV {
      input:
        inputBam = AddSNV.outputBam
    }
  }


  if(defined(input_INDEL_variants)){
    call AddINDEL {
      input:
        inputBamIndex = select_first([SortAndIndexSNV.sortedBamIndex, inputBamIndex]),
        inputBam = select_first([SortAndIndexSNV.sortedBam, inputBam])
    }

    call SortAndIndexBam as SortAndIndexINDEL {
      input:
        inputBam = AddINDEL.outputBam
    }
  }
  
  output {
    File mutatedBam = select_first([SortAndIndexINDEL.sortedBam, SortAndIndexSNV.sortedBam])
    File mutatedBamIndex = select_first([SortAndIndexINDEL.sortedBamIndex, SortAndIndexSNV.sortedBamIndex])
  }
}

# TASK DEFINITIONS

# This task calls bamsurgeon addsnv.py to mutate the reads
task AddINDEL {

  # Command parameters
  File refFasta
  File refIndex
  File refDict
  File ref_pac
  File ref_sa
  File ref_bwt
  File ref_ann
  File ref_amb

  File inputBam
  File inputBamIndex

  File? input_INDEL_variants
  String? extra_INDEL_params
  
  # Runtime parameters
  Int preemptible_tries
  String docker_image
  String path_to_bin
  String picard_jar

  Int? mem_gb
  Int? disk_space_gb
  Int disk_size = ceil(size(inputBam, "GB")) + 20

  String outputBamName = basename(inputBam, '.bam') + ".mutated.bam"
  

  command {
    mv ${inputBamIndex} ${inputBam}.bai \
    && \
    python ${path_to_bin}addindel.py \
    -r ${refFasta} \
    -f ${inputBam} \
    -v ${input_INDEL_variants} \
    -o ${outputBamName} \
    --picardjar ${picard_jar} \
    --tagreads ${extra_INDEL_params}
  }


  runtime {
    preemptible: preemptible_tries
    docker: docker_image
    memory: select_first([mem_gb, 11]) + " GB"
    disks: "local-disk " + select_first([disk_space_gb, disk_size]) + " HDD"
  }
  
  output {
    File outputBam = "${outputBamName}"
  }
}

# This task calls bamsurgeon addsnv.py to mutate the reads
task AddSNV {

  # Command parameters
  File refFasta
  File refIndex
  File refDict
  File ref_pac
  File ref_sa
  File ref_bwt
  File ref_ann
  File ref_amb

  File inputBam
  File inputBamIndex

  File? input_SNV_variants
  String? extra_SNV_params
  
  # Runtime parameters
  Int preemptible_tries
  String docker_image
  String path_to_bin
  String picard_jar

  Int? mem_gb
  Int? disk_space_gb
  Int disk_size = ceil(size(inputBam, "GB")) + 20

  String outputBamName = basename(inputBam, '.bam') + ".mutated.bam"
  

  command {
    mv ${inputBamIndex} ${inputBam}.bai \
    && \
    python ${path_to_bin}addsnv.py \
    -r ${refFasta} \
    -f ${inputBam} \
    -v ${input_SNV_variants} \
    -o ${outputBamName} \
    --picardjar ${picard_jar} \
    --tagreads ${extra_SNV_params}
  }


  runtime {
    preemptible: preemptible_tries
    docker: docker_image
    memory: select_first([mem_gb, 11]) + " GB"
    disks: "local-disk " + select_first([disk_space_gb, disk_size]) + " HDD"
  }
  
  output {
    File outputBam = "${outputBamName}"
  }
}

task SortAndIndexBam {

  # Command parameters
  File inputBam

  # Runtime parameters
  Int preemptible_tries
  String docker_image
  String gatk_path

  Int? mem_gb
  Int? disk_space_gb
  Int disk_size = ceil(size(inputBam, "GB")) + 20

  String sortedBamName = basename(inputBam, '.bam') + ".sorted.bam"
  String bamIndexName = basename(sortedBamName, '.bam') + ".bai"

  command {
    ${gatk_path} SortSam \
    -I ${inputBam} \
    -O ${sortedBamName} \
    --SORT_ORDER coordinate \
    --CREATE_INDEX TRUE
  }

  runtime {
    preemptible: preemptible_tries
    docker: docker_image
    memory: select_first([mem_gb, 5]) + " GB"
    disks: "local-disk " + select_first([disk_space_gb, disk_size]) + " HDD"
  }

  output {
    File sortedBam = "${sortedBamName}"
    File sortedBamIndex = "${bamIndexName}"
  }
}

