# Nexa-AI

Nexa-AI es un asistente inteligente empresarial construido sobre AWS. El proyecto combina una interfaz web tipo chat, autenticacion con Amazon Cognito, una API serverless con AWS Lambda y API Gateway, y capacidades RAG con Amazon Bedrock Knowledge Bases para responder preguntas usando documentacion corporativa.

El objetivo es entregar un asistente capaz de consultar politicas, manuales, guias operativas y documentos internos, generando respuestas naturales y trazables para usuarios empresariales.

## Arquitectura

La arquitectura propuesta incluye:

- Frontend web desplegado en Amazon S3 y distribuido con Amazon CloudFront.
- Autenticacion de usuarios mediante Amazon Cognito.
- API HTTP con Amazon API Gateway.
- Backend serverless con AWS Lambda en Python.
- Generacion de respuestas con Amazon Bedrock.
- Recuperacion aumentada por conocimiento mediante Bedrock Knowledge Bases.
- Documentos fuente almacenados en Amazon S3.
- Indice vectorial usando Amazon S3 Vectors.
- Monitoreo y auditoria con Amazon CloudWatch y AWS CloudTrail.
- Infraestructura como codigo con Terraform.
- Automatizacion de despliegue con GitHub Actions.

El flujo principal es:

1. El usuario ingresa al frontend.
2. CloudFront entrega la aplicacion web desde S3.
3. El usuario se autentica con Cognito.
4. El frontend envia consultas al endpoint de API Gateway.
5. API Gateway invoca una Lambda.
6. Lambda consulta Amazon Bedrock directamente o usa Bedrock Knowledge Bases si hay una base de conocimiento configurada.
7. Bedrock recupera contexto desde los documentos indexados y genera una respuesta.
8. La respuesta vuelve al frontend junto con las fuentes consultadas cuando aplica.

## Estructura Del Proyecto

```txt
Nexa-AI/
├── .github/
│   └── workflows/
│       └── terraform.yml
├── app/
│   ├── backend/
│   │   └── src/
│   │       └── lambda/
│   │           └── app.py
│   └── frontend/
│       ├── app/
│       ├── components/
│       ├── hooks/
│       ├── lib/
│       ├── public/
│       ├── styles/
│       └── package.json
├── architecture/
│   └── architecture.jpeg
├── infrastructure/
│   └── terraform/
│       ├── main.tf
│       ├── outputs.tf
│       ├── provider.tf
│       ├── variables.tf
│       └── modules/
│           ├── ai/
│           ├── api/
│           ├── audit/
│           ├── auth/
│           └── frontend/
├── knowledge-base/
│   ├── Catalogo_Servicios_Empresariales.pdf
│   ├── Guia_Operativa_Corporativa.pdf
│   ├── Manual_Completo_Soporte_y_Operaciones.pdf
│   ├── Manual_Onboarding_Empleados.pdf
│   ├── Manual_Soporte_Tecnico.pdf
│   ├── Politica_Global_Seguridad.pdf
│   ├── Politicas_Corporativas.pdf
│   └── Procedimientos_Desarrollo_Software.pdf
├── monitoring/
│   └── README.md
├── prompts/
│   └── README.md
└── README.md
```

## Componentes Principales

### Frontend

El frontend esta construido con Next.js y React. La interfaz permite crear conversaciones, escribir preguntas y recibir respuestas del asistente. El punto principal de la aplicacion esta en:

```txt
app/frontend/app/page.tsx
```

Tambien existe una interfaz mas modular en:

```txt
app/frontend/components/
```

Para conectar el frontend con el backend se usa una variable de entorno.
### Backend

El backend esta implementado como una funcion Lambda en Python:

```txt
app/backend/src/lambda/app.py
```

La Lambda expone dos comportamientos principales:

- `GET /health`: endpoint de verificacion.
- `POST /chat`: recibe un mensaje del usuario y devuelve una respuesta generada por Bedrock.

Cuando existe `KNOWLEDGE_BASE_ID`, la Lambda usa `retrieve_and_generate` de Bedrock Agent Runtime para responder con RAG. Si no existe una base de conocimiento configurada, usa una llamada directa al modelo de Bedrock.

### Infraestructura

La infraestructura se define con Terraform en:

```txt
infrastructure/terraform/
```

Modulos disponibles:

- `auth`: Amazon Cognito.
- `api`: API Gateway, Lambda, permisos IAM y logs.
- `ai`: S3 para documentos, S3 Vectors y Bedrock Knowledge Base.
- `frontend`: S3 y CloudFront para publicar la aplicacion web.
- `audit`: CloudTrail para auditoria.

## Ejecucion Local Del Frontend

Desde la carpeta del frontend:

```bash
cd app/frontend
pnpm install
pnpm dev
```

La aplicacion queda disponible en:

```txt
http://localhost:3000
```

## Despliegue De Infraestructura

Desde la carpeta de Terraform:

```bash
cd infrastructure/terraform
terraform init
terraform validate
terraform plan
terraform apply
```

## Base De Conocimiento

Los documentos empresariales se encuentran en:

```txt
knowledge-base/
```

Estos archivos deben cargarse al bucket de documentos creado por Terraform. Luego se debe sincronizar la fuente de datos de Bedrock Knowledge Base para que los documentos sean procesados, fragmentados, convertidos a embeddings e indexados.

## Seguridad

El proyecto contempla:

- Autenticacion con Cognito.
- API protegida con JWT.
- Buckets S3 privados.
- CloudFront con Origin Access Control para el frontend.
- Roles IAM especificos para Lambda y Bedrock.
- Auditoria con CloudTrail.
- Logs en CloudWatch.

Para una demo inicial, el endpoint `/chat` puede exponerse temporalmente sin JWT. Para una version empresarial, debe mantenerse protegido con Cognito y el frontend debe enviar el token en el header `Authorization`.

## Estado Actual

El proyecto ya cuenta con:

- Interfaz web inicial.
- Lambda funcional para Bedrock y RAG.
- Modulos Terraform para autenticacion, API, IA, frontend y auditoria.
- Documentos de ejemplo para la base de conocimiento.
- Workflow inicial de GitHub Actions.

## Licencia

Proyecto academico/demostrativo para implementar un asistente inteligente empresarial con RAG y agentes sobre AWS.
