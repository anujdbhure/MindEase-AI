# MindEase AI — CI/CD Pipeline (CCA2)

An AI-powered mental wellness dashboard built with Flask and the Claude API, deployed via a Jenkins CI/CD pipeline on AWS + Minikube.

---

## Project overview

MindEase AI is a single-page wellness dashboard that gives users personalised mood insights, breathing exercises, and evidence-based mental health tips — all powered by the Anthropic Claude API on the frontend.

**Routes:**
| Route | Description |
|-------|-------------|
| `/` | Main dashboard (serves `index.html`) |
| `/health` | Returns `{"status": "ok"}` — used by Kubernetes probes |
| `/about` | About page |

---

## Pipeline stages

| Stage | What happens |
|-------|-------------|
| Checkout | Jenkins pulls the latest code from GitHub |
| Build & Test | Installs dependencies, runs `pytest tests/` |
| Docker Build | Builds image tagged `mindease-ai:v<BUILD_NUMBER>` |
| Push Image | Pushes to Docker Hub using stored Jenkins credentials |
| Deploy to Minikube | Applies `k8s/deployment.yaml` and `k8s/service.yaml` via `kubectl` |
| Verify | Checks pods, deployment, service; prints the app URL |

---

## Jenkins setup on AWS

1. Launch an EC2 instance (Ubuntu 22.04, t2.medium recommended).
2. Install Java, Jenkins, Docker, kubectl, and Minikube.
3. Add the Jenkins user to the `docker` group: `sudo usermod -aG docker jenkins`.
4. In Jenkins → Manage Credentials, add a **Username with Password** credential with ID `dockerhub-credentials`.
5. Create a new Pipeline job, point it at this repository, set the script path to `Jenkinsfile`.

---

## Docker image

```bash
# Build locally
docker build -t YOUR_DOCKERHUB_USERNAME/mindease-ai:latest .

# Run locally
docker run -p 5000:5000 YOUR_DOCKERHUB_USERNAME/mindease-ai:latest
```

---

## Kubernetes on Minikube

```bash
# Start Minikube
minikube start

# Apply manifests
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Check pods
kubectl get pods -l app=mindease

# Get app URL
minikube service mindease-service --url
```

---

## Second pipeline run (code change demo)

To demonstrate a redeployment, edit the greeting in `templates/index.html`:

```html
<!-- Change this line -->
<div class="greeting-main">Good evening, <em>Arjun</em></div>

<!-- To something like -->
<div class="greeting-main">Welcome back, <em>Arjun</em></div>
```

Commit and push, then trigger the pipeline. The new version will be built, tagged with the new build number, pushed, and deployed automatically.

---

## Repository structure

```
mindease-ai/
├── app.py                  Flask application
├── requirements.txt        Python dependencies
├── Dockerfile              Container build instructions
├── Jenkinsfile             CI/CD pipeline definition
├── templates/
│   ├── index.html          Main dashboard (frontend)
│   └── about.html          About page
├── tests/
│   └── test_app.py         pytest test cases
└── k8s/
    ├── deployment.yaml     Kubernetes Deployment
    └── service.yaml        Kubernetes Service (NodePort)
```
