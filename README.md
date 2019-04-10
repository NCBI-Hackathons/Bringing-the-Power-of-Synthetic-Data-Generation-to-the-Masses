# Bringing-the-Power-of-Synthetic-Data-Generation-to-the-Masses

4 Objectives of the workshop

In a nutshell, we're starting from a prototype my team built for ASHG (American Society of Human Genetics) 2018 as a demonstration of how to make a reproducible research study. In the original study, the authors identified risk factors for congenital heart disease using exome data from a cohort of more than 800 patients. To make this study reproducible, we needed to generate a synthetic data set, since the original data were private (we decided that it would be simpler than making the original data set sufficiently anonymous). We started from publically available 1,000 genomes exomes and spiked in mutations of interest. As part of that project, we wrote some pipelines to leverage existing tools (including NEAT from OICR iirc) for generating synthetic data, and a notebook that recapitulated the clustering analysis. We have a poster that summarizes the project [here.](./ASHG18-Reproducible-Paper-ToF-poster.pdf)

Ctreating an accurate synthetic data set of this size was a fairly painful process, and we realized there would be great value in turning our prototype into a community resource. Hence the idea of bringing to the hackathon! We propose to do all the work in Terra, our cloud-based platform (app.terra.bio, successor to firecloud.org) and can provide a billing project to support all compute costs. We propose four main workstreams, each with tangible deliverables, that could accommodate people of different backgrounds/skillsets:

1. [Data in demand](./Data-Demand): This group will search the research space to determine specifications of datasets (exomes? wgs? what coverage?) that would be useful to generate and provide as freely available resource so that people don't have to generate them from scratch every time (suitable for people with high scientific chops but low computational chops).

2. [Method optimization](./Method-Optimization): Our prototype workflows are not very efficient in terms of either cost or runtime. We have some ideas for optimizing on both fronts (potentially using Hail) so the synthetic data sets would be more convenient and less costly to generate (suitable for people with algorithm and/or pipeline development experience).

3. [Quality control](./Quality-Control): Once we generate the synthetic data, we need to make sure it matches what we expect based on method parameters. For example, if we spike in mutations we need to verify that we can pull out the expected variants. We plan to develop publicly shareable QC notebooks (but open to external contributions of course) using existing code from our internal QC group. This would also scratch a more general itch that people have around QCing genomic datasets (suitable for people with analytical and/or pipeline development experience).

4. [Diversifying Options](./Diversifying-Options): This group will explore extending synthetic data sets to include additional variant types. Our current prototype can only spike-in SNPs, but the tools we leverage can do other variant types (suitable for people with analytical and/or pipeline development experience).


