SHELL := /bin/bash
GITHUB_RUN_ID ?=123

b: build-npm build-maven
buildw:
	cd vma-service && ./mvnw clean install
build:
	mvn clean install
build-maven:
	mvn clean install -DskipTests
build-npm:
	cd vma-gui && yarn && npm run build
	bash cleanup.sh
	mv vma-gui/dist docker-images/nginx/
test:
	mvn test
test-maven:
	mvn test
local: no-test
	mkdir -p bin
no-test:
	mvn clean install -DskipTests
docker:
	docker-compose -p "${GITHUB_RUN_ID}" up -d --build --remove-orphans
docker-action:
	docker-compose -p "${GITHUB_RUN_ID}" -f docker-compose.yml up -d --build --remove-orphans
docker-databases: stop local
build-images:
build-docker: stop no-test
	docker-compose -p "${GITHUB_RUN_ID}" up -d --build --remove-orphans
show:
	docker ps -a  --format '{{.ID}} - {{.Names}} - {{.Status}}'
docker-clean:
	docker-compose -p "${GITHUB_RUN_ID}" rm -svf
docker-delete-idle:
	docker ps --format '{{.ID}}' -q --filter="name=jofisaes_vma_" | xargs -I {}  docker rm {}
docker-delete: stop
	docker ps -a --format '{{.ID}}' -q --filter="name=jofisaes_vma_" | xargs -I {}  docker stop {}
	docker ps -a --format '{{.ID}}' -q --filter="name=jofisaes_vma_" | xargs -I {}  docker rm {}
docker-cleanup: docker-delete
	docker images -q | xargs docker rmi
docker-delete-apps: stop
docker-clean-build-start: docker-clean b docker
docker-clean-start: docker-clean docker
docker-psql-cluster:
	docker-compose -p "${GITHUB_RUN_ID}" down --remove-orphans
	docker-compose -p "${GITHUB_RUN_ID}" up -d --build jofisaes-vma-haproxy-lb jofisaes-vma-etcd
	docker-compose -p "${GITHUB_RUN_ID}" up -d --build jofisaes-vma-postgres-1
	docker-compose -p "${GITHUB_RUN_ID}" up -d --build jofisaes-vma-postgres-2 jofisaes-vma-postgres-3
docker-no-app: docker-psql-cluster
	docker-compose -p "${GITHUB_RUN_ID}" up -d --build jofisaes-schemaregistry jofisaes-vma-zookeeper jofisaes-vma-broker
docker-stop-apps:
	docker stop jofisaes-vma-nginx-lb
	docker stop jofisaes-vma-backend-img-1
	docker stop jofisaes-vma-backend-img-2
	docker stop jofisaes_vma_backend_img_3
	docker stop jofisaes_vma_listener
docker-start-kafka:
	docker start jofisaes-vma-zookeeper
	docker start jofisaes-vma-broker
docker-stats:
	docker stats
prune-all: docker-delete
	docker system prune --all
	docker builder prune
	docker system prune --all --volumes
stop:
	docker-compose -p "${GITHUB_RUN_ID}" down --remove-orphans
install:
	/usr/bin/python3 -m pip install --upgrade pip
	pip3 install requests
	pip3 install locust
case:
	cd vma-demo && make create-vmas
locust: case
	cd locust && locust --host=localhost --headless -u 10 -r 10 --run-time 30s --csv vma-awards --exit-code-on-error 0
locust-short: case
	cd locust && locust --host=localhost --headless -u 10 -r 10 --run-time 5s --csv vma-awards --exit-code-on-error 0
count-votes:
	curl -i -X POST http://localhost:8080/api/vma/voting/count
vma-wait:
	bash vma_wait.sh
db-wait:
	bash db_wait.sh
dcup-light: stop
	docker-compose -p "${GITHUB_RUN_ID}" up -d --build --remove-orphans jofisaes-vma-postgres-1 jofisaes-vma-postgres-2 jofisaes-vma-postgres-3 jofisaes-vma-haproxy-lb jofisaes-vma-etcd
	make db-wait
dcup-medium: stop dcup-light kafka
dcd: stop
dcup: dcd docker-clean docker vma-wait
dcup-full: docker-clean-build-start vma-wait
dcup-full-action: docker-clean b docker-action vma-wait
cypress-open:
	cd e2e && yarn && npm run cypress
cypress-electron:
	cd e2e && make cypress-electron
cypress-chrome:
	cd e2e && make cypress-chrome
cypress-firefox:
	cd e2e && make cypress-firefox
cypress-edge:
	cd e2e && make cypress-edge
demo: dcup cypress
demo-full: dcup-full cypress
demo-full-manual: dcup-full cypress-open
kafka:
	docker-compose -p "${GITHUB_RUN_ID}" rm -svf jofisaes-vma-zookeeper
	docker-compose -p "${GITHUB_RUN_ID}" rm -svf jofisaes-vma-broker
	docker-compose -p "${GITHUB_RUN_ID}" rm -svf jofisaes-schemaregistry
	docker-compose -p "${GITHUB_RUN_ID}" up -d --build --remove-orphans jofisaes-vma-zookeeper jofisaes-vma-broker jofisaes-schemaregistry
	bash kafka_wait.sh
backend:
	docker-compose -p "${GITHUB_RUN_ID}" rm -svf jofisaes-vma-backend-img-1
	docker-compose -p "${GITHUB_RUN_ID}" rm -svf jofisaes-vma-backend-img-2
	docker-compose -p "${GITHUB_RUN_ID}" build jofisaes-vma-backend-img-1
	docker-compose -p "${GITHUB_RUN_ID}" build jofisaes-vma-backend-img-2
	docker-compose -p "${GITHUB_RUN_ID}" up -d --build --remove-orphans jofisaes-vma-backend-img-1 jofisaes-vma-backend-img-2
