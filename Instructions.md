# End-to-End Reproducible Workflow: Quarto + GitHub + Docker + DockerHub

*(For social science grad students new to coding)*

---

## Why These Tools?

- **Quarto** → Next-generation reproducible document system. Write one `.qmd` and output HTML, PDF, Word, slides. Keeps code + text + output together.  
- **GitHub** → Tracks every change (version control) and makes collaboration transparent. Perfect for papers, dissertations, or shared projects.  
- **Docker** → Freezes the *computing environment*. Instead of “it worked on my laptop,” Docker guarantees the same R, Quarto, and packages run for everyone.  
- **DockerHub** → Like GitHub, but for Docker images. Lets you share a ready-to-run RStudio+Quarto environment without anyone installing R or LaTeX locally.  

---

## 0. Prerequisites (Install These First)

1. **GitHub account** – <https://github.com/join>  
2. **Git** – <https://git-scm.com/downloads>  
3. **R** – <https://cran.r-project.org/>  
4. **RStudio Desktop** – <https://posit.co/download/rstudio-desktop/>  
5. **Quarto CLI** (if you plan to render locally): <https://quarto.org/docs/get-started/>  
6. **Docker Desktop** – <https://www.docker.com/products/docker-desktop/>  
   - Windows: enable **WSL2 backend** during install  
   - macOS: choose Intel vs Apple Silicon download appropriately  
7. (Optional but recommended) **DockerHub account** – <https://hub.docker.com/>  

---

## 0a. Install & Configure Git

- Install Git:  
  - Windows: <https://git-scm.com/download/win>  
  - Mac: <https://git-scm.com/download/mac>  

- Confirm installation in terminal:  
  ```bash
  git --version
  ```

- Configure your name & email (this shows up in commits):  
  ```bash
  git config --global user.name "Your Name"
  git config --global user.email "your@email.com"
  ```

---

## 0b. Connect RStudio to GitHub

1. In RStudio: **Tools → Global Options → Git/SVN → Browse** to your Git executable.  
2. Restart RStudio; the **Git tab** should appear in your projects.  

---

## 0c. Authentication: HTTPS vs SSH (How to Log In to GitHub)

When you connect your project to GitHub, you have two main ways for your computer to authenticate:

---

### 🔹 Option 1: HTTPS (easiest to start, works well with browser login)
- Your GitHub repo URL looks like:  
  `https://github.com/USERNAME/REPO.git`

- If you have **2-Factor Authentication (2FA)** turned on in GitHub, you cannot just use your password.  
  Instead you need a **Personal Access Token (PAT)** (basically a long password string).  

Steps:
1. Go to GitHub → Settings → Developer Settings → Personal Access Tokens → Generate new token.  
   - Give it a name (e.g., "RStudio").  
   - Select **repo** scope.  
   - Copy the token (keep it secret).  

2. In RStudio or terminal, when Git asks for your GitHub password, paste the token instead.  

✅ Pros: Simple to set up, works on Windows and Mac.  
⚠️ Cons: You may need to manage tokens and re-enter them sometimes.

---

### 🔹 Option 2: SSH (recommended long-term, smoother once set up)
- Your GitHub repo URL looks like:  
  `git@github.com:USERNAME/REPO.git`

- You generate a **keypair** (like a secure ID card).  
  - **Private key** (stays on your computer).  
  - **Public key** (you upload to GitHub).  

Steps (do this once per computer):

1. **Generate a keypair**  
   In terminal (Mac/Linux/Windows PowerShell):  
   ```bash
   ssh-keygen -t ed25519 -C "your@email.com"
   ```  
   - Replace `your@email.com` with the email you use for GitHub.  
   - Press Enter to accept defaults.  
   - A private key (`id_ed25519`) and public key (`id_ed25519.pub`) are created in your `~/.ssh` folder.

2. **Copy the public key**  
   - Mac:  
     ```bash
     pbcopy < ~/.ssh/id_ed25519.pub
     ```  
   - Windows PowerShell:  
     ```powershell
     Get-Content $env:USERPROFILE\.ssh\id_ed25519.pub | clip
     ```  

3. **Add to GitHub**  
   - Go to GitHub → Settings → SSH and GPG Keys → New SSH Key.  
   - Paste the key you copied.  

