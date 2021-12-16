FROM ubuntu:18.04

LABEL org.opencontainers.image.source https://github.com/icgc-argo-workflows/argo-somatic-variant-calling

ENV PATH="/tools:${PATH}"

COPY *.py /tools/

ENTRYPOINT ["/usr/bin/env"]

CMD ["/bin/bash"]
