# Stamps JP

Mapa interactivo de estampas (eki stamps) de estaciones y lugares en Japón. Por ahora: Osaka.

Vue + Leaflet + Supabase, desplegado en Vercel. Instalable en el móvil como PWA ("Agregar a pantalla de inicio").

## Configuración

1. Crear un proyecto en Supabase y ejecutar `supabase/schema.sql` y luego `supabase/2026-10-23-imagenes.sql` en el SQL Editor (imágenes, bucket `stamp-images` y ~100 estaciones JR West de Osaka).
2. En Supabase > Authentication > URL Configuration, agregar `http://localhost:5173` y el dominio de Vercel a las Redirect URLs.
3. Copiar `.env.example` a `.env.local` con la URL y la publishable key.
4. `npm install` y `npm run dev`.

En Vercel: importar el repo y definir `VITE_SUPABASE_URL` y `VITE_SUPABASE_KEY`.
## Fuentes del catálogo

Estaciones con estampa oficial: lista de JR West ([JR Odekake](https://www.jr-odekake.net/navi/stamp_eki/)). Coordenadas y fotos: Wikipedia / Wikimedia Commons (licencias libres). Las imágenes de las estampas JR tienen derechos de autor, así que las suben los usuarios.

## Moderación

Las propuestas de usuarios entran como `pending` (gris en el mapa, solo las ve quien las propuso). Para aprobar:

```sql
update public.stamps set status = 'approved' where id = 123;
```

## Escalar a todo Japón

El esquema ya tiene `prefecture` y `city`. Al crecer el catálogo: cargar estampas por límites del mapa y mover las estadísticas a una vista SQL (ver comentarios `ponytail:`).
