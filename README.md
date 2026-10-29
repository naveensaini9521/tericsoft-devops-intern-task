# Tericsoft DevOps Internship Task — Containerized App Deployment

A small static web app packaged in Docker and deployed on AWS EC2. Nginx listens on port **8081 inside the container**, and Docker publishes the same port on the EC2 host.

## Architecture

Browser → EC2 public IPv4 address:8081 → EC2 security group → Docker port mapping `8081:8081` → Nginx container → `index.html`

## Files

- `index.html` — sample web page
- `Dockerfile` — builds the container image
- `default.conf` — configures Nginx to listen on port 8081
- `.dockerignore` — excludes unnecessary files from the build context

## Run locally

Requirements: Docker installed.

```bash
docker build -t tericsoft-devops-app:1.0 .
docker run --rm -p 8081:8081 tericsoft-devops-app:1.0
```

Open <http://localhost:8081>.

## Deploy on AWS EC2 (Ubuntu)

### 1. Launch the instance

In the AWS EC2 console, launch an Ubuntu Server 24.04 LTS instance. Select an instance type that your account is eligible to use at an acceptable cost. For this simple static site, a small instance is sufficient; check the selected instance's vCPU, RAM, and disk details in the console and mention the actual values in your recording.

Create or select an SSH key pair. In the security group, allow:

- SSH TCP 22 from **your own public IP**.
- Custom TCP 8081 from `0.0.0.0/0` so the public can view the demo over IPv4.

Do not open SSH to the whole internet. Public HTTP on port 8081 is intentionally exposed for this assignment. AWS charges can apply; review pricing and clean up resources after the demo.

### 2. Connect to EC2

From your local machine, set the downloaded key file permissions and connect (replace the placeholders):

```bash
chmod 400 /path/to/your-key.pem
ssh -i /path/to/your-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
```

### 3. Install Docker

On the EC2 instance:

```bash
sudo apt-get update
sudo apt-get install -y docker.io git
sudo systemctl enable --now docker
sudo docker --version
sudo docker run --rm hello-world
```

The `hello-world` container verifies that Docker can pull and run an image. Use `sudo docker` for the following commands unless you deliberately configure Docker group access.

### 4. Clone the repository and start the app

After you have pushed this project to your public GitHub repository:

```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/tericsoft-devops-intern-task.git
cd tericsoft-devops-intern-task
sudo docker build -t tericsoft-devops-app:1.0 .
sudo docker run -d --name tericsoft-app --restart unless-stopped -p 8081:8081 tericsoft-devops-app:1.0
```

If you are building directly on EC2 before publishing the repository, transfer the project files or create them on the server first.

### 5. Verify the deployment

On EC2:

```bash
sudo docker ps
sudo docker logs tericsoft-app
curl -I http://localhost:8081
```

From your local browser, open:

```text
http://YOUR_EC2_PUBLIC_IP:8081
```

Use the instance's **public IPv4 address**, not its private IP. If the page does not load, verify the container is running, Nginx is listening on port 8081, Docker maps `8081:8081`, and the security group permits inbound TCP 8081. Also check any host firewall rules if you enabled a firewall.

### Useful container commands

```bash
sudo docker ps
sudo docker logs tericsoft-app
sudo docker restart tericsoft-app
sudo docker stop tericsoft-app
sudo docker rm tericsoft-app
```

## Push to GitHub

Create an empty **public** GitHub repository named `tericsoft-devops-intern-task` (do not initialize it with a README if you are pushing this README). From the project directory:

```bash
git init
git add index.html Dockerfile default.conf .dockerignore README.md
git commit -m "Add Dockerized web app for Tericsoft DevOps task"
git branch -M main
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/tericsoft-devops-intern-task.git
git push -u origin main
```

Replace `YOUR_GITHUB_USERNAME` with your username. Confirm the public repository URL opens in a private/incognito browser window.

## Loom recording checklist

- Show the EC2 instance and the actual vCPU, RAM, and disk specs.
- Explain why you chose a small instance for a simple static page.
- Show Docker version and the running container.
- Open the public URL `http://YOUR_EC2_PUBLIC_IP:8081` in a browser.
- Show the public GitHub repository and briefly explain the Dockerfile and port mapping.
- Explain real issues you encountered and how you fixed them. Do not claim issues you did not encounter.

## Cleanup after the assessment

First remove the container if desired:

```bash
sudo docker rm -f tericsoft-app
```

Then stop or terminate the EC2 instance in the AWS console. **Stopping an instance does not necessarily stop all charges** (for example, EBS storage and allocated public IPv4 resources may still incur charges). Delete resources you no longer need, after confirming you do not need them.

## Optional ECS bonus

The assignment's ECS deployment is a bonus. It generally involves building the same image, pushing it to Amazon ECR, creating an ECS task definition and service, configuring networking, and verifying a running task. Check current AWS pricing before attempting it.
