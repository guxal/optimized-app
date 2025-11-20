#!/bin/bash
set -e

echo "Deploying to AWS ECS Staging..."
aws ecs update-service \
  --cluster optimized-app-staging \
  --service optimized-app-service \
  --force-new-deployment
