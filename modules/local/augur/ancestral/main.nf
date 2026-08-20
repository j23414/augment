process AUGUR_ANCESTRAL {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'oras://community.wave.seqera.io/library/pip_nextstrain-augur:9cbcad73b0d6c116'
        : 'community.wave.seqera.io/library/pip_nextstrain-augur:3a4986111477eddc'}"

    input:
    tuple val(meta), path(tree)
    path(aln_fasta)
    path(ref_fasta)

    output:
    path("${tree.baseName}_nt-muts.json"), emit: node
    
    script:
    def args = task.ext.args ?: ''
    def alignment_args = aln_fasta ? "--alignment ${aln_fasta}" : ""
    def root_args = ref_fasta ? "--root-sequence ${ref_fasta}": ""
    """
    augur ancestral \\
    --tree ${tree} \\
    ${args} \\
    ${alignment_args} \\
    ${root_args} \\
    --output-node-data ${tree.baseName}_nt-muts.json
    """
}