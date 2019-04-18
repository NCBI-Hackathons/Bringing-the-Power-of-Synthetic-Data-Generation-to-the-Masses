uploading scrappy code!

* full_wdl_genreads.wdl: full gen reads workflow, with the addition of the `--job` flag and wrapper code which we were analyzing for cost optimization

* merged_reads.wdl: a test for just `mergeReads` task, to see how we can join the bams and vcfs post parallelism step

* test1.wdl.json: a test for just `mergeReads` task, with hardcoded paths on successful shards to test merging of  bams and vcfs post parallelism step
