# frontend/Dockerfile.dev
FROM node:18-alpine

WORKDIR /app

# Instala expo-cli sin cache para reducir tamaño
RUN npm install -g expo-cli --no-cache


# Copia archivos de dependencias
COPY package.json package-lock.json ./

# Instala dependencias
RUN npm install ci

# Copia el resto del código
COPY . .

# Variables de entorno
ENV NODE_ENV=development

EXPOSE 3000 

# Para Next.js:
CMD ["npm", "run", "dev"]