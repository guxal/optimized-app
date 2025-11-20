#!/bin/bash
set -e

echo "Deploying to AWS ECS Production..."
aws ecs update-service \
  --cluster optimized-app-prod \
  --service optimized-app-service \
  --force-new-deployment
