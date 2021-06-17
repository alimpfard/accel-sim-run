all:
	docker build . -t anothertest/accel-sim-framework
	rm -fr res
	sh -c 'hash=$$(docker create -t anothertest/accel-sim-framework); docker cp $$hash:/results res; docker rm $$hash'
	
