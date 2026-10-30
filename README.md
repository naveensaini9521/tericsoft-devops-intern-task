# Tericsoft DevOps Internship Task: Containerized App Deployment

A static portfolio web application packaged in Docker and deployed on AWS EC2. Nginx serves the app on port `8081` inside the container, and Docker publishes the same port on the EC2 host. SSH is configured on custom port `2222`. The optional bonus deployment stores the image in Amazon ECR and runs it on Amazon ECS with AWS Fargate.

## Live URLs

| Deployment | URL |
|---|---|
| EC2 | http://32.236.41.107:8081 |
| ECS Fargate (bonus) | http://16.176.28.186:8081 |

> **Note:** These URLs work only while the corresponding AWS resources are running, have the correct public IPs, and allow inbound traffic on port 8081. If the deployments have been shut down to avoid ongoing costs, the links will not respond.

## Table of Contents

- [Architecture](#architecture)
- [Instance Specifications](#instance-specifications)
- [Project Files](#project-files)
- [Run Locally](#run-locally)
- [Amazon ECR: Build and Push the Image](#amazon-ecr-build-and-push-the-image)
- [Bonus: Amazon ECS with AWS Fargate](#bonus-amazon-ecs-with-aws-fargate)
- [Security Group Configuration](#security-group-configuration)
- [Challenges and Resolutions](#challenges-and-resolutions)
- [Cleanup and Cost Management](#cleanup-and-cost-management)
- [Submission Checklist](#submission-checklist)

## Architecture

**EC2 deployment**

```
Browser → EC2 public IPv4:8081 → EC2 security group → Docker port mapping (8081:8081) → Nginx container → index.html
```

**SSH access**

```
SSH client → EC2 public IPv4:2222 → EC2 security group → SSH daemon (sshd)
```

**Bonus: ECS Fargate**

```
Amazon ECR image → ECS task definition → ECS service → Fargate task → Public IP:8081
```

## Instance Specifications

| Specification | Configuration |
|---|---|
| Instance type | t3.micro |
| vCPU | 2 |
| RAM | 1 GiB |
| Root disk | 8 GiB gp3 EBS |
| Operating system | Ubuntu Server 24.04 LTS |
| AWS Region | ap-southeast-2 (Sydney) |

**Why this configuration?** The application is a lightweight static HTML site served by Nginx. A `t3.micro` provides enough resources for a basic demonstration, and the 8 GiB root volume holds the OS, Docker, and the application image. The instance was chosen to keep resource usage and cost low. Free-tier eligibility and charges depend on the AWS account, current offers, and usage.

## Project Files

| File | Description |
|---|---|
| `index.html` | Static portfolio webpage |
| `Dockerfile` | Builds the Docker image for the application |
| `default.conf` | Nginx configuration listening on port 8081 |
| `.dockerignore` | Excludes unnecessary files from the Docker build context |

## Run Locally

**Requirements:** Docker installed and running.

```bash
docker build -t tericsoft-portfolio:latest .
docker run --rm -p 8081:8081 tericsoft-portfolio:latest
```

Open http://localhost:8081 in your browser. Stop the container with `Ctrl+C`.

## Amazon ECR: Build and Push the Image

The Docker image is stored in Amazon Elastic Container Registry (ECR) for reuse by EC2 and ECS.

| Setting | Value |
|---|---|
| AWS Region | `ap-southeast-2` |
| Repository | `tericsoft-portfolio` |

**1. Authenticate** (using locally configured AWS CLI credentials):

```bash
aws ecr get-login-password --region ap-southeast-2 \
  | docker login \
      --username AWS \
      --password-stdin \
      875068569132.dkr.ecr.ap-southeast-2.amazonaws.com
```

**2. Create the repository** (only if it does not already exist):

```bash
aws ecr create-repository \
  --repository-name tericsoft-portfolio \
  --region ap-southeast-2
```

**3. Build, tag, and push:**

```bash
docker build -t tericsoft-portfolio:latest .

docker tag tericsoft-portfolio:latest \
  875068569132.dkr.ecr.ap-southeast-2.amazonaws.com/tericsoft-portfolio:latest

docker push \
  875068569132.dkr.ecr.ap-southeast-2.amazonaws.com/tericsoft-portfolio:latest
```

**4. Verify the upload:**

```bash
aws ecr describe-images \
  --repository-name tericsoft-portfolio \
  --region ap-southeast-2 \
  --output table
```

> **Security:** Never commit AWS access keys, secret keys, credentials, or local AWS configuration files to GitHub.

## Bonus: Amazon ECS with AWS Fargate

The bonus deployment uses Amazon ECR as the image registry and Amazon ECS with Fargate as the container runtime.

| Setting | Configuration |
|---|---|
| Cluster | `tericsoft-cluster` |
| Task definition family | `tericsoft-task` |
| Service | `tericsoft-service` |
| Compute | AWS Fargate |
| Task CPU | 0.25 vCPU |
| Task memory | 0.5 GB |
| Container port | 8081 |
| Public access | Public IP and security-group access configured as required |

The ECS task definition references the image in ECR, and the service maintains the desired number of running tasks. For browser access, the task must be running, have a reachable public IP or suitable network path, and allow inbound traffic on port 8081.

> **Important:** The configuration above documents the intended deployment. Verify the current ECS service, running task, image URI, and public IP in the AWS Console before treating the bonus deployment as operational.

## Security Group Configuration

Configure inbound rules on the relevant EC2 instance or ECS task security group:

| Port | Protocol | Purpose |
|---|---|---|
| 2222 | TCP | SSH administration on EC2 |
| 8081 | TCP | Web application access |

- Restrict SSH access to your own IP address where possible.
- For a public demonstration, allow HTTP traffic on port 8081 only as needed.
- On EC2, verify that `sshd` is actually listening on port 2222 before removing access on port 22.
- ECS Fargate does not use the EC2 instance's SSH configuration.

## Challenges and Resolutions

| Challenge | Resolution |
|---|---|
| **SSH connectivity:** initial connection attempts failed. | Checked the instance's public IP, SSH credentials, network reachability, and security-group rules. |
| **Custom SSH port:** the task requires SSH on port 2222. | Updated and tested both the SSH daemon configuration and the inbound security-group rule. |
| **ECR permissions:** repository creation and image operations can fail without the right IAM permissions. | Checked the IAM permissions and ECR authentication configuration. |
| **Docker image availability:** a container cannot start from an image that is missing locally or cannot be pulled from ECR. | Used Docker image tags and ECR image verification to troubleshoot. |
| **Public application access:** a container can respond locally while being unreachable externally. | Checked the container port mapping, public IP, and inbound security-group rules for port 8081. |
| **ECS deployment:** tasks need a valid image reference, suitable task execution permissions, and correct networking. | Checked the ECR image, task configuration, task status, and port access. |

## Cleanup and Cost Management

AWS resources may incur charges while running. After the review:

- Stop or terminate the EC2 instance.
- Remove unused ECS services, Fargate tasks, load balancers, and other chargeable resources.
- Remember that ECR images and storage may also incur charges.

If the live deployments are stopped before review, update the [Live URLs](#live-urls) section to explain that the resources have been shut down to avoid ongoing costs.

## Submission Checklist

- [ ] Public GitHub repository contains the source code, Dockerfile, Nginx configuration, `.dockerignore`, and README
- [ ] EC2 application is reachable at the published URL
- [ ] ECR image upload is verified
- [ ] ECS Fargate deployment is verified (if claiming the bonus)
- [ ] Loom recording shows your face and screen, instance specifications, the working application, the public GitHub repository, and the ECS console if attempted
- [ ] Submission includes the Loom URL, GitHub repository URL, and the required 5–6 line problem-and-resolution note
