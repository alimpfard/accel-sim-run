name ?= run
insn_count ?= 100M
extra_config ?=
reg2mem ?= false
all: docker resolve

ifneq (,$(findstring reg2mem,$(name)))
reg2mem=true
endif
	
framework:
	docker build . -t anothertest/accel-sim-framework
	touch framework

docker: framework
	docker build runner -t anothertest/accel-sim --build-arg insn_count=$(insn_count) --build-arg extra_config=$(extra_config) --build-arg reg2mem=$(reg2mem)

dump_docker:
	docker build dumps -t anothertest/accel-sim-dumps

resolve:
	rm -fr results-${name}
	sh -c 'hash=$$(docker create -t anothertest/accel-sim); docker cp $$hash:/results results-${name}; docker rm $$hash'

dumps: dump_docker
	rm -fr out_dumps
	sh -c 'hash=$$(docker create -t anothertest/accel-sim-dumps); docker cp $$hash:/dumps out_dumps; docker rm $$hash'

clean:
	docker container prune -f
	docker image prune -f
