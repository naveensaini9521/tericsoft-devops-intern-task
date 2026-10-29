# Tericsoft DevOps Internship Task — Containerized App Deployment

A small static portfolio web app packaged in Docker and deployed on AWS EC2.
Nginx listens on port **8081 inside the container**, and Docker publishes the
same port on the EC2 host. SSH is moved to a **custom port (2222)** as required
by the task. The same image is also deployed on **ECS (Fargate)** as the bonus.

## Architecture

Browser → EC2 public IPv4:8081 → EC2 security group → Docker port mapping
`8081:8081` → Nginx container → `index.html`

SSH → EC2 public IPv4:2222 → EC2 security group → sshd (custom port)

Bonus: ECR image → ECS Fargate service → task on port 8081

## Instance specs and justification

- **Instance type:** `t3.micro`
- **vCPU:** 2
- **RAM:** 1 GiB
- **Disk:** 8 GiB gp3 EBS (default root volume)
- **OS:** Ubuntu Server 24.04 LTS

**Why this size:** The app is a static HTML page served by Nginx. Nginx uses a
few MB of RAM and negligible CPU at this load, so 1 GiB RAM and 2 burstable
vCPUs are more than sufficient. `t3.micro` is free-tier eligible and keeps cost
near zero. The 8 GiB gp3 root volume holds the OS, Docker, and the small image.

## Files

- `index.html` — static portfolio page
- `Dockerfile` — builds the Nginx image serving the page on 8081
- `default.conf` — Nginx config listening on 8081
- `.dockerignore` — excludes unnecessary files from the build context

## Run locally

Requirements: Docker installed.

```bash
docker build -t tericsoft-devops-app:1.0 .
docker run --rm -p 8081:8081 tericsoft-devops-app:1.0
```
