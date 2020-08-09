testing: build
	docker run -it --privileged --name ulx3s-testing-buster --volume `pwd | sed 's/docker//'`:/ULX3S_testing --rm -e DEBUG=1 dpavlin/ulx3s-testing-buster /ULX3S_testing/testing.pl

run: build
	docker run -it --privileged --name ulx3s-testing-buster --volume `pwd | sed 's/docker//'`:/ULX3S_testing --rm dpavlin/ulx3s-testing-buster

build:
	docker build -t dpavlin/ulx3s-testing-buster .


