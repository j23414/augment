params.newick = "tree.nwk"
params.outdir = "results"
params.conda_env = "/Users/jchang99/.nextstrain/runtimes/conda/env/"

process REFINE {
    conda "${params.conda_env}"
    publishDir "${params.outdir}/refine", mode: "copy"
    input: path(newick)
    output: tuple path("${newick.baseName}_refined.nwk"), path("${newick.baseName}_branch_length.json")

    script:
    """
    augur refine \
    --tree ${newick} \
    --output-tree ${newick.baseName}_refined.nwk \
    --output-node-data ${newick.baseName}_branch_length.json \
    --keep-root
    """
}

process EXPORT {
    conda "${params.conda_env}"
    publishDir "${params.outdir}/export", mode: "copy"
    input: tuple path(newick), path(node_data)
    output: path("${newick.baseName}.json")

    script:
    """
    augur export v2 \
    --tree ${newick} \
    --node-data ${node_data} \
    --output ${newick.baseName}.json
    """
}

workflow {
    main:
    ch_newick = channel.fromPath(params.newick)

    ch_newick
    | REFINE
    | EXPORT
    | view
}