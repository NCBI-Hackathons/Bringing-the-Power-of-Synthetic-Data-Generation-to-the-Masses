This workspace is for the Method Optimization portion of the Hackathon

The WDL and JSON for this section can be found here: https://github.com/terra-workflows/tetralogy-of-fallot

There are 6 steps in the process:

| Name | Entity Type| Synopsis |
|---|---|---|
| [Collect-1000G-participant](Collect-1000G-participant.md) | participant | Collect the variants for a single participant from 1000G Phase 3 |
| [Generate-synthetic-reads](Generate-synthetic-reads.md) | participant | Generate synthetic read data based on intervals and a VCF of variants |
| Mutate-reads-with-BAMSurgeon | participant | Introduce specific mutations into an analysis-ready BAM file with BAMSurgeon |
| Call-single-sample-GVCF-GATK4 | participant | Call variants per-sample and produce a GVCF file with GATK4 HaplotypeCaller |
| Joint-call-and-hard-filter-GATK4 | participant_set | Apply joint variant discovery analysis and hard filtering |
| Predict-variant-effects-GEMINI | participant_set | Predict and annotate the functional effects of variants using SnpEff and GEMINI

