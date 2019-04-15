## Goals

Prototype methods to validate that the synthetic datasets we produce are appropriate for reproducing the target analyses.

## Proposed tasks

See the README about the workflows in the `workflows` directory for background details on the relevant original workflows.

1. Determine what QC metrics we care about (eg coverage, theoretical het sensitivity etc) and how we can collect them.

2. Develop tooling (workflow and/or notebook) to collect metrics and plot them for a single sample (to get the technical properties of our synthetic data).

3. (stretch) Extend tooling to compare relevant metrics (eg error rates?) between the synthetic data and the real data we are trying to emulate.

4. (stretch) Develop approach to verify that the expected mutations were introduced with the spike-in workflow.

5. (stretch) Develop approach to validate that a synthetic dataset is appropriate for reproducing a given analysis.

## Food for thought

### Metrics collection 

The Picard toolkit (available in GATK since version 4.0) contains a variety of useful quality control metrics definitions and corresponding collection tools -- for example, [CollectWgsMetrics](https://software.broadinstitute.org/gatk/documentation/tooldocs/current/picard_analysis_CollectWgsMetrics.php). They produce metrics reports that can then be used for plotting or analyzing the resulting metrics. 

The metrics collection tools can either be integrated into data processing workflows, as is done in the Broad's production implementation of the GATK Best Practices for germline variant discovery (aka the $5 Genome Pipeline) or they can be used in simple standalone workflows. For this project it will be most convenient to put them in standalone workflows so we can run them separately from the synthetic data processing, but down the road we would probably want to run them as part of the data generation process. Note that we could also run these tools directly from within a notebook if we add a GATK-enabling startup script on the notebook runtime (TODO: add link to instructions in Terra docs). That would allow us to iterate rapidly on the command line, though we'd have to run on some snippet data for test runs to finish quickly enough.

Here's a set of WDL tasks that are used in the production pipeline for collecting QC metrics: 
https://github.com/gatk-workflows/five-dollar-genome-analysis-pipeline/blob/master/tasks/Qc.wdl

And here's the Terra workspace that showcases that pipeline (which contains output metrics files): 
https://app.terra.bio/#workspaces/help-gatk/five-dollar-genome-analysis-pipeline

