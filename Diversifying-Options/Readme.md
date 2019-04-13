This section of the repository will hold Hackathon materials related to 

Diversifying options: Extend to more variant types than single nucleotide variants.

### Workflow name: MutateReadsWithBAMSurgeon

Every workflow on Terra consists of at least 2 parts.  A [WDL(Workflow Description Language)](Mutate-reads-with-BAMSurgeon.wdl) file and a [JSON that characterizes the inputs](Mutate-reads-with-BAMSurgeon.json).  In addition, workspace attributes may have been set to facilitate the recall of reference files, dockers, etc. by multiple workflows in the same workspace. 

The current version of the workflow uses the BAMSurgeon `addsnv.py` tool to introduce specific mutations into an analysis-ready BAM file.

 BAMSurgeon is a toolkit written by Adam Ewing et al. described in the paper cited below. The source code is
 available on Github at https://github.com/adamewing/bamsurgeon

 Combining tumor genome simulation with crowdsourcing to benchmark somatic single-nucleotide-variant detection.
 Adam D Ewing, Kathleen E Houlahan, Yin Hu, Kyle Ellrott, Cristian Caloian, Takafumi N Yamaguchi, J Christopher Bare,
 Christine P'ng, Daryl Waggott, Veronica Y Sabelnykova, ICGC-TCGA DREAM Somatic Mutation Calling Challenge
 participants, Michael R Kellen, Thea C Norman, David Haussler, Stephen H Friend, Gustavo Stolovitzky, Adam A
 Margolin, Joshua M Stuart, Paul C Boutros
 Published: May 18, 2015 | https://dx.doi.org/10.1038%2Fnmeth.3407


The goal of the hackathon is to create a workflow document for other types of variants.


More details about the workflow tool can be found in the Terra workspace for the hackathon.
