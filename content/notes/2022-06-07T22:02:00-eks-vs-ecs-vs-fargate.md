---
title: EKS vs ECS vs Fargate
date: 2022-06-07T22:02:00Z
slug: eks-vs-ecs-vs-fargate
tags:
- aws
- cloud native
- containers
---

tldr; ECS is just AWS's proprietary orchestration solution. EKS is their kubernetes
service - you don't have to manage the kubernetes control plane (don't have
access to master node, but you do get the kubernetes API). Fargate can be used
with ECS or EKS and basically abstracts away the compute nodes on which
containers run.

- https://cast.ai/blog/aws-eks-vs-ecs-vs-fargate-where-to-manage-your-kubernetes
- https://aws.amazon.com/blogs/containers/the-role-of-aws-fargate-in-the-container-world

