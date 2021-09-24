all: docker resolve
	
docker:
	docker build . -t anothertest/accel-sim-framework

dump_docker:
	docker build dumps -t anothertest/accel-sim-dumps

resolve:
	rm -fr res
	sh -c 'hash=$$(docker create -t anothertest/accel-sim-framework); docker cp $$hash:/results res; docker rm $$hash'

dumps: dump_docker
	rm -fr out_dumps
	sh -c 'hash=$$(docker create -t anothertest/accel-sim-dumps); docker cp $$hash:/dumps out_dumps; docker rm $$hash'
