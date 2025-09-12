# Primera etapa: 'builder'
FROM node:18-alpine AS builder
WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci
COPY . .
RUN npm run build

# ---
# Segunda etapa: 'runner' 
FROM node:18-alpine AS runner
WORKDIR /app

# PRIMERO dar permisos para puerto 80
USER root
RUN apk add --no-cache libcap && \
    setcap 'cap_net_bind_service=+ep' /usr/local/bin/node

# CREAR usuario y grupo (en orden correcto)
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs -G nodejs

#CORREGIR orden de copia: PRIMERO standalone, LUEGO static y public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=builder --chown=nextjs:nodejs /app/public ./public

# Variables de entorno
ENV NODE_ENV=production
ENV PORT=80
ENV HOSTNAME="0.0.0.0"

EXPOSE 80

# Ejecutar como usuario no-root PERO con permisos para puerto 80
USER nextjs:nodejs

CMD ["node", "server.js"]