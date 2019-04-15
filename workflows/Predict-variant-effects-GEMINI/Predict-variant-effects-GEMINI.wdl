### Workflow name: PredictVariantEffectsGEMINI
##
## This workflow annotates functional predictions using SnpEff and GEMINI after normalizing the variant representations
## using vt.
##
## **vt** is a toolkit for manipulating variants written by Adrian Tan et al. that is best known for its normalization
## capabilities, as described in the paper cited below. The source code is available on Github at
## http://github.com/atks/vt
##
## - Unified representation of genetic variants
## Adrian Tan, Gonçalo R. Abecasis, Hyun Min Kang
## Published: July 1, 2015 | https://doi.org/10.1093/bioinformatics/btv112
##
## **SnpEff** is a variant annotation and effect prediction tool written by Pablo Cingolani et al. that predicts the
## functional impact of variants on genes (such as amino acid changes), as described in the paper cited below. The
## source code is available at http://snpeff.sourceforge.net
##
## - A program for annotating and predicting the effects of single nucleotide polymorphisms, SnpEff: SNPs in the
## genome of Drosophila melanogaster strain w1118; iso-2; iso-3.
## Cingolani P, Platts A, Wang le L, Coon M, Nguyen T, Wang L, Land SJ, Lu X, Ruden DM. Fly
## https://doi.org/10.4161/fly.19695
##
## **GEMINI** is a toolkit written by Aaron Quinlan et al. that enables exploration of genetic variation for disease
## and population genetics via SQL, as described in the paper cited below. The source code is available on GitHub at
## https://github.com/arq5x/gemini
##
## - GEMINI: Integrative Exploration of Genetic Variation and Genome Annotations
## Paila U, Chapman BA, Kirchner R, Quinlan AR
## https://doi.org/10.1371/journal.pcbi.1003153
##
#### Main inputs
## - One multisample VCF file to annotate
## - A PED file describing the case and control samples
## - Tar file of annotation resources used by Gemini
## - Reference genome (FASTA only) and name of the reference as it appears in the Gemini resources
## - A SnpEff jar executable and configuration file
##
#### Important parameters
## - The query to apply to the Gemini database
##
#### Outputs
## - A VCF file annotated by SnpEff
## - A queryable Gemini database
## - A text file containing the result of the Gemini query
##
#### Workflow notes
## - The workflow is designed to be run per cohort.
## - Several pre-processing tasks are used to address minor incompatibilities that would break further analysis.
## - This version of the workflow does note scale well above a few hundred samples (tests ok with 100, but unreasonably slow with 500)
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
workflow PredictVariantEffectsGEMINI {
    File inputVCF
    File configFile

    String databaseName
    String basename = basename("${inputVCF}", ".vcf.gz")

	File snpEff_jar
    String gemini_docker

    call vtNormalize {
        input:
            inputVCF = inputVCF,
            outputName = basename + ".normalized.vcf",
            docker_image = gemini_docker
    }

    call SnpEffAnnotation  {
        input:
            snpEff_jar = snpEff_jar,
            inputVCF = vtNormalize.normalizedVcf,
            configFile = configFile,
            databaseName = databaseName,
            outputName = basename + ".snpEff.vcf",
            docker_image = gemini_docker
    }

    call GeminiCreateDatabase {
        input:
            inputFile = SnpEffAnnotation.snpeff_vcf,
            databaseName = basename + ".db",
            docker_image = gemini_docker
    }

    call GeminiQueryDatabase{
        input:
            database = GeminiCreateDatabase.gemini_database,
            outputName = basename + ".gemini-predictions.txt",
            docker_image = gemini_docker
    }

    output {
        File snpEff_vcf_output = SnpEffAnnotation.snpeff_vcf
        File gemini_vcf_database = GeminiCreateDatabase.gemini_database
        File gemini_query_output = GeminiQueryDatabase.case_variants
    }
}

# TASK DEFINITIONS

# This task applies vt normalize and vt decompose to adjust variant representations
task vtNormalize {

    # Command parameters
    File inputVCF
    File ref_fasta

    String outputName

    # Runtime parameters
    String docker_image
    Int machine_mem_gb
    Int disk_space_gb
    Int preemptible_tries

    command <<<

        set -e

        zless ${inputVCF} \
            | sed '1,100s/ID=AD,Number=./ID=AD,Number=R/' \
            | vt decompose -s - \
            | vt normalize -r ${ref_fasta} - > ${outputName}
    >>>

    output {
        File normalizedVcf = "${outputName}"
    }

    runtime {
        preemptible: preemptible_tries
        docker: docker_image
        memory: machine_mem_gb + " GB"
        disks: "local-disk " + disk_space_gb + " HDD"
    }
}

# This task applies SnpEff functional annotation
task SnpEffAnnotation {

    # Command parameters
    File inputVCF
    File configFile

    String outputName
    String databaseName

    # Runtime parameters
    File snpEff_jar
    String docker_image
    Int machine_mem_gb
    Int disk_space_gb
    Int preemptible_tries

    command {
        set -e

        awk '$5 !~/\*/' ${inputVCF} > removed_asterisk.vcf

        java -Xmx3g -jar ${snpEff_jar} -classic -v -config ${configFile} -canon -download ${databaseName} removed_asterisk.vcf > ${outputName}
        bgzip ${outputName}
    }

    output {
        File snpeff_vcf = "${outputName}.gz"
    }

    runtime {
        preemptible: preemptible_tries
        docker: docker_image
        memory: machine_mem_gb + " GB"
        disks: "local-disk " + disk_space_gb + " HDD"
    }
}

# This task creates the Gemini database
task GeminiCreateDatabase {

    # Command parameters
    File inputFile
    File resourcesTarFiles
    File ped

    String databaseName

    # Runtime parameters
    String docker_image
    Int machine_mem_gb
    Int disk_space_gb
    Int preemptible_tries

    command {
        set -e

        mkdir -p /usr/local/share/gemini/gemini_data
        tar -xzf ${resourcesTarFiles} -C /usr/local/share/gemini/gemini_data/
        rm ${resourcesTarFiles}

        tabix -p vcf ${inputFile}
        gemini load --cores 3 -p ${ped} -t snpEff -v ${inputFile} ${databaseName}
    }

    output {
        File gemini_database = "${databaseName}"
    }

    runtime {
        preemptible: preemptible_tries
        docker: docker_image
        memory: machine_mem_gb + " GB"
        disks: "local-disk " + disk_space_gb + " HDD"
        bootDiskSizeGb: 70
    }
}

# This task queries the Gemini database
task GeminiQueryDatabase {

    # Command parameters
    File database

    String outputName
    String gemini_query

    # Runtime parameters
    String docker_image
    Int machine_mem_gb
    Int disk_space_gb
    Int preemptible_tries

    command {
        set -e

        gemini query --header \
            --sample-filter "phenotype==2" \
            --show-samples \
            --in only \
            -q "${gemini_query}" \
            ${database} > ${outputName}
    }

    output {
        File case_variants = "${outputName}"
    }

    runtime {
        preemptible: preemptible_tries
        docker: docker_image
        memory: machine_mem_gb + " GB"
        disks: "local-disk " + disk_space_gb + " HDD"
    }
}