4. **Test it**  
   ```bash
   ssh -T git@github.com
   ```  
   You should see: *“Hi USERNAME! You’ve successfully authenticated...”*

✅ Pros: No need to enter tokens each time; works seamlessly once set up.  
⚠️ Cons: Slightly more setup up front.

---

### ❓ FAQ

- **Do I type literally `your@email.com`?** → No, replace it with the email linked to your GitHub account.  
- **Is this related to RStudio?** → Indirectly. RStudio uses Git under the hood. GitHub authentication is about Git, not RStudio itself.  
- **Do I need to do this every time?** → No. Once per computer is enough. Each machine gets its own unique keypair.  
- **Why was it easier on Windows?** → On Windows, RStudio often defaults to HTTPS (browser login). On Mac/Linux, SSH is often the default, so you need to set up keys.  


---

## 1. Create a New Quarto Project in RStudio (Windows or Mac)

1. Open **RStudio** → `File > New Project > New Directory > Quarto Project`.  
2. Name it (e.g., `quarto-docker-demo`) and choose a folder location you remember.  
3. Check **“Create a Git repository”** (if offered).  
4. Click **Create Project**.  
5. Open the `.qmd` file (e.g., `quarto-docker-demo.qmd`).  
6. Add a code chunk to test (example using the built-in `mtcars` dataset):  

    ````markdown
    ---
    title: "Quarto Docker Demo"
    format:
      html: default
      pdf: default
    ---

    ```{r}
       summary(mtcars)
    ```
    ````

7. Click **Render**. Confirm both `.html` and `.pdf` render without errors.  

