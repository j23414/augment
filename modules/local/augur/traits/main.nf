process AUGUR_TRAITS {
    tag "${meta.id}"
    label 'process_medium'

    conda params.conda_env ?: "${moduleDir}/environment.yml"
    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'oras://community.wave.seqera.io/library/pip_nextstrain-augur:9cbcad73b0d6c116'
        : 'community.wave.seqera.io/library/pip_nextstrain-augur:3a4986111477eddc'}"

    input:
    tuple val(meta), path(tree)
    path(metadata)
    val(trait_columns)
    

    output:
    path("${tree.baseName}_traits.json"), emit: node
    
    script:
    def args = task.ext.args ?: ''
    def metadata_args = params.metadata_id_columns ?: "accession_version"
    """
    augur traits \\
        --tree ${tree} \\
        --metadata ${metadata} \\
        --metadata-id-columns ${metadata_args} \\
        --columns ${trait_columns} \\
        ${args} \\
        --output-node-data ${tree.baseName}_traits.json
    """
}