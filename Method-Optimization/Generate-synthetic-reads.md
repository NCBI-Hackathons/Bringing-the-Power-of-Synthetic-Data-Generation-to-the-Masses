## Workflow name: GenerateSyntheticReads

 This workflow uses the NEAT toolkit to generate synthetic paired-end read data based on a file of input variants
 and a desired mutation rate (can be 0 to not include any random mutation in addition to the input variants).
 It creates an analysis-ready BAM file and a "ground truth" VCF.

 NEAT is a toolkit written by Zachary Stephens et al. described in the paper cited below. The source code is
 available on Github at https://github.com/zstephens/neat-genreads

 Simulating Next-Generation Sequencing Datasets from Empirical Mutation and Sequencing Models
 Zachary D. Stephens , Matthew E. Hudson, Liudmila S. Mainzer, Morgan Taschuk, Matthew R. Weber, Ravishankar K. Iyer
 Published: November 28, 2016 | https://doi.org/10.1371/journal.pone.0167047

### Main inputs
 - Participant ID or equivalent base name for naming outputs
 - VCF of variant calls to spike into the synthetic reads
 - List of scatter intervals list in BED format
 - Reference genome, index and dictionary

### Important parameters
 - Mutation rate (between 0 and 0.3)
 - Average coverage
 - Read length to generate
 - Fragment length (mean and standard deviation)
 - Data type (for naming output files)

### Outputs
 - Aligned BAM file and its index (generated separately by Picard after cleanup and adding readgroups)
 - Ground truth VCF (sites only, no real genotypes except for WP annotation)

### Workflow notes
 - The workflow is designed to be run per participant.
 - The synthetic data generation is scattered across lists of intervals.
 - A preprocessing task removes complex variant records that would break other tasks.
 - Accessory tasks apply fixes for read names and VCF header issues.
 - Artificial read groups are added after merging.

### Runtime notes
 - Cromwell version support: successfully tested on v34
 - Runtime parameters are optimized for Broad's Google Cloud Platform implementation.
 - For program versions, see docker containers.

More details about the workflow tool can be found in the Terra workspace for the hackathon.
