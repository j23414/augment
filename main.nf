// Minimal
params.newick = "tree.nwk"
params.outdir = "results"
params.conda_env = "/Users/jchang99/.nextstrain/runtimes/conda/env/"

// Add Metadata
params.metadata = false
params.metadata_id_columns = "accession"
params.metadata_annotate = "date region country host is_lab_host"

// Enable adding georesolution
params.export_params = "" // "--geo-resolutions country"

// Add gene annotations
params.alignment = false
params.reference_gb = false
params.reference_fasta = false

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

process ANCESTRAL {
    conda "${params.conda_env}"
    publishDir "${params.outdir}/ancestral", mode: "copy"
    input: tuple path(newick), path(alignment), path(reference_fasta)
    output: path("${newick.baseName}_nt-muts.json")

    script:
    """
    augur ancestral \
    --tree ${newick} \
    --alignment ${alignment} \
    --root-sequence ${reference_fasta} \
    --output-node-data ${newick.baseName}_nt-muts.json
    """
}

process TRANSLATE {
    conda "${params.conda_env}"
    publishDir "${params.outdir}/translate", mode: "copy"
    input: tuple path(newick), path(nt_muts_json), path(reference_gb)
    output: path("${newick.baseName}_aa-muts.json")

    script:
    """
    augur translate \
    --tree ${newick} \
    --ancestral-sequences ${nt_muts_json} \
    --reference-sequence ${reference_gb} \
    --output-node-data ${newick.baseName}_aa-muts.json
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
    input: tuple path(newick), path(node_data), path(metadata), val(metadata_id_columns), val(metadata_columns), val(export_params)
    output: path("${newick.baseName}.json")

    script:
    """
    augur export v2 \
    --tree ${newick} \
    --node-data ${node_data} \
    --output ${newick.baseName}.json \
    ${export_params} \
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

    ch_tree = REFINE.out.map{ it[0] }

    if(params.alignment && params.reference_gb && params.reference_fasta){
        ch_alignment = channel.fromPath(params.alignment)
        ch_reference_fasta = channel.fromPath(params.reference_fasta)
        ch_reference_gb = channel.fromPath(params.reference_gb)

        ch_tree 
        | combine(ch_alignment)
        | combine(ch_reference_fasta)
        | ANCESTRAL

        ch_tree
        | combine(ANCESTRAL.out)
        | combine(ch_reference_gb)
        | TRANSLATE

        ch_node_data = REFINE.out.map{ it[1] }
        | combine(ANCESTRAL.out)
        | combine(TRANSLATE.out)
        | map{n -> [n]}
    } else {
        ch_node_data = REFINE.out.map{ it[1] }
    }

    // ch_tree
    // | combine(ch_node_data)
    // | view

    // Metadata exists
    if(params.metadata){
        ch_metadata = channel.fromPath(params.metadata)

        ch_tree
        | combine(ch_node_data)
        | combine(ch_metadata)
        | combine(channel.from("${params.metadata_id_columns}"))
        | combine(channel.from("${params.metadata_annotate}"))
        | combine(channel.from("${params.export_params}"))
        | EXPORT_METADATA
        | view
    } else {
        ch_tree
        | combine(ch_node_data)
        | EXPORT
        | view
    }
}
