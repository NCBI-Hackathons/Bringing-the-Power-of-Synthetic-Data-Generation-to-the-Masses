### Workflow name: Collect1000GParticipant
##
## This workflow collects the variants for a single participant from the master 1000 Genomes Projects Phase 3 data 
## stored as separate per-chromosome VCFs in GCS by Google Genomics (as mirror of the EBI site) and consolidates them 
## over all chromosomes.
##
#### Main inputs
## - Valid participant ID from the 1000 Genomes Project
## - Google bucket path to the Google Genomics mirror of the 1000G Phase 3 data
## - List of chromosomes to process (1 through 22 ; X is processed separately)
##
#### Outputs
## - Single VCF callset of variants for the participant and its index
##
#### Workflow notes
## - The workflow is designed to be run per 1000G Project participant.
## - The extraction of each participant set of variants and genotypes is scattered across the separate chromosome files.
## - The main collection task includes a fix for the original data's incomplete headers and a sorting step.
## - Due to different base filenames, chromosome X is processed separately, and chromosome Y is currently left out.
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
workflow Collect1000GParticipant {

  File refFasta
  File refIndex
  File refDict

  String gatk_docker_image
  String gatk_path

  String participantName
  Array[String] contigList
  String bucket

  scatter (contig in contigList) {

    call RetrieveAndSort {
      input:
        targetParticipant = participantName,
        targetInterval = contig,
        inputContigVcf = bucket+"ALL.chr"+contig+".phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf",
        refFasta = refFasta,
        refIndex = refIndex,
        refDict = refDict,
        docker_image = gatk_docker_image,
        gatk_path = gatk_path
    }
  }

  call RetrieveAndSort as RetrieveAndSortX {
    input:
      targetParticipant = participantName,
      targetInterval = "X",
      inputContigVcf = bucket+"ALL.chrX.phase3_shapeit2_mvncall_integrated_v1a.20130502.genotypes.vcf",
      refFasta = refFasta,
      refIndex = refIndex,
      refDict = refDict,
      docker_image = gatk_docker_image,
      gatk_path = gatk_path
  }

#  call RetrieveAndSort as RetrieveAndSortY {
#    input:
#      targetParticipant = participantName,
#      targetInterval = "Y",
#      inputContigVcf = bucket+"ALL.chrY.phase3_integrated_v1a.20130502.genotypes.vcf"
#  }

  call Consolidate {
    input:
      targetParticipant = participantName,
      inputCallsetsSorted = RetrieveAndSort.extractedCalls,
      inputCallsetX = RetrieveAndSortX.extractedCalls,
      refFasta = refFasta,
      refIndex = refIndex,
      refDict = refDict,
      docker_image = gatk_docker_image,
      gatk_path = gatk_path#,
#      inputCallsetY = RetrieveAndSortY.extractedCalls
  }

  output {
    File sampleVcf = Consolidate.consolidatedCalls
    File sampleVcfIdx = Consolidate.consolidatedCallsIdx
  }
}

# TASK DEFINITIONS

# This task extracts calls for the participant
task RetrieveAndSort {

  # Command parameters
  File refFasta
  File refIndex
  File refDict
  File inputContigVcf

  String targetInterval
  String targetParticipant

  String outputName = targetParticipant + "." + targetInterval + ".phase3.vcf"

  String? extra_params_select
  String? extra_params_sort
  String? extra_params_header

  # Runtime parameters
  Int preemptible_tries
  String docker_image
  String gatk_path
  Int machine_mem_gb
  Int disk_space_gb = ceil(size(inputContigVcf, "GB"))*2 + 20

  command {
    ${gatk_path} FixVcfHeader \
      -I ${inputContigVcf} \
      -O fixed.vcf \
      --CREATE_INDEX true \
      ${extra_params_header} \
      && \
    ${gatk_path} SelectVariants \
      -R ${refFasta} \
      -V fixed.vcf \
      -L ${targetInterval} \
      -O subset.vcf \
      -select-type SNP \
      -select-type INDEL \
      -select-type MIXED \
      --sample-name ${targetParticipant} \
      --exclude-non-variants \
      --remove-unused-alternates \
      ${extra_params_select} \
      && \
    ${gatk_path} SortVcf \
      -R ${refFasta} \
      -I subset.vcf \
      -O ${outputName} \
      --CREATE_INDEX true \
      ${extra_params_sort}
  }

  runtime {
    preemptible: preemptible_tries
    docker: docker_image
    memory: machine_mem_gb + " GB"
    disks: "local-disk " + disk_space_gb + " HDD"
  }

  output {
    File extractedCalls = outputName
    File extractedCallsIdx = outputName + ".idx"
  }
}

# This task consolidates VCFs across chromosomes
task Consolidate {

  # Command parameters
  File refFasta
  File refIndex
  File refDict
  Array[File] inputCallsetsSorted
  File inputCallsetX
#  File inputCallsetY

  String targetParticipant
  String outputName = targetParticipant + ".phase3.vcf"

  # Runtime parameters
  Int preemptible_tries
  String docker_image
  String gatk_path
  Int machine_mem_gb
  Int disk_space_gb

  # To retrieve Y calls add -I ${inputCallsetY} \

  command {
    ${gatk_path} MergeVcfs \
      -R ${refFasta} \
      -I ${sep=" -I " inputCallsetsSorted} \
      -I ${inputCallsetX} \
      -O ${outputName} \
      && \
    ${gatk_path} IndexFeatureFile \
      -F ${outputName}
  }

  runtime {
    preemptible: preemptible_tries
    docker: docker_image
    memory: machine_mem_gb + " GB"
    disks: "local-disk " + disk_space_gb + " HDD"
  }

  output {
    File consolidatedCalls = outputName
    File consolidatedCallsIdx = outputName + ".idx"
  }

  meta {
        description: "This workflow collects the variants for a single participant from the master 1000 Genomes Projects"
  }
}
