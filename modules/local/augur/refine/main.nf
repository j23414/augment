process AUGUR_REFINE {
    tag "${meta.id}"
    label 'process_medium'

    conda params.conda_env ?: "${moduleDir}/environment.yml"
    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'oras://community.wave.seqera.io/library/pip_nextstrain-augur:9cbcad73b0d6c116'
        : 'community.wave.seqera.io/library/pip_nextstrain-augur:3a4986111477eddc'}"

    input:
    tuple val(meta), path(tree)
    path(tsv)
    path(fasta)

    output:
    tuple val(meta), path("${tree.baseName}_refined.tre"), emit: tree
    path("${tree.baseName}_branch_length.json"), emit: node
    
    script:
    def args = task.ext.args ?: ''
    def metadata_args = tsv ? "--metadata ${tsv} --metadata-id-columns ${params.metadata_id_columns}" : ""
    def alignment_args = fasta ? "--alignment ${fasta}" : ""
    """
    augur refine \\
      --tree ${tree} \\
      ${metadata_args} \\
      ${alignment_args} \\
      ${args} \\
      --output-tree ${tree.baseName}_refined.tre \\
      --output-node-data ${tree.baseName}_branch_length.json
    """
}