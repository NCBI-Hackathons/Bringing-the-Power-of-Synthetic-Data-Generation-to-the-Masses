## Goals

Prototype methods to validate that the synthetic datasets we produce are appropriate for reproducing the target analyses.

## Proposed tasks

See the README about the workflows in the `workflows` directory for background details on the relevant original workflows.

1. Determine what QC metrics we care about (eg coverage, theoretical het sensitivity etc) and how we can collect them.

2. Develop tooling (workflow and/or notebook) to collect metrics and plot them for a single sample (to get the technical properties of our synthetic data).

3. (stretch) Extend tooling to compare relevant metrics (eg error rates?) between the synthetic data and the real data we are trying to emulate.

4. (stretch) Develop approach to verify that the expected mutations were introduced with the spike-in workflow.

5. (stretch) Develop approach to validate that a synthetic dataset is appropriate for reproducing a given analysis.
