This workspace is for the Method Optimization portion of the Hackathon

The WDL and JSON for this section can be found here: https://github.com/terra-workflows/tetralogy-of-fallot

## Current Workflow

| Name | Entity Type| Synopsis |
|---|---|---|
| [Collect-1000G-participant](Collect-1000G-participant.md) | participant | Collect the variants for a single participant from 1000G Phase 3 |
| [Generate-synthetic-reads](Generate-synthetic-reads.md) | participant | Generate synthetic read data based on intervals and a VCF of variants |
| [Mutate-reads-with-BAMSurgeon](Mutate-reads-with-BAMSurgeon.md) | participant | Introduce specific mutations into an analysis-ready BAM file with BAMSurgeon |
| [Call-single-sample-GVCF-GATK4](Call-single-sample-GVCF-GATK4.md) | participant | Call variants per-sample and produce a GVCF file with GATK4 HaplotypeCaller |
| Joint-call-and-hard-filter-GATK4 | participant_set | Apply joint variant discovery analysis and hard filtering |
| Predict-variant-effects-GEMINI | participant_set | Predict and annotate the functional effects of variants using SnpEff and GEMINI

## Time and Cost

| Workflow Name                  	| 1 file (range) 	| 100 files 	| Time to Run 1 file 	| Time to Run 100 files 	|
|--------------------------------	|----------------	|-----------	|--------------------	|-----------------------	|
| 1_Collect-1000G-participants     	| $1.64 to $2.90 	| $193.75   	| 4.5 hours          	| 12 hours              	|
| 2_Generate-synthetic-reads       	| $2.40 to $3.44 	| $405.67   	| 4.5 hours          	| 12 hours              	|
| 3_Mutate-reads-with-BAMSurgeon   	| $0.02 to $0.15 	| $5.72     	| .5 hours           	| 2.5 hours             	|
| 4_Call-single-sample-GVCF-GATK4  	| $0.32 to $0.52 	| $39.82    	| 1.75 hours         	| 2.75 hours            	|
| 5_Joint-call-and-hard-filter     	|                	| $10.09    	|                    	| 4 hours               	|
| 6_Predict-variant-effects-GEMINI 	|                	| $1.00     	|                    	| 4 minutes             	|

The goal of this objective in the Hackathon is to brainstorm ways to reduce the time and costs of the entire workflow.
