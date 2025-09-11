# Primera etapa: 'builder'
# Esta etapa instala las dependencias y construye la aplicación.
FROM node:18-alpine AS builder

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia los archivos de manifiesto del proyecto para aprovechar el cache de Docker.
COPY package.json package-lock.json* ./

# Instala todas las dependencias, incluidas las de desarrollo.
RUN npm ci

# Copia el resto del código fuente al contenedor, incluyendo la carpeta 'src'.
COPY . .

# Genera el build de la aplicación de Next.js.
RUN npm run build

# ---
# Segunda etapa: 'runner'
# Esta etapa es para la imagen final de producción, la más ligera posible.
FROM node:18-alpine AS runner

# Establece el directorio de trabajo
WORKDIR /app

# Establece un usuario no-root para mayor seguridad.
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copia los archivos de la build y los `node_modules` de la etapa 'builder'.
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

# Establece las variables de entorno para producción.
ENV NODE_ENV=production
ENV PORT=80
ENV HOSTNAME="0.0.0.0"

# Next.js por defecto usa el puerto 3000.
EXPOSE 80

# El comando final para iniciar la aplicación en producción.
CMD ["node", "server.js"]
