## Workflow name: CallSingleSampleGvcfGATK4

 This workflow uses GATK4 HaplotypeCaller to call variants per-sample and produce a GVCF file, which is an
 intermediate in the GATK joint calling workflow for germline short variants. The HaplotypeCaller's execution is
 scattered over sets of intervals, and followed by a merging step to produce a single file.

 GATK is a genomics toolkit mainly focused on variant discovery developed at the Broad Institute. For documentation
 and support, see https://software.broadinstitute.org/gatk. To cite the joint calling methodology, see the preprint
 cited below. The source code is available on Github at https://github.com/broadinstitute/gatk

 Scaling accurate genetic variant discovery to tens of thousands of samples
 Ryan Poplin, Valentin Ruano-Rubio, Mark A. DePristo, Tim J. Fennell, Mauricio O. Carneiro, Geraldine A. Van der
 Auwera, David E. Kling, Laura D. Gauthier, Ami Levy-Moonshine, David Roazen, Khalid Shakir, Joel Thibault, Sheila
 Chandran, Chris Whelan, Monkol Lek, Stacey Gabriel, Mark J. Daly, Benjamin Neale, Daniel G. MacArthur, Eric Banks
 Preprint posted: November 14, 2017 | https://doi.org/10.1101/201178

### Main inputs
 - Reference genome, index and dictionary
 - Input BAM file for a single sample as identified in the RG:SM tag
 - List of lists of intervals to scatter across (any GATK-supported format)

 Important parameters
 - For exomes, interval padding is crucial for calling variants on the outskirts of targets.

### Outputs
 - One GVCF file in compressed .gz format and its .tbi index

### Workflow notes
 - The workflow is designed to be run per sample (as identified in RG:SM).
 - The scatter across lists of intervals should be as balanced as possible to avoid wallclock bottlenecks.

### Runtime notes
 - Cromwell version support: successfully tested on v34
 - Runtime parameters are optimized for Broad's Google Cloud Platform implementation.
 - For program versions, see docker containers.

More details about the workflow tool can be found in the Terra workspace for the hackathon.
