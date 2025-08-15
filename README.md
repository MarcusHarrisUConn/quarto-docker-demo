For instructions on how to reproduce the files in this repo, use this link: https://github.com/MarcusHarrisUConn/quarto-docker-demo/blob/main/Instructions.md

# Quarto Docker Demo

A minimal, reproducible R + Quarto workflow packaged in Docker. Run RStudio Server in your browser, render to HTML/PDF, and share the exact environment across Windows, macOS, and Linux.

---

## 🚀 Quick Start (Prebuilt Image — No Build Needed)

### Prereqs
- Install & start **Docker Desktop** (whale icon running).
- Internet connection (first pull only).

### Steps (Windows PowerShell, macOS, or Linux Terminal)

1. Open a terminal (PowerShell on Windows, Terminal on macOS/Linux).  
2. Run:

   ```bash
   docker run -d -p 8787:8787 -e PASSWORD=pass123 --name rstudio-demo marcusharrisuconn/quarto-docker-demo:latest
   ```

3. Visit <http://localhost:8787>  
   **Username:** `rstudio` **Password:** `pass123`

> **Note:** This quick run **does not save work to your computer**. Anything you create stays inside the container. To save to your machine, see “Mount your project folder” below.

---

## 📂 What Does “Mounting Your Project Folder” Mean?

Mounting links a folder on *your computer* to a folder *inside the container*.  
Result: anything you save in `/home/rstudio/project` (inside RStudio) is actually saved to your local disk.

### Why mount?
- Keep outputs, .Rds files, rendered PDFs/HTML, etc. on your computer.
- Avoid losing work when you remove the container.

### How to mount

**Stop & remove the quick-start container first (if running):**

```bash
docker stop rstudio-demo
docker rm rstudio-demo
```

Now, from **inside your project folder** (the one with your `.qmd` file), run **one** of these (pick your shell):

**macOS / Linux (bash/zsh):**
```bash
docker run -d -p 8787:8787 -e PASSWORD=pass123 \
  -v "$(pwd):/home/rstudio/project" \
  --name rstudio-demo \
  marcusharrisuconn/quarto-docker-demo:latest
```

**Windows PowerShell:**
```powershell
docker run -d -p 8787:8787 -e PASSWORD=pass123 `
  -v "${PWD}:/home/rstudio/project" `
  --name rstudio-demo `
  marcusharrisuconn/quarto-docker-demo:latest
```

**Windows CMD:**
```cmd
docker run -d -p 8787:8787 -e PASSWORD=pass123 -v "%cd%:/home/rstudio/project" --name rstudio-demo marcusharrisuconn/quarto-docker-demo:latest
```

Open <http://localhost:8787>, log in, and go to **/home/rstudio/project**. You should see your repo files. Anything you save there shows up on your host machine.

---

## 🛠 Build the Image Yourself (From This Repo)

If you want to build (rather than pull) the image:

```bash
git clone https://github.com/MarcusHarrisUConn/quarto-docker-demo.git
cd quarto-docker-demo
docker build -t quarto-docker-demo .
```

Run it with mounting (pick your shell syntax from above, just swap the image name):

```bash
docker run -d -p 8787:8787 -e PASSWORD=pass123 \
  -v "$(pwd):/home/rstudio/project" \
  --name rstudio-demo \
  quarto-docker-demo
```

---

## 📁 Repository Contents

- `quarto-docker-demo.qmd` — Example Quarto doc using `mtcars`
- `quarto-docker-demo.html` / `.pdf` — Rendered outputs
- `Dockerfile` — Builds the RStudio + Quarto + TinyTeX environment
- `.dockerignore` / `.gitignore` — Keep junk out of the image/repo
- *(Optional)* `renv.lock` — Pin package versions if you add `renv`

---

## 🔄 Reproducibility & Versioning Tips

- Freeze an image for a paper/release:
  ```bash
  docker tag quarto-docker-demo marcusharrisuconn/quarto-docker-demo:v0.1
  docker push marcusharrisuconn/quarto-docker-demo:v0.1
  ```
- Keep code/data evolving in GitHub; rebuild/push the image only when the **environment** (packages/system deps) changes.

---

## 🧹 Stop / Remove Containers & Images

```bash
docker stop rstudio-demo
docker rm rstudio-demo
```

Free space by removing the image:

```bash
docker rmi quarto-docker-demo
```

---

## 📦 Requirements

- Docker Desktop (WSL2 backend on Windows)
- macOS (Intel or Apple Silicon), Windows 10/11, or Linux
- Internet for first-time builds/pulls

---

## 🔧 Maintainer Notes: Update the DockerHub Image

Only the image owner/collaborators need this. Regular users just `docker pull`.

```bash
docker login
docker build -t quarto-docker-demo .
docker tag quarto-docker-demo marcusharrisuconn/quarto-docker-demo:latest
docker push marcusharrisuconn/quarto-docker-demo:latest
```


## 🙌 Credits

Created by Marcus Harris (UConn) to demonstrate a reproducible Quarto + R workflow using Docker.

