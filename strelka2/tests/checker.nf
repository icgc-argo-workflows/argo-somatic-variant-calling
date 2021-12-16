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

/*
 This is an auto-generated checker workflow to test the generated main template workflow, it's
 meant to illustrate how testing works. Please update to suit your own needs.
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

// universal params
params.container_registry = ""
params.container_version = ""
params.container = ""

// tool specific parmas go here, add / change as needed
params.tumourBam = ""
params.normalBam = ""
params.referenceFa = ""
params.isExome = true

params.expected_snv_output = ""
params.expected_indel_output = ""

include { strelka2 } from '../main'
include { getSecondaryFiles as getSec } from './wfpr_modules/github.com/icgc-argo-workflows/data-processing-utility-tools/helper-functions@1.0.2/main'


process file_smart_diff {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"

  input:
    path output_somaticSnvVcf
    path expected_snv_output
    path output_somaticIndelVcf
    path expected_indel_output

  output:
    stdout()

  script:
    """
    gunzip -c ${output_somaticSnvVcf} \
      | grep -v '^#' > normalized_output_somaticSnvVcf

    gunzip -c ${expected_snv_output} \
      | grep -v '^#' > normalized_expected_snv_output

    diff normalized_output_somaticSnvVcf normalized_expected_snv_output \
      && ( echo -n "SNV calls MATCH. " ) || ( echo "Test FAILED, output SNV calls mismatch." && exit 1 )

    gunzip -c ${output_somaticIndelVcf} \
      | grep -v '^#' > normalized_output_somaticIndelVcf

    gunzip -c ${expected_indel_output} \
      | grep -v '^#' > normalized_expected_indel_output

    diff normalized_output_somaticIndelVcf normalized_expected_indel_output \
      && ( echo "Indel calls MATCH. Test PASSED" && exit 0 ) || ( echo "Test FAILED, output Indel calls mismatch." && exit 1 )

    """
}


workflow checker {
  take:
    tumourBam
    tumourBai
    normalBam
    normalBai
    referenceFa
    referenceFai
    isExome
    expected_snv_output
    expected_indel_output

  main:
    strelka2(
      tumourBam,
      tumourBai,
      normalBam,
      normalBai,
      referenceFa,
      referenceFai,
      isExome
    )

    file_smart_diff(
      strelka2.out.somaticSnvVcf,
      expected_snv_output,
      strelka2.out.somaticIndelVcf,
      expected_indel_output
    )
}


workflow {
  checker(
    file(params.tumourBam),
    Channel.fromPath(getSec(params.tumourBam, ['crai', 'bai'])).collect(),
    file(params.normalBam),
    Channel.fromPath(getSec(params.normalBam, ['crai', 'bai'])).collect(),
    file(params.referenceFa),
    Channel.fromPath(getSec(params.referenceFa, ['fai']), checkIfExists: true).collect(),
    params.isExome,
    file(params.expected_snv_output),
    file(params.expected_indel_output)
  )
}
