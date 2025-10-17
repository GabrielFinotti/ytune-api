# Build stage
FROM node:20-alpine AS builder

# Instalar dependências necessárias para compilação
RUN apk add --no-cache python3 make g++

WORKDIR /app

# Copiar arquivos de dependências
COPY package*.json ./

# Instalar todas as dependências (incluindo dev)
RUN npm install

# Copiar código fonte
COPY . .

# Build da aplicação
RUN npm run build

# Production stage
FROM node:20-alpine

# Instalar ffmpeg (necessário para o youtube-dl-exec)
RUN apk add --no-cache ffmpeg python3

# Criar usuário não-root para segurança
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /app

# Copiar package files
COPY package*.json ./

# Instalar apenas dependências de produção
RUN npm install --omit=dev && \
    npm cache clean --force

# Copiar código compilado do builder
COPY --from=builder /app/dist ./dist

# Mudar ownership para usuário não-root
RUN chown -R nodejs:nodejs /app

# Usar usuário não-root
USER nodejs

# Comando para iniciar a aplicação
CMD ["node", "dist/server.js"]