> 💡 For PDF rendering outside Docker, you need LaTeX installed locally. The easiest way:  
> - In R:  
>   ```r
>   install.packages("tinytex")
>   tinytex::install_tinytex()
>   ```  
> - Or on Windows only: install MiKTeX (<https://miktex.org/download>).  
> Inside Docker, TinyTeX is already installed.  

---

## 2. Initialize Git & Push to GitHub

1. In RStudio, open the **Git** tab (upper-right pane).  
2. Click **Commit**, select all files, write a message (e.g., “Initial commit”), and commit.  
3. On GitHub, create a **new empty repo** (no README) with the same name.  
4. In RStudio’s **Terminal** (or external terminal), run:  

    ```bash
    git remote add origin https://github.com/<YOUR_USERNAME>/<REPO_NAME>.git
    git branch -M main
    git push -u origin main
    ```

5. Refresh your GitHub repo page to confirm files are there.  

---

## 3. Add a Dockerfile (Defines the Exact Computing Environment)

1. In RStudio: `File > New File > Text File`, paste:  

    ```dockerfile
    # Base: RStudio Server + R 4.3.1
    FROM rocker/rstudio:4.3.1

    # Install tools: wget, gdebi (for .deb), git
    RUN apt-get update && apt-get install -y --no-install-recommends           wget           gdebi-core           git      && rm -rf /var/lib/apt/lists/*

    # Install Quarto CLI
    RUN wget -qO /tmp/quarto.deb https://quarto.org/download/latest/quarto-linux-amd64.deb      && gdebi -n /tmp/quarto.deb      && rm -f /tmp/quarto.deb

    # (Optional) Install TinyTeX for PDF rendering (non-interactive)
    # If this fails transiently, the "|| true" prevents the whole build from breaking.
    RUN quarto install tinytex --update-path no || true

    # (Optional) R packages you want available globally
    RUN R -q -e "install.packages('tinytex', repos='https://cloud.r-project.org')"

    # Clone your repo into the image (snapshot at build time)
    RUN git clone https://github.com/<YOUR_USERNAME>/<REPO_NAME>.git /home/rstudio/project      && chown -R rstudio:rstudio /home/rstudio/project

    # Work from the project directory by default
    WORKDIR /home/rstudio/project
    ```

2. Save as **`Dockerfile`** (no extension) in the project root.  
3. (Optional) Create `.dockerignore` to shrink image size:  

    ```
    .Rproj.user
    .Rhistory
    .RData
    _quarto
    *.pdf
    *.html
    ```

4. Commit & push these changes (`Git` tab → Commit → Push).  

---

## 4. Build the Docker Image Locally (Windows PowerShell / macOS Terminal)

```bash
cd path/to/quarto-docker-demo
docker build -t quarto-docker-demo .
```

- First build can take several minutes.  
- Success message ends with: `Successfully tagged quarto-docker-demo:latest`.  

---

## 5. Run RStudio Server in Docker (Quick Test)

```bash
docker run -d -p 8787:8787 -e PASSWORD=pass123 --name rstudio-demo quarto-docker-demo
```

Open <http://localhost:8787> →  
- Username: `rstudio`  
- Password: `pass123`  

> ⚠️ Files are already cloned from GitHub into the image. If you edit inside this container, changes **will not sync back** to your computer unless you commit/push inside the container.  

---

## 6. Mount Your Project Folder (Recommended for Active Work)

Stop & remove the old container:

```bash
docker stop rstudio-demo
docker rm rstudio-demo
```

From *inside your project folder*, run ONE of these:

- **macOS / Linux (bash/zsh):**
  ```bash
  docker run -d -p 8787:8787 -e PASSWORD=pass123     -v "$(pwd):/home/rstudio/project"     --name rstudio-demo     quarto-docker-demo
  ```

- **Windows PowerShell:**
  ```powershell
  docker run -d -p 8787:8787 -e PASSWORD=pass123 `
    -v "${PWD}:/home/rstudio/project" `
    --name rstudio-demo `
    quarto-docker-demo
  ```

- **Windows CMD:**
  ```cmd
  docker run -d -p 8787:8787 -e PASSWORD=pass123 -v "%cd%:/home/rstudio/project" --name rstudio-demo quarto-docker-demo
  ```

Now go to <http://localhost:8787> → open `/home/rstudio/project`.  
Anything you save there appears in your local folder.  

---

## 7. Create & Push a DockerHub Image (Optional but Recommended for Sharing)

```bash
docker login
docker tag quarto-docker-demo <USER>/quarto-docker-demo:latest
docker push <USER>/quarto-docker-demo:latest
```

Collaborators can pull/run it with:

```bash
docker run -d -p 8787:8787 -e PASSWORD=pass123   --name rstudio-demo   <USER>/quarto-docker-demo:latest
```

---

## 8. Routine Workflow After Setup

1. Edit code/documents locally (or inside RStudio Server with mounting).  
2. Render your Quarto files.  
3. Commit & push to GitHub frequently.  
4. Rebuild & push the Docker image **only** if the environment changes (new packages, system dependencies).  
   - Tag releases (e.g., `:v0.1`) for frozen snapshots.  

---

## 9. Common Maintenance Commands

```bash
# List containers
docker ps -a

# Stop/remove a container
docker stop rstudio-demo
docker rm rstudio-demo

# Remove image (frees disk space)
docker rmi quarto-docker-demo

# Prune stopped containers/images
docker system prune
```

---

## 10. Troubleshooting Tips

- **Port 8787 already in use?** → `docker ps` → `docker stop <id>`  
- **Permission denied on Windows mounts?** → Docker Desktop: Settings → Resources → File Sharing → add your drive/folder.  
- **WSL errors on Windows?** → `wsl --update` (PowerShell as admin).  
- **PDF render fails inside container?** → Ensure TinyTeX is installed (Dockerfile already includes it).  
- **Slow DockerHub upload?** → Use a `.dockerignore` to shrink build context.  

---

## 11. (Optional) Maintainer Notes: Update the DockerHub Image

```bash
docker login
docker build -t quarto-docker-demo .
docker tag quarto-docker-demo <USER>/quarto-docker-demo:latest
docker push <USER>/quarto-docker-demo:latest
```

---

## 12. License & Citation

Add a `LICENSE` (MIT, CC-BY, etc.) and `CITATION.cff` if you want others to cite this project.  

---

## 13. You Did It 🎉

You now have:  
- A Quarto project under version control (GitHub)  
- A fully reproducible environment (Dockerfile / DockerHub image)  
- A browser-based RStudio that runs identically on any OS  
- A workflow your collaborators can follow without “it works on my machine” issues  

Happy researching!
