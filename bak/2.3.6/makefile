VERSION = 2.3.6

build:
	docker image build -t dovecot:${VERSION} .

test:
	docker container run -d --rm --name test dovecot:${VERSION}
	docker container exec -ti test bash
	docker container rm -f test

publish:
	docker tag dovecot:$(VERSION) existo/dovecot:$(VERSION)
	docker push existo/dovecot:$(VERSION)

