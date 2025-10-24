# Architectural Decision Records (ADR)

## 1. Monorepo con Backend y Frontend Separados

**Fecha:** 2025-10-24

**Estado:** Aceptado

**Contexto:**  
Necesitamos organizar una aplicación con backend Rails y frontend React de manera que sea fácil de mantener y desplegar.

**Decisión:**  
Usar una estructura de monorepo con `/server` (Rails API) y `/web` (React). Esto permite:
- Versionado conjunto del código
- Desarrollo coordinado entre frontend y backend
- CI/CD simplificado
- Compartir configuraciones y documentación

**Consecuencias:**
- Requiere coordinar versiones entre ambos proyectos
- El tamaño del repositorio será mayor
- Facilita el desarrollo local y la integración continua

---

## 2. JWT con Refresh Tokens para Autenticación

**Fecha:** 2025-10-24

**Estado:** Aceptado

**Contexto:**  
Necesitamos un sistema de autenticación seguro para una API REST con frontend SPA.

**Decisión:**  
Implementar JWT con refresh tokens usando `devise-jwt`. Esto proporciona:
- Autenticación stateless para la API
- Tokens de corta duración (15 minutos) para access tokens
- Refresh tokens de larga duración (30 días) almacenados de forma segura
- Capacidad de revocar sesiones

**Consecuencias:**
- Complejidad adicional en el manejo de tokens
- Requiere estrategia de renovación en el cliente
- Mayor seguridad que tokens de larga duración únicos

---

## 3. PostgreSQL con Full-Text Search

**Fecha:** 2025-10-24

**Estado:** Aceptado

**Contexto:**  
La aplicación requiere búsqueda eficiente de usuarios y posts por contenido, etiquetas, etc.

**Decisión:**  
Usar las capacidades nativas de PostgreSQL para full-text search:
- Extensión `pg_trgm` para búsqueda por similitud
- `tsvector` para indexación de texto completo
- Índices GIN para rendimiento

**Consecuencias:**
- No requiere servicios externos como Elasticsearch
- Rendimiento adecuado para aplicaciones de tamaño medio
- Limitaciones para búsquedas muy complejas
- Simplicidad en el deployment

---

## 4. Action Cable con Redis para Real-Time

**Fecha:** 2025-10-24

**Estado:** Aceptado

**Contexto:**  
Las notificaciones deben entregarse en tiempo real a los usuarios conectados.

**Decisión:**  
Usar Action Cable (WebSockets) con Redis como backend de pub/sub. Esto permite:
- Notificaciones instantáneas sin polling
- Escalabilidad con múltiples instancias de servidor
- Integración nativa con Rails

**Consecuencias:**
- Requiere Redis como dependencia adicional
- Necesita manejar reconexiones en el cliente
- Mayor complejidad en deployment vs. polling simple

---

## 5. Sidekiq para Jobs en Background

**Fecha:** 2025-10-24

**Estado:** Aceptado

**Contexto:**  
Tareas como envío de emails, procesamiento de menciones y generación de notificaciones no deben bloquear requests HTTP.

**Decisión:**  
Usar Sidekiq con Redis para jobs asíncronos. Beneficios:
- Alta performance (multithreading)
- UI de administración incluida
- Retry automático con backoff exponencial
- Ampliamente adoptado en la comunidad Rails

**Consecuencias:**
- Redis requerido (ya usado para Action Cable)
- Proceso adicional a monitorear
- Requiere considerar idempotencia en jobs

---

## 6. JBuilder para Serialización

**Fecha:** 2025-10-24

**Estado:** Aceptado

**Contexto:**  
Necesitamos serializar modelos a JSON de forma flexible y eficiente.

**Decisión:**  
Usar JBuilder en lugar de ActiveModel::Serializers o blueprinter. Razones:
- Vista-driven: templates claros y reutilizables
- Fragmentos cacheables
- DSL Ruby familiar
- Performance adecuada con partial caching

