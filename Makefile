.PHONY: help setup up down logs lint test seed docs clean install-server install-web server-console

help: ## Muestra este mensaje de ayuda
	@echo "Comandos disponibles:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## Configuración inicial del proyecto (instala dependencias)
	@echo "🚀 Configurando el proyecto..."
	@$(MAKE) install-server
	@$(MAKE) install-web
	@cd server && bundle exec rails db:create db:migrate
	@echo "✅ Setup completado!"

install-server: ## Instala dependencias del backend
	@echo "📦 Instalando dependencias del servidor..."
	@cd server && bundle install

install-web: ## Instala dependencias del frontend
	@echo "📦 Instalando dependencias del frontend..."
	@cd web && npm install

up: ## Inicia todos los servicios
	@echo "🚀 Iniciando servicios..."
	@cd server && bundle exec rails server -p 3000 &
	@cd server && bundle exec sidekiq &
	@cd web && npm run dev

down: ## Detiene todos los servicios
	@echo "🛑 Deteniendo servicios..."
	@pkill -f "rails server" || true
	@pkill -f "sidekiq" || true
	@pkill -f "vite" || true

logs: ## Muestra logs del servidor
	@tail -f server/log/development.log

lint: ## Ejecuta linters (RuboCop)
	@echo "🔍 Ejecutando linters..."
	@cd server && bundle exec rubocop
	@cd web && npm run lint

test: ## Ejecuta tests del backend
	@echo "🧪 Ejecutando tests..."
	@cd server && bundle exec rspec

seed: ## Carga datos de prueba
	@echo "🌱 Cargando seeds..."
	@cd server && bundle exec rails db:seed

docs: ## Genera documentación Swagger
	@echo "📚 Generando documentación..."
	@cd server && bundle exec rake rswag:specs:swaggerize
	@echo "✅ Documentación disponible en http://localhost:3000/api-docs"

clean: ## Limpia archivos temporales
	@echo "🧹 Limpiando..."
	@cd server && bundle exec rails tmp:clear log:clear
	@cd web && rm -rf dist .vite
	@echo "✅ Limpieza completada!"

server-console: ## Abre consola de Rails
	@cd server && bundle exec rails console

db-reset: ## Reinicia la base de datos
	@echo "🔄 Reiniciando base de datos..."
	@cd server && bundle exec rails db:drop db:create db:migrate db:seed

security: ## Ejecuta análisis de seguridad (Brakeman)
	@echo "🔒 Analizando seguridad..."
	@cd server && bundle exec brakeman -q

coverage: ## Genera reporte de cobertura de tests
	@echo "📊 Generando reporte de cobertura..."
	@cd server && COVERAGE=true bundle exec rspec
	@open server/coverage/index.html

