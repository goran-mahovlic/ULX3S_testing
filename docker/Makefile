testing: build
	docker run -it --privileged --name ulx3s-testing-buster --volume `pwd | sed 's/docker//'`:/ULX3S_testing -v /run/udev:/run/udev -v /dev:/dev --rm dpavlin/ulx3s-testing-buster /ULX3S_testing/docker/udev-testing.sh

production: build
	docker run -it --privileged --name ulx3s-testing-buster --volume `pwd | sed 's/docker//'`:/ULX3S_testing -v /run/udev:/run/udev -v /dev:/dev --rm -e PRODUCTION=1 dpavlin/ulx3s-testing-buster /ULX3S_testing/docker/udev-testing.sh

bash: build
	docker run -it --privileged --name ulx3s-testing-buster --volume `pwd | sed 's/docker//'`:/ULX3S_testing -v /run/udev:/run/udev -v /dev:/dev --rm dpavlin/ulx3s-testing-buster /ULX3S_testing/docker/udev-bash.sh

build:
	docker build -t dpavlin/ulx3s-testing-buster .


