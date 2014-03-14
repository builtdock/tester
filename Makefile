build:
	$(MAKE) -C master build
	$(MAKE) -C slave build

killall:
	docker kill `docker ps -q`

clean:
	docker rm `docker ps -a -q`
	docker rmi `docker images -q`

master_shell:
	$(MAKE) -C master shell

slave_shell:
	$(MAKE) -C slave shell
