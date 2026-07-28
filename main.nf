include { AUGUR_REFINE } from './modules/local/augur/refine/main'
include { AUGUR_ANCESTRAL } from './modules/local/augur/ancestral/main'
include { AUGUR_TRANSLATE } from './modules/local/augur/translate/main'
include { AUGUR_EXPORT } from './modules/local/augur/export/main'

process EXPORT_METADATA_COLORS {
    //conda "${params.conda_env}"
    publishDir "${params.outdir}/export", mode: "copy"
    input: 
    path(metadata)
    path(color_orders)
    path(colors_tsv)

    output:
    path("final-colors.tsv")

    script:
    def colors_args = colors_tsv ?: ""
    """
    python ${projectDir}/bin/assign-colors.py \\
    --color-schemes ${projectDir}/assets/color_schemes.tsv \\
    --ordering ${color_orders} \\
    --metadata ${metadata} \\
    --output temp-colors.tsv

    cat ${colors_args} temp-colors.tsv > final-colors.tsv
    """
}

workflow {
    main:
    ch_newick = channel.fromPath(params.newick, checkIfExists: true)
    | map { tree -> tuple([id: tree.baseName], tree)}

    ch_metadata = params.metadata ? channel.fromPath(params.metadata, checkIfExists: true) : []
    ch_alignment = params.alignment ? channel.fromPath(params.alignment, checkIfExists: true) : []
    
    ch_set_colors = params.metadata_set_colors ? channel.fromPath(params.metadata_set_colors, checkIfExists: true) : []
    

    AUGUR_REFINE(
        ch_newick,
        ch_metadata,
        ch_alignment
    )

    if ( params.reference_fasta && params.reference_gb ) {
        ch_reference_fasta = channel.fromPath(params.reference_fasta, checkIfExists: true)
        ch_reference_gb = channel.fromPath(params.reference_gb, checkIfExists: true)

        AUGUR_ANCESTRAL(
            AUGUR_REFINE.out.tree,
            ch_alignment,
            ch_reference_fasta
        )

        AUGUR_TRANSLATE(
            AUGUR_REFINE.out.tree,
            AUGUR_ANCESTRAL.out.node,
            ch_reference_gb
        )
        ch_nt = AUGUR_ANCESTRAL.out.node
        ch_aa = AUGUR_TRANSLATE.out.node
    } else {
        ch_nt = []
        ch_aa = []
    }

    if(params.metadata_color_order) {
        ch_color_order = channel.fromPath(params.metadata_color_order, checkIfExists: true)
        EXPORT_METADATA_COLORS(
            ch_metadata,
            ch_color_order,
            ch_set_colors
        )
        ch_colors = EXPORT_METADATA_COLORS.out
    } else {
        ch_colors = []
    }

    AUGUR_EXPORT(
        AUGUR_REFINE.out.tree,
        AUGUR_REFINE.out.node,
        ch_metadata,
        ch_colors,
        ch_nt,
        ch_aa
    )

}
