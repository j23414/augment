// Minimal
params.newick = "tree.nwk"
params.outdir = "results"
params.conda_env = "/Users/jchang99/.nextstrain/runtimes/conda/env/"

// Add Metadata
params.metadata = false
params.metadata_id_columns = "accession"
params.metadata_annotate = "date region country host is_lab_host"

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

process EXPORT_METADATA {
    conda "${params.conda_env}"
    publishDir "${params.outdir}/export", mode: "copy"
    input: tuple path(newick), path(node_data), path(metadata), val(metadata_id_columns), val(metadata_columns)
    output: path("${newick.baseName}.json")

    script:
    """
    augur export v2 \
    --tree ${newick} \
    --node-data ${node_data} \
    --output ${newick.baseName}.json \
    --metadata ${metadata} \
    --metadata-id-columns ${metadata_id_columns} \
    --metadata-columns ${metadata_columns} \
    --color-by-metadata ${metadata_columns}
    """
}

workflow {
    main:
    ch_newick = channel.fromPath(params.newick)

    ch_newick
    | REFINE

    // Metadata exists
    if(params.metadata){
        ch_metadata = channel.fromPath(params.metadata)
        REFINE.out
        | combine(ch_metadata)
        | combine(channel.from("${params.metadata_id_columns}"))
        | combine(channel.from("${params.metadata_annotate}"))
        | EXPORT_METADATA
        | view
    } else {
        REFINE.out
        | EXPORT
        | view
    }
}