## Goals

Reduce the runtime and cost of the workflows involved in synthetic data generation.

## Proposed tasks

1. Determine which workflow(s) to prioritize.

2. Identify bottlenecks and propose streamlined approach.

3. Prototype proposed solution(s) and test for runtime and/or cost reductions.

## Original workflows

| Name | Synopsis |
|:---|:---|
| [Collect-1000G-participant](Collect-1000G-participant.md) | Collect the variants for a single participant from 1000G Phase 3 |
| [Generate-synthetic-reads](Generate-synthetic-reads.md) | Generate synthetic read data based on intervals and a VCF of variants |
| [Mutate-reads-with-BAMSurgeon](Mutate-reads-with-BAMSurgeon.md) | Introduce specific mutations into an analysis-ready BAM file with BAMSurgeon |

### Runtime and cost  

| Workflow Name                  	| Cost for 1x (range) 	| Cost for 100x 	| Time to Run 1x 	| Time to Run 100x (in parallel) 	|
|:--------------------------------	|:----------------	|:-----------	|:--------------------	|:-----------------------	|
| 1_Collect-1000G-participants     	| $1.64 to $2.90 	| $193.75   	| 4.5 hours          	| 12 hours              	|
| 2_Generate-synthetic-reads       	| $2.40 to $3.44 	| $405.67   	| 4.5 hours          	| 12 hours              	|
| 3_Mutate-reads-with-BAMSurgeon   	| $0.02 to $0.15 	| $5.72     	| .5 hours           	| 2.5 hours             	|
