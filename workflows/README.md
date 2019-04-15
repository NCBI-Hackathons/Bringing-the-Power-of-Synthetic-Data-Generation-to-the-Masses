## Overview of workflows: syntax and execution 

We use workflows written in [WDL](http://www.openwdl.org/), a Workflow Description Language with a human-readable and -writeable syntax. WDL makes it straightforward to define analysis tasks, chain them together in workflows, and parallelize their execution. The language makes common patterns simple to express, while also admitting uncommon or complicated behavior; and strives to achieve portability not only across execution platforms, but also different types of users. WDL is designed to be accessible and understandable to a wide range of users without requiring sophisticated programming knowledge.

The workflow files are recognizable by their '.wdl' extension. They are typically accompanied by one or more '.json' files that contain input file paths and parameters in JSON format. 

WDL workflows can be executed using the Cromwell workflow management system, which can be run on a variety of local, HPC and cloud platforms as described [here](https://cromwell.readthedocs.io/en/stable/). 

### Execution on Terra

For the purposes of the hackathon, we will run our workflows on [Terra](https://terra.bio/), an open cloud-based platform for genomic analysis operated by the Data Sciences Platform at the Broad Institute. Terra includes a Cromwell server and a user-friendly interface for managing and running WDL workflows. 

See the workspace description and link in the main project README doc. 

Note that we are using [workspace attributes](workspace_attributes.txt) to facilitate the use of reference files, dockers, etc. by multiple workflows in the same workspace.

## Original prototype workflows

This section lists the WDL workflow files and the corresponding workflow name as used in the original [Tetralogy of Fallot paper reproduction project](https://app.terra.bio/#workspaces/workshop-ashg18/ASHG18-ToF-Reproducible-Paper). 

### Synthetic data generation

These are the workflows that we originally used to generate synthetic read data, and which are the main focus of this hackathon project.

#### Collect1000GParticipant | Collect-1000G-participants.wdl
This workflow collects the variants for a single participant from the master 1000 Genomes Projects Phase 3 data stored as separate per-chromosome VCFs in GCS by Google Genomics (as mirror of the EBI site) and consolidates them over all chromosomes.

#### GenerateSyntheticReads | Generate-synthetic-reads.wdl 
This workflow uses the NEAT toolkit to generate synthetic paired-end read data based on a file of input variants and a desired mutation rate (can be 0 to not include any random mutation in addition to the input variants). It creates an analysis-ready BAM file and a "ground truth" VCF.

#### MutateReadsWithBAMSurgeon | Mutate-reads-with-BAMSurgeon.wdl
This workflow uses the BAMSurgeon `addsnv.py` tool to introduce specific mutations into an analysis-ready BAM file.

### Data analysis from ToF project

These are the workflows we used to reproduce the Tetralogy of Fallot analysis proper. We include them here in case we want to run some evaluations of how synthetic dataset properties affect analysis results, but we don't expect to make any modifications to these workflows.

#### CallSingleSampleGvcfGATK4 | Call-single-sample-GVCF-GATK4.wdl
This workflow uses GATK4 HaplotypeCaller to call variants per-sample and produce a GVCF file, which is an intermediate in the GATK joint calling workflow for germline short variants. The HaplotypeCaller's execution is scattered over sets of intervals, and followed by a merging step to produce a single file.

#### JointCallAndHardFilterGATK4 | Joint-call-and-hard-filter-GATK4.wdl
This workflow uses several GATK4 tools, including the GenomicsDB tooling for scalable joint calling, to apply joint variant discovery analysis to GVCFs produced by HaplotypeCaller and apply a simple hard filtering threshold. Note that this does not completely follow the official GATK Best Practices recommendations, which use VQSR for multisample datasets and CNN for single WGS or small exome cohorts (N<30).

#### PredictVariantEffectsGEMINI | Predict-variant-effects-GEMINI.wdl
This workflow annotates functional predictions using SnpEff and GEMINI after normalizing the variant representations using vt, a toolkit for manipulating variants that is best known for its normalization capabilities.


## Additional workflows

This section will list any new workflows developed as part of the hackathon.

### Wanted

- Quality control (see QC objective section for details)

