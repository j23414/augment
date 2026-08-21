process AUGUR_TREE {
    tag "${alignment.baseName}"
    label 'process_medium'

    conda params.conda_env ?: "${moduleDir}/environment.yml"
    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'oras://community.wave.seqera.io/library/pip_nextstrain-augur:9cbcad73b0d6c116'
        : 'community.wave.seqera.io/library/pip_nextstrain-augur:3a4986111477eddc'}"

    input:
    path(alignment)

    output:
    path("${alignment.baseName}.tre"), emit: tree
    
    script:
    def args = task.ext.args ?: ''
    """
    augur tree \\
        --alignment ${alignment} \\
        ${args} \\
        --output ${alignment.baseName}.tre
    """
}