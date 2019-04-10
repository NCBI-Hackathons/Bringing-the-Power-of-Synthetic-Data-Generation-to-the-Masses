# Bringing-the-Power-of-Synthetic-Data-Generation-to-the-Masses

4 Objectives of the workshop

In a nutshell, we're starting from a prototype that my team built for ASHG 2018, in which we reproduced an analysis from a preprint identifying risk factors for congenital heart disease from exome data. For the purposes of that project, we had to generate several hundred synthetic exomes and spike in mutations of interest. We wrote some pipelines to leverage existing tools (including NEAT from OICR iirc) and a notebook that recapitulated the clustering analysis. We have a poster that summarizes the project [here.](./ASHG18-Reproducible-Paper-ToF-poster.pdf)

It was a fairly painful process and we came away from it with the realization that there would be great value in turning this prototype into a community resource, hence the idea of the hackathon. We propose to do all the work in our cloud platform (app.terra.bio, successor to firecloud.org) and can provide a billing project to support all compute costs. We envisage 4 main workstreams that could accommodate people of different backgrounds/skillsets with tangible deliverables:

1. Data in demand: search the research space to determine specifications of datasets (exomes, wgs? what coverage?) that would be useful to generate and provide as freely available resource so that people don't have to generate them from scratch every time. (Suitable for people with high scientific chops but low computational chops)

2. Method optimization: our prototype workflows are not very efficient in terms of either cost or runtime. We have some ideas for optimizing on both fronts (potentially using Hail) to make these resources more convenient and less costly to generate. (Suitable for people with algorithm and/or pipeline development experience)

3. Quality control: once we generate the synthetic data, we need to QC the data to make sure it matches what we expect based on method parameters, and if we spike in mutations we need to verify that we can pull out the expected variants. We envisage using existing code from our internal QC group to develop publicly shareable QC notebooks (but open to external contributions of course). This would also scratch a more general itch that people have around QCing genomic datasets. (Suitable for people with analytical and/or pipeline development experience)

4. Extend to more variant types: our current prototype can only spike-in SNPs, but the tools we leverage can do other variant types. 


