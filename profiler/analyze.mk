

all: cptmp sql_benchmark_id perf_pidtid.svg perf_pid.svg perf.svg

clean:
	-rm perf_script.out.tar.gz
	sudo rm -rf /tmp/perf*.map

cleanall:
	-rm perf_script.out.gz

cptmp:
	sudo rm -rf /tmp/perf*.map
	sudo cp perf*.map /tmp

#one liner that we don't use but would save the most space
# sudo perf script -f comm,pid,tid,cpu,time,event,ip,sym,dso,trace \
	# | ~/nfs/bigdata/FlameGraph/stackcollapse-perf.pl \
	# |  ~/nfs/bigdata/FlameGraph/flamegraph.pl --color=java > ./test.svg


stackcollapse := ~/nfs/bigdata/FlameGraph/stackcollapse-perf.pl
flamegraph := ~/nfs/bigdata/FlameGraph/flamegraph.pl
perf2sql := ~/nfs/bigdata/profiler/perf2sql.py

perf.data: | perf.data.gz
	gzip -dc $^ > perf.data

perf_script.out.gz: | perf.data
	perf script -f comm,pid,tid,cpu,time,event,ip,sym,dso,trace | \
	gzip -9 > $@

sql_benchmark_id: | perf_script.out.gz
	gzip -dc perf_script.out.gz | \
	$(perf2sql) --name $(basename `pwd`) --dbpass hellopostgres > $@

#perf_script.out.gz: perf.data.gz
	#gzip -dc $< | perf script -i - -f comm,pid,tid,cpu,time,event,ip,sym,dso,trace | \
		#gzip -9 > $@

perf_pidtid.svg: | perf_script.out.gz
	gzip -dc $^ | \
	$(stackcollapse) --stdin --pid --tid | \
		~/nfs/bigdata/FlameGraph/flamegraph.pl \
		--color=java > $@

perf_pid.svg: | perf_script.out.gz
	gzip -dc $^ | \
	$(stackcollapse) --stdin --pid | \
		~/nfs/bigdata/FlameGraph/flamegraph.pl \
		--color=java > $@

perf.svg: | perf_script.out.gz
	gzip -dc $^ | \
	$(stackcollapse) --stdin | \
		~/nfs/bigdata/FlameGraph/flamegraph.pl \
		--color=java > $@
