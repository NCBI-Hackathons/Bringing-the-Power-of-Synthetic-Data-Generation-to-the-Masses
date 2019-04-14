### Workflow name: JointCallAndHardFilterGATK4
##
## This workflow uses several GATK4 tools, including the GenomicsDB tooling for scalable joint calling, to apply joint
## variant discovery analysis to GVCFs produced by HaplotypeCaller and apply a simple hard filtering threshold. Note
## that this does not completely follow the official GATK Best Practices recommendations, which use VQSR for multisample
## datasets and CNN for single WGS or small exome cohorts (N<30).
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
## - List of GVCF files to joint-call and the corresponding sample names
## - List of intervals in GATK-style format
##
#### Important parameters
## - Batch size for import step (use the provided default of 50 unless you know what you're doing)
## - Filtering expression and corresponding filter name
##
#### Outputs
## - Joint-called multisample VCF with hard filtering applied, in compressed .gz format, and its .tbi index
##
#### Workflow notes
## - The workflow is designed to be run per cohort.
## - The GenomicsDB-centric import and joint calling steps are scattered across supersets of WGS intervals.
## - All sites that are present in the input VCF are retained; filtered sites are annotated as such in the FILTER field.
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

## WORKFLOW DEFINITION
workflow JointCallAndHardFilterGATK4 {

  File ref_fasta
  File ref_fasta_index
  File ref_dict

  Array[File] input_gvcfs     
  Array[File] input_gvcfs_indices
  File intervals_list

  String callset_name
  Array[String] sample_names

  String gatk_docker
  String gatk_path
  
  Int preemptible

  Array[String] intervals = read_lines(intervals_list)

  scatter (interval in intervals) {

    call ImportGVCFs {
      input:
        sample_names = sample_names,
        input_gvcfs = input_gvcfs,    
        input_gvcfs_indices = input_gvcfs_indices,
        interval = interval,
        workspace_dir_name = "genomicsdb",
        batch_size = 50,
        docker = gatk_docker,
        gatk_path = gatk_path,
        preemptible = preemptible
    }

    call GenotypeGVCFs {
      input:
        workspace_tar = ImportGVCFs.output_genomicsdb,
        interval = interval,
        output_vcf_filename = "interval_jointcalls.vcf.gz",
        ref_fasta = ref_fasta,
        ref_fasta_index = ref_fasta_index,
        ref_dict = ref_dict,
        docker = gatk_docker,
        gatk_path = gatk_path,
        preemptible = preemptible
    }
  }

  call GatherVcfs {
    input:
      input_vcfs_fofn = write_lines(GenotypeGVCFs.output_vcf),
      output_vcf_name = callset_name + ".jointcalls.vcf.gz",
      docker = gatk_docker,
      gatk_path = gatk_path,
      preemptible = preemptible
  }

  call HardFilterVariants {
    input:
      vcf = GatherVcfs.output_vcf,
      vcf_index = GatherVcfs.output_vcf_index,
      variant_filtered_vcf_filename = callset_name + ".jointcalls.filtered.vcf.gz",
      docker = gatk_docker,
      gatk_path = gatk_path,
      preemptible = preemptible
}

  output {
    File filteredJointVcf = HardFilterVariants.output_vcf
    File filteredJointVcfIndex = HardFilterVariants.output_vcf_index
  }
}

## TASK DEFINITIONS

