
all: dpc2sim-stream

run: dpc2sim-stream
	zcat traces/mcf_trace2.dpc.gz | ./dpc2sim-stream

dpc2sim-stream:
	$(CXX) -Wall -no-pie -o dpc2sim-stream example_prefetchers/stream_prefetcher.cc lib/dpc2sim.a

clean:
	rm -rf dpc2sim-stream

.PHONY: all run clean
