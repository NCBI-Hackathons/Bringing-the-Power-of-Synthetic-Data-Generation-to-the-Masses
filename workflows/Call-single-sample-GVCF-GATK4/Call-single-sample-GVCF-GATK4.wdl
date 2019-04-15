### Workflow name: CallSingleSampleGvcfGATK4
##
## This workflow uses GATK4 HaplotypeCaller to call variants per-sample and produce a GVCF file, which is an
## intermediate in the GATK joint calling workflow for germline short variants. The HaplotypeCaller's execution is
## scattered over sets of intervals, and followed by a merging step to produce a single file.
##
## GATK is a genomics toolkit mainly focused on variant discovery developed at the Broad Institute. For documentation
## and support, see https://software.broadinstitute.org/gatk. To cite the joint calling methodology, see the preprint
## cited below. The source code is available on Github at https://github.com/broadinstitute/gatk
##
## Scaling accurate genetic variant discovery to tens of thousands of samples
## Ryan Poplin, Valentin Ruano-Rubio, Mark A. DePristo, Tim J. Fennell, Mauricio O. Carneiro, Geraldine A. Van der
## Auwera, David E. Kling, Laura D. Gauthier, Ami Levy-Moonshine, David Roazen, Khalid Shakir, Joel Thibault, Sheila
## Chandran, Chris Whelan, Monkol Lek, Stacey Gabriel, Mark J. Daly, Benjamin Neale, Daniel G. MacArthur, Eric Banks
## Preprint posted: November 14, 2017 | https://doi.org/10.1101/201178
##
#### Main inputs
## - Reference genome, index and dictionary
## - Input BAM file for a single sample as identified in the RG:SM tag
## - List of lists of intervals to scatter across (any GATK-supported format)
##
#### Important parameters
## - For exomes, interval padding is crucial for calling variants on the outskirts of targets.
##
#### Outputs
## - One GVCF file in compressed .gz format and its .tbi index
##
#### Workflow notes
## - The workflow is designed to be run per sample (as identified in RG:SM).
## - The scatter across lists of intervals should be as balanced as possible to avoid wallclock bottlenecks.
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
workflow CallSingleSampleGvcfGATK4 {

  File scattered_calling_intervals_list

  String gatk_docker
  String gatk_path

  Array[File] scattered_calling_intervals = read_lines(scattered_calling_intervals_list)

  # Call variants in parallel over grouped calling intervals
  scatter (interval_file in scattered_calling_intervals) {

    # Generate GVCF by interval
    call HaplotypeCaller {
      input:
        interval_list = interval_file,
        docker_image = gatk_docker,
        gatk_path = gatk_path
    }
  }

  # Merge per-interval GVCFs
  call MergeGVCFs {
    input:
      input_vcfs = HaplotypeCaller.output_vcf,
      input_vcfs_indexes = HaplotypeCaller.output_vcf_index,
      docker_image = gatk_docker,
      gatk_path = gatk_path
  }

  # Outputs that will be retained when execution is complete
  output {
    File output_gvcf = MergeGVCFs.output_vcf
    File output_gvcf_index = MergeGVCFs.output_vcf_index
  }
}

# TASK DEFINITIONS

# HaplotypeCaller per-sample in GVCF mode
task HaplotypeCaller {

  # Command parameters
  File ref_dict
  File ref_fasta
  File ref_fasta_index
  File input_bam
  File input_bam_index
  File interval_list

  Int interval_padding
  String? extra_params_caller

  # Runtime parameters
  Int preemptible_tries
  String docker_image
  String gatk_path
  Int machine_mem_gb
  Int disk_space_gb

  Int command_mem_gb = machine_mem_gb - 1

  String output_filename = basename(input_bam, ".bam") + ".g.vcf.gz"

  command {
    ${gatk_path} --java-options "-Xmx${command_mem_gb}G -XX:GCTimeLimit=50 -XX:GCHeapFreeLimit=10" \
      HaplotypeCaller \
      -R ${ref_fasta} \
      -I ${input_bam} \
      --read-index ${input_bam_index} \
      -L ${interval_list} \
      -ip ${interval_padding} \
      -O ${output_filename} \
      -ERC GVCF \
      ${extra_params_caller}
  }

  runtime {
    preemptible: preemptible_tries
    docker: docker_image
    memory: machine_mem_gb + " GB"
    disks: "local-disk " + disk_space_gb + " HDD"
  }

  output {
    File output_vcf = "${output_filename}"
    File output_vcf_index = "${output_filename}.tbi"
  }
}
# Merge GVCFs generated per-interval for the same sample
task MergeGVCFs {

  # Command parameters
  Array[File] input_vcfs
  Array[File] input_vcfs_indexes

  String? extra_params_merge

  # Runtime parameters
  Int preemptible_tries
  String docker_image
  String gatk_path
  Int machine_mem_gb
  Int disk_space_gb

  Int command_mem_gb = machine_mem_gb - 1
  
  String output_filename = basename(input_vcfs[0], ".g.vcf.gz") + ".merged.g.vcf.gz"

  command {
    ${gatk_path} --java-options "-Xmx${command_mem_gb}G"  \
      MergeVcfs \
      --INPUT ${sep=' --INPUT ' input_vcfs} \
      --OUTPUT ${output_filename} \
      ${extra_params_merge}
  }

  runtime {
    preemptible: preemptible_tries
    docker: docker_image
    memory: machine_mem_gb + " GB"
    disks: "local-disk " + disk_space_gb + " HDD"
  }

  output {
    File output_vcf = "${output_filename}"
    File output_vcf_index = "${output_filename}.tbi"
  }
}
