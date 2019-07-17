### Workflow name: MutateReadsWithBAMSurgeon

 This workflow uses the BAMSurgeon `addsnv.py` tool to introduce specific mutations into an analysis-ready BAM file.

 BAMSurgeon is a toolkit written by Adam Ewing et al. described in the paper cited below. The source code is
 available on Github at https://github.com/adamewing/bamsurgeon

 Combining tumor genome simulation with crowdsourcing to benchmark somatic single-nucleotide-variant detection.
 Adam D Ewing, Kathleen E Houlahan, Yin Hu, Kyle Ellrott, Cristian Caloian, Takafumi N Yamaguchi, J Christopher Bare,
 Christine P'ng, Daryl Waggott, Veronica Y Sabelnykova, ICGC-TCGA DREAM Somatic Mutation Calling Challenge
 participants, Michael R Kellen, Thea C Norman, David Haussler, Stephen H Friend, Gustavo Stolovitzky, Adam A
 Margolin, Joshua M Stuart, Paul C Boutros
 Published: May 18, 2015 | https://dx.doi.org/10.1038%2Fnmeth.3407

### Main inputs
 - One BAM file to mutate
 - One file of input snp variants as described in the BAMSurgeon manual, with desired allele frequency for each
 - One file of input indel variants as described in the BAMSurgeon manual, with desired allele frequency for each
 - Reference genome, index and dictionary, plus BWA indices

 Important parameters
 - None by default; BAMSurgeon parameters can be added using the optional `snp_extra_params` or `indel_extra_params` arguments.

### Outputs
 - New BAM file with mutated reads with the desired allele(s) at the specified allele frequency

### Workflow notes
 - The workflow is designed to be run per participant.
 - This workflow was designed for a use case where only one variant is added so there is no scatter.
 - A postprocessing task sorts and indexes the output BAM file as BAMSurgeon sometimes introduces sorting errors.

### Runtime notes
 - Cromwell version support: successfully tested on v34
 - Runtime parameters are optimized for Broad's Google Cloud Platform implementation.
 - For program versions, see docker containers.

More details about the workflow tool can be found in the Terra workspace for the hackathon.
