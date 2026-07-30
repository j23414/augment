process AUGUR_EXPORT {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    // container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
    //     ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/e9/e994bf4eb3731150511a14f5706b7bdfd64df1b6d40898fff334286c027e0859/data'
    //     : 'community.wave.seqera.io/library/htslib_samtools:1.24--d697cfb9dce007cd'}"

    input:
    tuple val(meta), path(tree)
    path(node_data)
    path(tsv)
    path(colors_tsv)
    path(nt_data)
    path(aa_data)
    path(auspice_config_json)
    path(description_md)
    path(lat_longs_tsv)

    output:
    tuple val(meta), path("${tree.baseName}.json"), emit: auspice
    
    script:
    def args = task.ext.args ?: ''
    def metadata_aux = params.metadata_annotate ? "--metadata-columns ${params.metadata_annotate} --color-by-metadata ${params.metadata_annotate}" : ""
    def metadata_args = tsv ? "--metadata ${tsv} --metadata-id-columns ${params.metadata_id_columns} ${metadata_aux}" : ""
    def colors_args = colors_tsv ? "--colors ${colors_tsv}" : ""
    def auspice_config_args = auspice_config_json ? "--auspice-config ${auspice_config_json}" : ""
    def description_args = description_md ? "--description ${description_md}" : ""
    def lat_longs_args = lat_longs_tsv ? "--lat-longs ${lat_longs_tsv}" : ""
    """
    augur export v2 \\
        --tree ${tree} \\
        --node-data ${node_data} ${nt_data} ${aa_data} \\
        ${args} \\
        ${metadata_args} \\
        ${colors_args} \\
        ${auspice_config_args} \\
        ${description_args} \\
        ${lat_longs_args} \\
        --output ${tree.baseName}.json
    """
}