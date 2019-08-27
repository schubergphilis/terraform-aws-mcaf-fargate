[
  {
    "name": "app-${name}",
    "image": "${image}",
    "cpu": ${cpu},
    "memory": ${memory},
    "networkMode": "awsvpc",
    "environment": ${environment},
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${log_group}",
          "awslogs-region": "${region}",
          "awslogs-stream-prefix": "ecs"
        }
    },
    "portMappings": [
      {
        "containerPort": ${port},
        "hostPort": ${port}
      }
    ]
  }
]
