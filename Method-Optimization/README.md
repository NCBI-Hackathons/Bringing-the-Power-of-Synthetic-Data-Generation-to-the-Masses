## Goals

Reduce the runtime and cost of the workflows involved in synthetic data generation.

## Proposed tasks

1. Determine which workflow(s) to prioritize.

2. Identify bottlenecks and propose streamlined approach.

3. Prototype proposed solution(s) and test for runtime and/or cost reductions.

## Original workflows

| Name | Synopsis |
|:---|:---|
| Collect1000GParticipant | Collect the variants for a single participant from 1000G Phase 3 |
| GenerateSyntheticReads | Generate synthetic read data based on intervals and a VCF of variants |
| MutateReadsWithBAMSurgeon | Introduce specific mutations into an analysis-ready BAM file with BAMSurgeon |

### Runtime and cost  

| Workflow Name                  	| Cost for 1 sample (range) 	| Cost for 100 samples (total)	| Time to run 1 sample 	| Time to run 100 samples in parallel (wallclock) 	|
|:--------------------------------	|:----------------	|:-----------	|:--------------------	|:-----------------------	|
| Collect1000GParticipant     	| $1.64 to $2.90 	| $193.75   	| 4.5 hours          	| 12 hours              	|
| GenerateSyntheticReads       	| $2.40 to $3.44 	| $405.67   	| 4.5 hours          	| 12 hours              	|
| MutateReadsWithBAMSurgeon   	| $0.02 to $0.15 	| $5.72     	| .5 hours           	| 2.5 hours             	|
