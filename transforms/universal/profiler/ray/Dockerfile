## builder stage

FROM docker.io/rayproject/ray:2.24.0-py310 AS builder-stage

# Copy and install data processing libraries
# These are expected to be placed in the docker context before this is run (see the make image).
COPY --chown=ray:users data-processing-lib-python/ data-processing-lib-python/
RUN cd data-processing-lib-python && pip install --no-cache-dir -e .
COPY --chown=ray:users data-processing-lib-ray/ data-processing-lib-ray/
RUN cd data-processing-lib-ray && pip install --no-cache-dir -e .

COPY --chown=ray:users src/ src/
COPY --chown=ray:users pyproject.toml pyproject.toml
RUN pip install -e .

# Set environment
ENV PYTHONPATH /home/ray

## test stage

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
COPY src/profiler_transform_ray.py .
COPY src/profiler_local_ray.py local/

# Put these at the end since they seem to upset the docker cache.
ARG BUILD_DATE
ARG GIT_COMMIT
LABEL build-date=$BUILD_DATE
LABEL git-commit=$GIT_COMMIT
