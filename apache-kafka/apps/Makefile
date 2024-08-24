.PHONY: combine, start, stop, list

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
