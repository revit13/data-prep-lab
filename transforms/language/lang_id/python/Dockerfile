FROM docker.io/python:3.10.14-slim-bullseye AS builder-stage

RUN pip install --upgrade pip 

# Create a user and use it to run the transform
RUN useradd -ms /bin/bash dpk
USER dpk
WORKDIR /home/dpk

# Copy and install data processing libraries 
# These are expected to be placed in the docker context before this is run (see the make image).
COPY --chown=dpk:root data-processing-lib-python/ data-processing-lib-python/
RUN cd data-processing-lib-python && pip install --no-cache-dir -e .

# END OF STEPS destined for a data-prep-kit base image 

# set up environment required to install and use huggingface and fasttext
USER root
RUN apt update && apt install gcc g++ -y
RUN mkdir -p /home/dpk/.cache/huggingface/hub && chmod -R 777 /home/dpk/.cache/huggingface/hub
USER dpk

COPY --chown=dpk:root src/ src/
COPY --chown=dpk:root pyproject.toml pyproject.toml 
RUN pip install --no-cache-dir -e .

# clean up apt
USER root 
RUN apt-get remove gcc g++ -y \
    && apt clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
USER dpk


# Set environment
ENV PYTHONPATH /home/dpk

FROM builder-stage AS test
ARG EXECUTE_TESTS

# install pytest
RUN pip install --no-cache-dir pytest

# copy test
COPY --chown=ray:users test/ test/
COPY --chown=ray:users test-data/ test-data/
RUN if [ "${EXECUTE_TESTS}" = "true" ]; then echo "===> RUNNING TESTS"; export PYTHONPATH=$PYTHONPATH:../src && cd test && pytest .; fi

## final stage
FROM builder-stage AS base

# copy source data
COPY ./src/lang_id_transform_python.py .
COPY ./src/lang_id_local.py local/

# Put these at the end since they seem to upset the docker cache.
ARG BUILD_DATE
ARG GIT_COMMIT
LABEL build-date=$BUILD_DATE
LABEL git-commit=$GIT_COMMIT