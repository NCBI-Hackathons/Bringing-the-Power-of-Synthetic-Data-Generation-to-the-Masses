## Workflow name: Collect1000GParticipant

 This workflow collects the variants for a single participant from the master 1000 Genomes Projects Phase 3 data 
 stored as separate per-chromosome VCFs in GCS by Google Genomics (as mirror of the EBI site) and consolidates them 
 over all chromosomes.

### Main inputs
 - Valid participant ID from the 1000 Genomes Project
 - Google bucket path to the Google Genomics mirror of the 1000G Phase 3 data
 - List of chromosomes to process (1 through 22 ; X is processed separately)

### Outputs
 - Single VCF callset of variants for the participant and its index

### Workflow notes
 - The workflow is designed to be run per 1000G Project participant.
 - The extraction of each participant set of variants and genotypes is scattered across the separate chromosome files.
 - The main collection task includes a fix for the original data's incomplete headers and a sorting step.
 - Due to different base filenames, chromosome X is processed separately, and chromosome Y is currently left out.

### Runtime notes
 - Cromwell version support: successfully tested on v34
 - Runtime parameters are optimized for Broad's Google Cloud Platform implementation.
 - For program versions, see docker containers.


More details about the workflow tool can be found in the Terra workspace for the hackathon.
