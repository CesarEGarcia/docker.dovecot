VERSION = 2.3.6-1

build:
	docker image build -t dovecot-existo:${VERSION} .

test:
	docker container run -d --rm --name test dovecot-existo:${VERSION}
	docker container exec -ti test bash
	docker container rm -f test

# publish:
# 	docker tag dovecot:$(VERSION) existo/dovecot:$(VERSION)
# 	docker push existo/dovecot:$(VERSION)

