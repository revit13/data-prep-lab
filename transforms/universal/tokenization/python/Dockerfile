## builder stage

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

# Install python project source
COPY --chown=dpk:users src/ src/
COPY --chown=dpk:users pyproject.toml pyproject.toml
COPY --chown=dpk:users README.md Readme.md
RUN pip install --no-cache-dir -e .

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
COPY ./src/tokenization_transform.py . 
COPY ./src/tokenization_transform_python.py .
COPY ./src/tokenization_utils.py .
COPY src/tokenization_local_python.py local/

# Put these at the end since they seem to upset the docker cache.
ARG BUILD_DATE
ARG GIT_COMMIT
LABEL build-date=$BUILD_DATE
LABEL git-commit=$GIT_COMMIT

