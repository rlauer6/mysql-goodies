.PHONY: rpm

rpm: Dockerfile.mysql8
	docker build -f Dockerfile.mysql8 . -t dbd-mysql-8 | tee docker-build.log
	id=$$(docker create --name=dbd-mysql dbd-mysql-8); \
	for a in $$(docker run --rm -i dbd-mysql-8 ls /root/rpmbuild/RPMS/x86_64); do \
	  docker cp $$id:/root/rpmbuild/RPMS/x86_64/$$a . ; \
	done; \
	docker rm $$id

