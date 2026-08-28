# Deployment

## Docker

The app can run locally as a full Docker stack with a PostGIS database, Node
backend, and Flutter web frontend served by Nginx.

Copy or reference the provided local defaults:

```bash
docker compose --env-file .env.docker.example up --build
```

Run the database schema, seed, and PostGIS setup explicitly:

```bash
docker compose --env-file .env.docker.example run --rm migrate
```

Local URLs:

- Frontend: `http://localhost:8002`
- Backend health: `http://localhost:4000/api/health`

The frontend Docker build uses `FRONTEND_API_BASE_URL`, which defaults to
`http://localhost:4000/api`. This must be browser-reachable because Flutter web
runs in the user's browser, not inside Docker's internal network.

The Flutter app also needs Firebase values in its bundled `.env` asset. Docker
does not copy `frontend/.env`; instead, set the `FIREBASE_*` values in your
local Docker env file before building the frontend image.

Useful checks:

```bash
docker compose --env-file .env.docker.example build
docker compose --env-file .env.docker.example run --rm backend npm test
```

## Backend

The backend can be deployed to Render with the root `render.yaml`.

Required environment variables:

- `DATABASE_URL`
- `JWT_SECRET`
- `CORS_ORIGIN`

Optional environment variables:

- `GEMINI_API_KEY`
- `GEMINI_MODEL`

Database setup:

```bash
npm run db:schema
npm run db:seed
npm run db:postgis
```

Run `db:postgis` only when the PostgreSQL host supports the PostGIS extension.

## Frontend

The Flutter web app can be deployed with the root `netlify.toml`.

Required build variable:

- `API_BASE_URL=https://your-backend.example.com/api`

Build command:

```bash
cd frontend
flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL
```

Publish directory:

```text
frontend/build/web
```
