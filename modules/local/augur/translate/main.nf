process AUGUR_TRANSLATE {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    // container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
    //     ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/e9/e994bf4eb3731150511a14f5706b7bdfd64df1b6d40898fff334286c027e0859/data'
    //     : 'community.wave.seqera.io/library/htslib_samtools:1.24--d697cfb9dce007cd'}"

    input:
    tuple val(meta), path(tree)
    path(nt_muts)
    path(reference_gb)

    output:
    path("${tree.baseName}_aa-muts.json"), emit: node
    
    script:
    def args = task.ext.args ?: ''
    """
    augur translate \\
    --tree ${tree} \\
    ${args} \\
    --ancestral-sequences ${nt_muts} \\
    --reference-sequence ${reference_gb} \\
    --output-node-data ${tree.baseName}_aa-muts.json
    """
}