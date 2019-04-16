
#### Licensing
##### Copyright Broad Institute, 2018 | BSD-3
## This script is released under the WDL open source code license (BSD-3) (full license text at
## https://github.com/openwdl/wdl/blob/master/LICENSE). Note however that the programs it calls may be subject to
## different licenses. Users are responsible for checking that they are authorized to run all programs before running
## this script.

## This script takes an input list of synthetic data files, real data file & index and produces output files which can be 
## used to cpmpare results to verify the quality of the synthetic data

workflow CollectQualityMetrics { 

  File real_input_bam
  File real_input_bam_index
  File ref_fasta
  File ref_fasta_index
  File interval_list
  File bait_interval_list
  Int preemptible_tries
  Int read_length
  Array[File] synth_inputs # file input array of all synthetic data files
  
  Boolean wgsMetrics # flag to indicate if wgsMetrics should be run
  Boolean exomeMetrics # flag to indicate if exomeMetrics should be run

  # TODO: this scatter means that the real input file metrics are run twice. The 
  #       scatter should only be relevant to the synthetic data. We have just repeated
  #       the block but this could be done more elegantly

  scatter (bam in synth_inputs) {
    File bai = sub(bam, ".bam", ".bai")

    if (wgsMetrics) {  
      call CollectWgsMetrics as SynthWgsMetrics {
      input: 
        input_bam = bam,
        input_bam_index = bai,
        ref_fasta = ref_fasta,
        ref_fasta_index = ref_fasta_index,
        wgs_coverage_interval_list = interval_list,
        preemptible_tries = preemptible_tries,
        read_length = read_length,
        metrics_filename = basename(bam, ".bam") + "_synth_metrics.txt"
      }
    }
    
    if (exomeMetrics) {
      call CollectHsMetrics as SynthHsMetrics {
      input: 
        input_bam = bam,
        input_bam_index = bai,
        ref_fasta = ref_fasta,
        ref_fasta_index = ref_fasta_index,
        bait_interval_list = bait_interval_list,
        target_interval_list = interval_list,
        preemptible_tries = preemptible_tries,
        metrics_filename = basename(bam, ".bam") + "_synth_metrics.txt"
      }
    }
  }

  if (wgsMetrics) {  
    call CollectWgsMetrics as RealWgsMetrics {
    input: 
      input_bam = bam,
      input_bam_index = bai,
      ref_fasta = ref_fasta,
      ref_fasta_index = ref_fasta_index,
      wgs_coverage_interval_list = interval_list,
      preemptible_tries = preemptible_tries,
      read_length = read_length,
      metrics_filename = basename(bam, ".bam") + "_real_metrics.txt"
    }
  }

  if (exomeMetrics) {
    call CollectHsMetrics as RealHsMetrics {
    input: 
      input_bam = bam,
      input_bam_index = bai,
      ref_fasta = ref_fasta,
      bait_interval_list = bait_interval_list,
      ref_fasta_index = ref_fasta_index,
      target_interval_list = interval_list,
      preemptible_tries = preemptible_tries,
      metrics_filename = basename(bam, ".bam") + "_real_metrics.txt"
    }
  }


}


# Note these tasks will break if the read lengths in the bam are greater than 250.
task CollectWgsMetrics {
  File input_bam
  File input_bam_index
  String metrics_filename
  File wgs_coverage_interval_list
  File ref_fasta
  File ref_fasta_index
  Int read_length
  Int preemptible_tries
#   Pair[File, File] synth_inputs - TODO allow input of an "array of arrays"

  Float ref_size = size(ref_fasta, "GB") + size(ref_fasta_index, "GB")
  Int disk_size = ceil(size(input_bam, "GB") + ref_size) + 20

  command {
    java -Xms2000m -jar /usr/gitc/picard.jar \
      CollectWgsMetrics \
      INPUT=${input_bam} \
      VALIDATION_STRINGENCY=SILENT \
      REFERENCE_SEQUENCE=${ref_fasta} \
      INCLUDE_BQ_HISTOGRAM=true \
      INTERVALS=${wgs_coverage_interval_list} \
      OUTPUT=${metrics_filename} \
      USE_FAST_ALGORITHM=true \
      READ_LENGTH=${read_length}
  }
  runtime {
    docker: "us.gcr.io/broad-gotc-prod/genomes-in-the-cloud:2.3.2-1510681135"
    preemptible: preemptible_tries
    memory: "3 GB"
    disks: "local-disk " + disk_size + " HDD"
  }
  output {
    File metrics = "${metrics_filename}"
  }
}

task CollectHsMetrics {
  File input_bam
  File input_bam_index
  File ref_fasta
  File ref_fasta_index
  String metrics_filename
  File target_interval_list
  File bait_interval_list
  Int preemptible_tries
#   Pair[File, File] synth_inputs - TODO allow input of an "array of arrays"

  Float ref_size = size(ref_fasta, "GB") + size(ref_fasta_index, "GB")
  Int disk_size = ceil(size(input_bam, "GB") + ref_size) + 20

  # Try to fit the input bam into memory, within reason.
  Int rounded_bam_size = ceil(size(input_bam, "GB") + 0.5)
  Int java_mem_size = if (rounded_bam_size > 9) then 9 else rounded_bam_size
  Int final_java_mem_size = if (java_mem_size < 2) then 2 else java_mem_size
  Int mem_size = final_java_mem_size + 1
  
  # There are probably more metrics we want to generate with this tool
  command {
    java -Xms${final_java_mem_size * 1000}m -jar /usr/gitc/picard.jar \
      CollectHsMetrics \
      INPUT=${input_bam} \
      REFERENCE_SEQUENCE=${ref_fasta} \
      VALIDATION_STRINGENCY=SILENT \
      TARGET_INTERVALS=${target_interval_list} \
      BAIT_INTERVALS=${bait_interval_list} \
      METRIC_ACCUMULATION_LEVEL=null \
      METRIC_ACCUMULATION_LEVEL=SAMPLE \
      METRIC_ACCUMULATION_LEVEL=LIBRARY \
      OUTPUT=${metrics_filename}
  }

  runtime {
    docker: "us.gcr.io/broad-gotc-prod/genomes-in-the-cloud:2.4.1-1540490856"
    preemptible: preemptible_tries
    memory: "${mem_size} GB"
    disks: "local-disk " + disk_size + " HDD"
  }

  output {
    File metrics = "${metrics_filename}"
  } 

}
