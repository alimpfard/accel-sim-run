all: docker resolve
	
framework:
	docker build . -t anothertest/accel-sim-framework
	touch framework

docker: framework
	docker build runner -t anothertest/accel-sim

dump_docker:
	docker build dumps -t anothertest/accel-sim-dumps

resolve:
	rm -fr res
	sh -c 'hash=$$(docker create -t anothertest/accel-sim); docker cp $$hash:/results res; docker rm $$hash'

dumps: dump_docker
	rm -fr out_dumps
	sh -c 'hash=$$(docker create -t anothertest/accel-sim-dumps); docker cp $$hash:/dumps out_dumps; docker rm $$hash'

clean:
	docker container prune -f
	docker image prune -f
