# 🚀 AIPosts - Guía de Inicio Rápido

## ⚡ Setup en 3 Minutos

### 1️⃣ Prerrequisitos
Asegúrate de tener instalado:
- ✅ Ruby 3.4.4
- ✅ Rails 8.0.3
- ✅ PostgreSQL 14+
- ✅ Redis 6+
- ✅ Node.js 18+

### 2️⃣ Instalación

```bash
cd rails_aiposts_with_rules

# Instalar todo (backend + frontend + crear DB)
make setup

# Cargar datos de ejemplo (21 usuarios, 125 posts, etc.)
make seed
```

### 3️⃣ Iniciar Servicios

**Opción A: Todo junto (requiere 3 terminales)**
```bash
# Terminal 1: Rails API
cd server && rails server

# Terminal 2: Sidekiq (jobs en background)
cd server && sidekiq

# Terminal 3: Frontend React
cd web && npm run dev
```

**Opción B: Con Make (experimental)**
```bash
make up
```

### 4️⃣ Acceder a la Aplicación

- **Frontend:** http://localhost:5173
- **API:** http://localhost:3000
- **Swagger Docs:** http://localhost:3000/api-docs

**Credenciales de prueba:**
- Email: `john@example.com`
- Password: `password123`

---

## 🧪 Verificar que Todo Funciona

### Backend
```bash
cd server

# Tests
bundle exec rspec

# Lint
bundle exec rubocop

# Security
bundle exec brakeman

# Consola Rails
bundle exec rails console
# > User.count  # Debe retornar 21
# > Post.count  # Debe retornar 125
```

### Frontend
```bash
cd web

# Build (verificar que compila)
npm run build

# Dev server
npm run dev
```

---

## 🎯 Probar la Aplicación

### 1. Login
1. Ir a http://localhost:5173/login
2. Usar: john@example.com / password123
3. Debe redirigir al Feed

### 2. Ver Feed
- Deberías ver posts de usuarios que John sigue
- Cada post muestra: contenido, tags, likes, comentarios

### 3. Registrar Nuevo Usuario
1. Ir a http://localhost:5173/register
2. Completar el formulario
3. Debe crear cuenta y loguear automáticamente

### 4. Probar API (con curl)

**Login:**
```bash
curl -X POST http://localhost:3000/api/v1/auth/sign_in \
  -H "Content-Type: application/json" \
  -d '{"user": {"email": "john@example.com", "password": "password123"}}'
```

Guarda el token JWT del header `Authorization`.

**Listar Posts:**
```bash
curl http://localhost:3000/api/v1/posts
```

**Crear Post (requiere token):**
```bash
curl -X POST http://localhost:3000/api/v1/posts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{"post": {"content": "Mi primer post! #ruby #rails"}}'
```

### 5. Ver Swagger Documentation
1. Ir a http://localhost:3000/api-docs
2. Explorar todos los endpoints disponibles
3. Probar endpoints directamente desde la UI

---

## 📚 Comandos Útiles

```bash
# Ver todos los comandos disponibles
make help

# Reiniciar DB
make db-reset

# Ver logs
make logs

# Limpiar archivos temporales
make clean

# Abrir consola Rails
make server-console

# Ejecutar tests con cobertura
cd server && COVERAGE=true bundle exec rspec

# Ver reporte de cobertura
open server/coverage/index.html
```

---

## 🐛 Troubleshooting

### Error: Database no existe
```bash
cd server
rails db:create
rails db:migrate
rails db:seed
```

### Error: Redis connection refused
```bash
# Iniciar Redis (macOS con Homebrew)
brew services start redis

# O manualmente
redis-server
```

### Error: Port 3000 already in use
```bash
# Matar proceso en puerto 3000
lsof -ti:3000 | xargs kill -9

# O cambiar puerto
rails server -p 3001
```

### Error: Cannot find module (Frontend)
```bash
cd web
rm -rf node_modules package-lock.json
npm install
```

### Error: JWT token inválido
- Logout y login nuevamente
- El token expira después de 15 minutos

---

## 📖 Estructura del Proyecto

```
rails_aiposts_with_rules/
├── server/              # Rails 8 API
│   ├── app/
│   │   ├── controllers/api/v1/  # Todos los endpoints
│   │   ├── models/              # User, Post, Comment, etc.
│   │   ├── jobs/                # Background jobs
│   │   ├── channels/            # WebSockets
│   │   └── serializers/         # JSON serializers
│   ├── spec/                    # RSpec tests
│   └── db/                      # Migrations & seeds
│
├── web/                 # React + TypeScript
│   ├── src/
│   │   ├── components/          # PostCard, Navbar
│   │   ├── pages/               # Login, Register, Feed
│   │   ├── lib/                 # API client
│   │   ├── stores/              # Zustand stores
│   │   └── types/               # TypeScript types
│   └── public/
│
├── docs/                # Documentación
├── .github/workflows/   # CI/CD
└── Makefile             # Comandos útiles
```

---

## 🎓 Recursos Adicionales

- **[README.md](README.md)** - Documentación completa
- **[PROJECT_STATUS.md](PROJECT_STATUS.md)** - Estado del proyecto
- **[COMPLETION_SUMMARY.md](COMPLETION_SUMMARY.md)** - Resumen de completitud
- **[docs/ADR.md](docs/ADR.md)** - Decisiones arquitectónicas
- **[PROMPT.md](PROMPT.md)** - Especificaciones originales

---

## 🚀 Siguientes Pasos

Después del setup inicial, puedes:

1. **Explorar la API** con Swagger: http://localhost:3000/api-docs
2. **Crear más posts** desde la consola Rails
3. **Probar WebSockets** (notificaciones real-time)
4. **Ejecutar tests** con `bundle exec rspec`
5. **Extender el frontend** con más páginas
6. **Deploy a producción** (Heroku, AWS, etc.)

---

**¿Necesitas ayuda?** Revisa la documentación completa en [README.md](README.md)

¡Disfruta construyendo con AIPosts! 🎉

