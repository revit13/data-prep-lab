
# Directories in the transforms/universal directory for which we want to generate test workflows
UNIVERSAL_TRANSFORMS=doc_id ededup fdedup filter html2parquet noop profiler resize tokenization
# Directories in the transforms/code directory for which we want to generate test workflows
CODE_TRANSFORMS=code2parquet code_quality header_cleanser malware proglang_select repo_level_ordering
# Directories in the transforms/language directory for which we want to generate test workflows
LANG_TRANSFORMS=doc_chunk doc_quality lang_id pdf2parquet pii_redactor text_encoder


transform-tests:
	$(MAKE) TRANSFORM_SUBDIR=universal .transform-tests
	$(MAKE) TRANSFORM_SUBDIR=language .transform-tests
	$(MAKE) TRANSFORM_SUBDIR=code .transform-tests

KFP_BLACK_LIST: "doc_chunk-ray,pdf2parquet-ray,pii_redactor"

# Expects
#   TRANSFORM_SUBDIR  transforms subdirectory (such as universal)
.transform-tests:
	@for i in $$(find ../../transforms/$(TRANSFORM_SUBDIR) -mindepth 1 -maxdepth 1 -type d  ); do	\
	    dir=$$(basename $$i);							\
	    yml=test-$(TRANSFORM_SUBDIR)-$$dir.yml;					\
	    echo Generating $$yml;							\
	    cat test-transform.template | sed -e "s?@TARGET_TRANSFORM_DIR@?transforms/$${TRANSFORM_SUBDIR}/$$dir?g" > $$yml;	\
	done

.transform-kfp-tests:
	@for i in $$(find ../../transforms/$(TRANSFORM_SUBDIR) -mindepth 1 -maxdepth 1 -type d  ); do	\
		dir=$$(basename $$i);	\
		if [ -d $$dir/kfp_ray ] && echo ${KFP_BLACK_LIST} | grep -qv $$dir ; then \
                      header_text "Skipping $$dir"  \
                      continue; 			\					
		fi
	    yml=test-$(TRANSFORM_SUBDIR)-$$dir.yml;					\
	    echo Generating $$yml;							\
	    cat test-kfp-transform.template | sed -e "s?@TARGET_TRANSFORM_DIR@?transforms/$${TRANSFORM_SUBDIR}/$$dir?g" > $$yml;	\
	done






