
build: 
	docker image build -t dovecot:2.2.36 .

test:
	docker container run -d --rm --name test dovecot:2.2.36
	docker container exec -ti test bash
	docker container rm -f test