**Consecuencias:**
- Lógica de presentación en vistas en lugar de clases
- Posible duplicación entre vistas similares
- Requiere atención a N+1 queries

---

## 7. RSpec con FactoryBot para Testing

**Fecha:** 2025-10-24

**Estado:** Aceptado

**Contexto:**  
Necesitamos una suite de tests completa y mantenible.

**Decisión:**  
Stack de testing:
- RSpec para todos los tests
- FactoryBot para fixtures
- Faker para datos realistas
- Shoulda-matchers para validaciones
- SimpleCov para cobertura (objetivo: 90%+)

**Consecuencias:**
- Mayor tiempo inicial de configuración
- Tests más expresivos y legibles
- Mantenimiento más fácil a largo plazo

---

## 8. React Query + Zustand para Estado

**Fecha:** 2025-10-24

**Estado:** Aceptado

**Contexto:**  
El frontend necesita manejar estado de servidor y estado de UI de forma eficiente.

**Decisión:**  
- **React Query:** para estado del servidor (cache, revalidación, optimistic updates)
- **Zustand:** para estado de UI y autenticación (más simple que Redux)

**Consecuencias:**
- Menos boilerplate que Redux
- Cache automático y revalidación de React Query
- Curva de aprendizaje moderada
- Excelente developer experience

---

## 9. Tailwind CSS para Estilos

**Fecha:** 2025-10-24

**Estado:** Aceptado

**Contexto:**  
Necesitamos un sistema de diseño rápido y consistente.

**Decisión:**  
Usar Tailwind CSS con clases de utilidad. Ventajas:
- Desarrollo rápido sin escribir CSS custom
- Diseño consistente con sistema de espaciado
- Tree-shaking automático (bundle pequeño)
- Responsive design integrado

**Consecuencias:**
- HTML con muchas clases (puede ser verboso)
- Requiere familiaridad con las clases de Tailwind
- Customización mediante configuración

---

## 10. Rack::Attack para Rate Limiting

**Fecha:** 2025-10-24

**Estado:** Aceptado

**Contexto:**  
La API necesita protección contra abuso y ataques de fuerza bruta.

**Decisión:**  
Implementar Rack::Attack para rate limiting a nivel de middleware. Límites:
- Auth endpoints: 5 requests/minuto por IP
- API general: 100 requests/minuto por usuario autenticado
- Búsquedas: 20 requests/minuto

**Consecuencias:**
- Protección básica contra abuso
- Puede requerir ajustes según uso real
- Redis necesario para almacenar contadores

---

## 11. GitHub Actions para CI/CD

**Fecha:** 2025-10-24

**Estado:** Aceptado

**Contexto:**  
Necesitamos automatizar tests, linting y security checks.

**Decisión:**  
Pipeline de GitHub Actions que ejecuta:
1. RuboCop (linting)
2. Brakeman (security)
3. RSpec (tests con cobertura 90%+)
4. Build del frontend

**Consecuencias:**
- Integración nativa con GitHub
- Feedback rápido en PRs
- Gratis para repositorios públicos
- Previene merge de código con problemas

---

## 12. Active Storage para Archivos

**Fecha:** 2025-10-24

**Estado:** Aceptado

**Contexto:**  
Usuarios necesitan subir imágenes de perfil y cover.

**Decisión:**  
Usar Active Storage con:
- Local disk para desarrollo
- Configuración lista para S3 en producción
- Validaciones de tipo y tamaño
- Variantes para diferentes resoluciones

**Consecuencias:**
- Integración nativa con Rails
- Migraciones futuras a S3 sin cambios de código
- Requiere procesamiento de imágenes (libvips/ImageMagick)

---

## Decisiones Futuras

- Estrategia de caching (Redis, Memcached)
- Herramientas de observabilidad (New Relic, Datadog)
- Estrategia de deployment (Heroku, AWS, Docker)
- CDN para assets estáticos

