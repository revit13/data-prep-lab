ARG BASE_IMAGE=quay.io/dataprep1/data-prep-kit/data-prep-kit-spark-3.5.1:0.1.0
FROM ${BASE_IMAGE} AS builder-stage

USER root

WORKDIR ${SPARK_HOME}/work-dir

# Copy in the data processing framework source/project and install it
# This is expected to be placed in the docker context before this is run (see the make image).

COPY --chown=spark:root data-processing-lib-python/ data-processing-lib-python/
RUN cd data-processing-lib-python && pip install --no-cache-dir -e .
COPY --chown=spark:root data-processing-lib-spark/ data-processing-lib-spark/
RUN cd data-processing-lib-spark && pip install --no-cache-dir -e .

# Install project source
COPY --chown=spark:root src/ src/
COPY --chown=spark:root pyproject.toml pyproject.toml 
RUN pip install --no-cache-dir -e .

# copy config
COPY config/ config/

USER spark

# Set environment
ENV PYTHONPATH=${SPARK_HOME}/work-dir/:${PYTHONPATH}

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

# copy source main 
COPY ./src/doc_id_transform_spark.py .
COPY ./src/doc_id_local.py local/

# Put these at the end since they seem to upset the docker cache.
ARG BUILD_DATE
ARG GIT_COMMIT
LABEL build-date=$BUILD_DATE
LABEL git-commit=$GIT_COMMIT