# This task imports the content of GVCF files into a GenomicsDB workspace
task ImportGVCFs {
  Array[String] sample_names
  Array[File] input_gvcfs
  Array[File] input_gvcfs_indices
  String interval

  String workspace_dir_name

  String gatk_path
  String docker
  Int disk_size
  Int preemptible
  Int batch_size

  command <<<
    set -e
    set -o pipefail
    
    python << CODE
    gvcfs = ['${sep="','" input_gvcfs}']
    sample_names = ['${sep="','" sample_names}']

    if len(gvcfs)!= len(sample_names):
      exit(1)

    with open("inputs.list", "w") as fi:
      for i in range(len(gvcfs)):
        fi.write(sample_names[i] + "\t" + gvcfs[i] + "\n") 

    CODE

    rm -rf ${workspace_dir_name}

    # The memory setting here is very important and must be several GB lower
    # than the total memory allocated to the VM because this tool uses
    # a significant amount of non-heap memory for native libraries.
    # Also, testing has shown that the multithreaded reader initialization
    # does not scale well beyond 5 threads, so don't increase beyond that.
    ${gatk_path} --java-options "-Xmx4g -Xms4g" \
    GenomicsDBImport \
    --genomicsdb-workspace-path ${workspace_dir_name} \
    --batch-size ${batch_size} \
    -L ${interval} \
    --sample-name-map inputs.list \
    --reader-threads 5 \
    -ip 500

    tar -cf ${workspace_dir_name}.tar ${workspace_dir_name}

  >>>
  runtime {
    docker: docker
    memory: "7 GB"
    cpu: "2"
    disks: "local-disk " + disk_size + " HDD"
    preemptible: preemptible
  }
  output {
    File output_genomicsdb = "${workspace_dir_name}.tar"
  }
}

# This task applies joint calling across all samples
task GenotypeGVCFs {
  File workspace_tar
  String interval

  String output_vcf_filename

  String gatk_path

  File ref_fasta
  File ref_fasta_index
  File ref_dict

  String docker
  Int disk_size
  Int preemptible

  command <<<
    set -e

    tar -xf ${workspace_tar}
    WORKSPACE=$( basename ${workspace_tar} .tar)

    ${gatk_path} --java-options "-Xmx5g -Xms5g" GenotypeGVCFs \
      -R ${ref_fasta} \
      -O ${output_vcf_filename} \
      -G StandardAnnotation \
      --only-output-calls-starting-in-intervals \
      --use-new-qual-calculator \
      -V gendb://$WORKSPACE \
      -L ${interval}

  >>>
  runtime {
    docker: docker
    memory: "7 GB"
    cpu: "2"
    disks: "local-disk " + disk_size + " HDD"
    preemptible: preemptible
  }
  output {
    File output_vcf = "${output_vcf_filename}"
    File output_vcf_index = "${output_vcf_filename}.tbi"
  }
}

# This task gathers VCFs output by scattered jobs and merges them into one
task GatherVcfs {
  File input_vcfs_fofn
  String output_vcf_name
  String gatk_path

  String docker
  Int disk_size
  Int preemptible

  command <<<
    set -e

    # Now using NIO to localize the vcfs but the input file must have a ".list" extension
    mv ${input_vcfs_fofn} inputs.list

    # --ignore-safety-checks makes a big performance difference so we include it in our invocation.
    # This argument disables expensive checks that the file headers contain the same set of
    # genotyped samples and that files are in order by position of first record.
    ${gatk_path} --java-options "-Xmx6g -Xms6g" \
    GatherVcfsCloud \
    --ignore-safety-checks \
    --gather-type BLOCK \
    --input inputs.list \
    --output ${output_vcf_name}

    ${gatk_path} --java-options "-Xmx6g -Xms6g" \
    IndexFeatureFile \
    --feature-file ${output_vcf_name}
  >>>

  runtime {
    docker: docker
    memory: "7 GB"
    cpu: "1"
    disks: "local-disk " + disk_size + " HDD"
    preemptible: preemptible
  }

  output {
    File output_vcf = "${output_vcf_name}"
    File output_vcf_index = "${output_vcf_name}.tbi"
  }
}

# This task applies a hard filtering expression
task HardFilterVariants {
  File vcf
  File vcf_index

  String filterName
  String filterExpression

  String variant_filtered_vcf_filename
  String gatk_path

  String docker
  Int disk_size
  Int preemptible

  command {
    set -e

    ${gatk_path} --java-options "-Xmx3g -Xms3g" \
      VariantFiltration \
      --filter-expression "${filterExpression}" \
      --filter-name ${filterName} \
      -O ${variant_filtered_vcf_filename} \
      -V ${vcf}
  }

  runtime {
    docker: docker
    memory: "3.5 GB"
    cpu: "1"
    disks: "local-disk " + disk_size + " HDD"
    preemptible: preemptible
  }

  output {
    File output_vcf = "${variant_filtered_vcf_filename}"
    File output_vcf_index = "${variant_filtered_vcf_filename}.tbi"
  }
}