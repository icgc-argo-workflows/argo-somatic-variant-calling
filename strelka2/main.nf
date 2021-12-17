#!/usr/bin/env nextflow

/*
  Copyright (c) 2021, ICGC ARGO

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

  Authors:
    Junjun Zhang
*/

/********************************************************************/
/* this block is auto-generated based on info from pkg.json where   */
/* changes can be made if needed, do NOT modify this block manually */
nextflow.enable.dsl = 2
version = '0.1.0'  // package version

container = [
    'ghcr.io': 'ghcr.io/icgc-argo-workflows/argo-somatic-variant-calling.strelka2'
]
default_container_registry = 'ghcr.io'
/********************************************************************/


// universal params go here
params.container_registry = ""
params.container_version = ""
params.container = ""

params.cpus = 1
params.mem = 1  // GB
params.publish_dir = ""  // set to empty string will disable publishDir

params.tumourBam = ""
params.normalBam = ""
params.referenceFa = ""
params.isExome = false

process strelka2 {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"
  publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", mode: "copy", enabled: params.publish_dir

  cpus params.cpus
  memory "${params.mem} GB"

  input:
    path tumourBam
    path tumourBai
    path normalBam
    path normalBai
    path referenceFa
    path referenceFai
    val isExome


  output:
    path "output_dir/results/variants/somatic.snvs.vcf.gz", emit: somaticSnvVcf
    path "output_dir/results/variants/somatic.snvs.vcf.gz.tbi", emit: somaticSnvVcfTbi
    path "output_dir/results/variants/somatic.indels.vcf.gz", emit: somaticIndelVcf
    path "output_dir/results/variants/somatic.indels.vcf.gz.tbi", emit: somaticIndelVcfTbi
    path "output_dir/results/stats/runStats.tsv", emit: runStats

  script:
    arg_exome = isExome == "true" ? "--exome" : ""

    """
    
    mkdir -p output_dir

    configureStrelkaSomaticWorkflow.py \
      --tumorBam=${tumourBam} \
      --normalBam=${normalBam} \
      --referenceFasta=${referenceFa} \
      --callMemMb=${Math.round(params.mem * 1000 / params.cpus)} \
      --runDir=./output_dir ${arg_exome}

    ./output_dir/runWorkflow.py -m local -j ${params.cpus}

    """
}


// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx
workflow {
  tumourIdx = params.tumourBam.endsWith('.bam') ? params.tumourBam + '.bai' : params.tumourBam + '.crai'
  normalIdx = params.normalBam.endsWith('.bam') ? params.normalBam + '.bai' : params.normalBam + '.crai'

  strelka2(
    file(params.tumourBam),
    file(tumourIdx),
    file(params.normalBam),
    file(normalIdx),
    file(params.referenceFa),
    file(params.referenceFa + '.fai'),
    params.isExome
  )
}
