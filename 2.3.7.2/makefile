NAME = dovecot
VERSION = 2.3.7.2

build:
	docker image build -t ${NAME}:${VERSION} .

test:
	docker container run -d --rm --name test ${NAME}:${VERSION}
	docker container exec -ti test bash
	docker container rm -f test

publish:
	docker tag ${NAME}:$(VERSION) docker.existo.net/${NAME}:$(VERSION)
	docker push docker.existo.net/${NAME}:$(VERSION)

