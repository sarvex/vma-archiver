#!/usr/bin/env bash

java -jar -Dapplication.schema.host=${VMA_SCHEMA_REGISTRY} -Dapplication.postgres.host=jofisaes-vma-haproxy-lb -Dspring.profiles.active=${VMA_BACKEND_PROFILE} -Dserver.port="${VMA_PORT}" vma-service-backend.jar
