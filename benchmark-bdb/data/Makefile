
# run this file to download the needed data files ot run this benchmark
# tiny is about 20mb, 1node is ~15gb
#
dry := --dry-run
dry := 

all: tiny 1node

tiny:
	aws s3 sync $(dry) --exclude "*" --include "*tiny*" s3://big-data-benchmark/pavlo/ ./

1node:
	aws s3 sync $(dry) --exclude "*" --include "*1node*" s3://big-data-benchmark/pavlo/text-deflate ./text-deflate
#	aws s3 sync $(dry) --exclude "*" --include "*1node*" s3://big-data-benchmark/pavlo/text ./text

