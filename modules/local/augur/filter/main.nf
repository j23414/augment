process AUGUR_FILTER {
    tag "${fasta.baseName}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'oras://community.wave.seqera.io/library/pip_nextstrain-augur:9cbcad73b0d6c116'
        : 'community.wave.seqera.io/library/pip_nextstrain-augur:3a4986111477eddc'}"

    input:
    path(fasta)
    path(metadata)

    output:
    path("${fasta.baseName}_filtered.fasta"), emit: fasta
    path("${fasta.baseName}_filtered.tsv"), emit: tsv
    
    script:
    def args = task.ext.args ?: ''
    def metadata_args = params.metadata_id_columns ?: "accession_version"
    """
    augur filter \\
        --sequences ${fasta} \\
        --metadata ${metadata} \\
        --metadata-id-columns ${metadata_args} \\
        ${args} \\
        --output-sequences ${fasta.baseName}_filtered.fasta \\
        --output-metadata ${fasta.baseName}_filtered.tsv
    """
}