### Workflow name: MutateReadsWithBAMSurgeon
##
## This workflow uses the BAMSurgeon `addsnv.py` tool to introduce specific mutations into an analysis-ready BAM file.
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
## - One file of input variants as described in the BAMSurgeon manual, with desired allele frequency for each
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
## - This workflow was designed for a use case where only one variant is added so there is no scatter.
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

  File input_bam
  File input_bam_index
  File? snp_variants
  File? indel_variants
  File ref_fasta
  File ref_fasta_index
  File ref_dict
  File ref_pac
  File ref_sa
  File ref_bwt
  File ref_ann
  File ref_amb
  String? snp_extra_params
  String? indel_extra_params

  if (defined(snp_variants)) {
    call AddSNV {
      input:
        input_bam = input_bam,
        input_bam_index = input_bam_index,
        ref_fasta = ref_fasta,
        ref_fasta_index = ref_fasta_index,
        ref_dict = ref_dict,
        ref_pac = ref_pac,
        ref_sa = ref_sa,
        ref_bwt = ref_bwt,
        ref_ann = ref_ann,
        ref_amb = ref_amb,
        snp_variants = select_first([snp_variants]),
        snp_extra_params = snp_extra_params
    }

    call SortAndIndexBam as SnpSortAndIndexBam {
      input:
        input_bam = AddSNV.output_bam
    }
  }

  if (defined(indel_variants)) {
    File indel_bam = select_first([SnpSortAndIndexBam.sorted_bam, input_bam])
    File indel_bam_index = select_first([SnpSortAndIndexBam.sorted_bam_index, input_bam_index])

    call AddINDEL {
      input:
        input_bam = indel_bam,
        input_bam_index = indel_bam_index,
        ref_fasta = ref_fasta,
        ref_fasta_index = ref_fasta_index,
        ref_dict = ref_dict,
        ref_pac = ref_pac,
        ref_sa = ref_sa,
        ref_bwt = ref_bwt,
        ref_ann = ref_ann,
        ref_amb = ref_amb,
        indel_variants = indel_variants,
        indel_extra_params = indel_extra_params,
    }

    call SortAndIndexBam as IndelSortAndIndexBam {
      input:
        input_bam = AddINDEL.output_bam
    }
  }

  output {
    File mutated_bam = select_first([IndelSortAndIndexBam.sorted_bam, SnpSortAndIndexBam.sorted_bam])
    File mutated_bam_index = select_first([IndelSortAndIndexBam.sorted_bam_index, SnpSortAndIndexBam.sorted_bam_index])
  }
}

# TASK DEFINITIONS

# This task calls bamsurgeon addsnv.py to mutate the reads
task AddSNV {

  # Command parameters
  File input_bam
  File input_bam_index
  File snp_variants
  String? snp_extra_params

  File ref_fasta
  File ref_fasta_index
  File ref_dict
  File ref_pac
  File ref_sa
  File ref_bwt
  File ref_ann
  File ref_amb
  
  # Runtime parameters
  Int? mem_gb
  Int? disk_space_gb

  Int preemptible_tries = 3
  String docker_image = "lethalfang/bamsurgeon:1.1-3"
  String path_to_bamsurgeon = "/usr/local/bamsurgeon/bin/"
  String picard_jar = "/usr/local/picard-tools-1.131/picard.jar"
  Int disk_size = ceil(size(input_bam, "GB") * 2) + 20

  String output_bam_name = basename(input_bam)
  
  command {
    mv ${input_bam_index} ${input_bam}.bai \
      && \
    python ${path_to_bamsurgeon}addsnv.py \
    	-r ${ref_fasta} \
    	-f ${input_bam} \
    	-v ${snp_variants} \
    	-o ${output_bam_name} \
    	--picardjar ${picard_jar} \
    	--tagreads ${snp_extra_params}
  }
  
  runtime {
    preemptible: preemptible_tries
    docker: docker_image
    memory: select_first([mem_gb, 3]) + " GB"
    disks: "local-disk " + select_first([disk_space_gb, disk_size]) + " HDD"
  }
  
  output {
    File output_bam = "${output_bam_name}"
  }
}

# This task calls bamsurgeon addsnv.py to mutate the reads
task AddINDEL {

  # Command parameters
  File input_bam
  File input_bam_index
  File indel_variants
  String? indel_extra_params

  File ref_fasta
  File ref_fasta_index
  File ref_dict
  File ref_pac
  File ref_sa
  File ref_bwt
  File ref_ann
  File ref_amb

  # Runtime parameters
  Int? mem_gb
  Int? disk_space_gb

  Int preemptible_tries = 3
  String docker_image = "lethalfang/bamsurgeon:1.1-3"
  String path_to_bamsurgeon = "/usr/local/bamsurgeon/bin/"
  String picard_jar = "/usr/local/picard-tools-1.131/picard.jar"
  Int disk_size = ceil(size(input_bam, "GB") * 2) + 20

  String output_bam_name = basename(input_bam)

  command {
    mv ${input_bam_index} ${input_bam}.bai \
      && \
    python ${path_to_bamsurgeon}addindel.py \
    	-r ${ref_fasta} \
    	-f ${input_bam} \
    	-v ${indel_variants} \
    	-o ${output_bam_name} \
    	--picardjar ${picard_jar} \
    	--tagreads ${indel_extra_params}
  }

  runtime {
    preemptible: preemptible_tries
    docker: docker_image
    memory: select_first([mem_gb, 3]) + " GB"
    disks: "local-disk " + select_first([disk_space_gb, disk_size]) + " HDD"
  }

  output {
    File output_bam = "${output_bam_name}"
  }
}

task SortAndIndexBam {

  # Command parameters
  File input_bam

  # Runtime parameters
  Int? mem_gb
  Int? disk_space_gb

  Int preemptible_tries = 3
  String docker_image = "us.gcr.io/broad-gatk/gatk:4.0.9.0"
  String gatk_path = "/gatk/gatk"
  Int disk_size = ceil(size(input_bam, "GB") * 3.25) + 20

  String sorted_bam_name = basename(input_bam, '.bam') + ".mutated.sorted.bam"
  String bam_index_name = basename(sorted_bam_name, '.bam') + ".bai"

  command {
    ${gatk_path} SortSam \
      -I ${input_bam} \
      -O ${sorted_bam_name} \
      --SORT_ORDER coordinate \
      --CREATE_INDEX TRUE \
      --MAX_RECORDS_IN_RAM=300000
  }

  runtime {
    preemptible: preemptible_tries
    docker: docker_image
    memory: select_first([mem_gb, 5]) + " GB"
    disks: "local-disk " + select_first([disk_space_gb, disk_size]) + " HDD"
  }

  output {
    File sorted_bam = "${sorted_bam_name}"
    File sorted_bam_index = "${bam_index_name}"
  }
}

