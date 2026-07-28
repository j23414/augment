process AUGUR_REFINE {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    // container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
    //     ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/e9/e994bf4eb3731150511a14f5706b7bdfd64df1b6d40898fff334286c027e0859/data'
    //     : 'community.wave.seqera.io/library/htslib_samtools:1.24--d697cfb9dce007cd'}"

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