.PHONY: start, stop, list, clean

start:
	docker compose up -d

stop:
	docker compose down

list:
	docker compose ps -a

clean:
	docker system prune -af --volumes
