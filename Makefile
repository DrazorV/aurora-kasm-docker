.PHONY: build up down logs validate

build:
	docker compose build

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f

validate:
	./scripts/check.sh
