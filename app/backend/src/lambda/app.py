import json
import os
import traceback
from typing import Any, Dict

import boto3

REGION = os.environ.get("REGION", "us-east-1")
MODEL_ID = os.environ.get("MODEL_ID", "anthropic.claude-3-haiku-20240307-v1:0")
KNOWLEDGE_BASE_ID = os.environ.get("KNOWLEDGE_BASE_ID", "")

bedrock_runtime = boto3.client("bedrock-runtime", region_name=REGION)
bedrock_agent_runtime = boto3.client("bedrock-agent-runtime", region_name=REGION)


def _response(status_code: int, body: Dict[str, Any]) -> Dict[str, Any]:
    return {
        "statusCode": status_code,
        "headers": {
            "content-type": "application/json; charset=utf-8",
            "access-control-allow-origin": "*",
            "access-control-allow-headers": "authorization,content-type",
            "access-control-allow-methods": "GET,POST,OPTIONS",
        },
        "body": json.dumps(body, ensure_ascii=False),
    }


def _parse_body(event: Dict[str, Any]) -> Dict[str, Any]:
    raw_body = event.get("body") or "{}"
    if event.get("isBase64Encoded"):
        import base64
        raw_body = base64.b64decode(raw_body).decode("utf-8")
    return json.loads(raw_body)


def _direct_bedrock_answer(message: str) -> str:
    result = bedrock_runtime.converse(
        modelId=MODEL_ID,
        messages=[
            {
                "role": "user",
                "content": [{"text": message}],
            }
        ],
        inferenceConfig={
            "maxTokens": 700,
            "temperature": 0.3,
        },
    )
    return result["output"]["message"]["content"][0]["text"]


def _rag_answer(message: str) -> Dict[str, Any]:
    model_arn = f"arn:aws:bedrock:{REGION}::foundation-model/{MODEL_ID}"

    result = bedrock_agent_runtime.retrieve_and_generate(
        input={"text": message},
        retrieveAndGenerateConfiguration={
            "type": "KNOWLEDGE_BASE",
            "knowledgeBaseConfiguration": {
                "knowledgeBaseId": KNOWLEDGE_BASE_ID,
                "modelArn": model_arn,
                "generationConfiguration": {
                    "promptTemplate": {
                        "textPromptTemplate": """
                Responde únicamente con la respuesta final para el usuario.
                No muestres búsquedas, acciones, herramientas utilizadas ni razonamiento interno.
                Si utilizas documentos de la base de conocimiento, sintetiza la información en lenguaje natural.
                $search_results$
                Pregunta: $query$
                """
                    },
                    "inferenceConfig": {
                        "textInferenceConfig": {
                            "maxTokens": 700,
                            "temperature": 0.3,
                        }
                    },
                },
            },
        },
    )

    citations = []

    for citation in result.get("citations", []):
        for ref in citation.get("retrievedReferences", []):

            location = ref.get("location", {})
            content = ref.get("content", {})

            citations.append({
                "source": location,
                "excerpt": content.get("text", "")
            })

    return {
        "answer": result.get("output", {}).get("text", ""),
        "citations": citations,
    }


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    try:
        route_key = event.get("routeKey", "")

        if route_key == "GET /health":
            return _response(200, {"ok": True, "service": "ati-assistant"})

        if event.get("requestContext", {}).get("http", {}).get("method") == "OPTIONS":
            return _response(200, {"ok": True})

        body = _parse_body(event)
        message = (body.get("message") or "").strip()

        if not message:
            return _response(400, {"error": "Debes enviar un campo 'message'."})

        if KNOWLEDGE_BASE_ID:
            rag = _rag_answer(message)
            print("RAG RESULT:")
            print(json.dumps(rag, ensure_ascii=False))
            
            return _response(200, rag)

        answer = _direct_bedrock_answer(message)
        return _response(200, {"answer": answer, "citations": []})

    except Exception as exc:
        print("ERROR", str(exc))
        print(traceback.format_exc())
        return _response(500, {"error": "Error procesando la solicitud en Lambda."})
