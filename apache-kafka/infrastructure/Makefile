.PHONY: combine, start, stop, list, clean_containers, prune_images, prune_volumes, prune_networks, clean

INTERNAL_ENV_FILE = .internal.env
EXTERNAL_ENV_FILE = ../.external.env
COMBINED_ENV_FILE = .combinded.env

combine:
	@cat $(INTERNAL_ENV_FILE) $(EXTERNAL_ENV_FILE) > ${COMBINED_ENV_FILE}

start: combine
	docker compose \
		--env-file $(COMBINED_ENV_FILE) \
		up -d

stop: combine
	docker compose \
		--env-file $(COMBINED_ENV_FILE) \
		down

list:
	docker compose ps -a

clean_restart: stop prune_volumes start

clean_containers:
	docker container kill $$(docker container ls -a -q)
	docker container rm $$(docker container ls -a -q)

prune_images:
	docker image prune -af

prune_volumes:
	docker volume prune -af

prune_networks:
	docker network prune -f

clean:
	docker system prune -af --volumes
