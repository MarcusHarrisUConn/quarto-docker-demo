# End-to-End Reproducible Workflow: Quarto + GitHub + Docker + DockerHub

*(For social science grad students new to coding)*

------------------------------------------------------------------------

## 0. Prerequisites (Install These First)

1.  **GitHub account** – <https://github.com/join>\
2.  **Git** – <https://git-scm.com/downloads>\
3.  **R** – <https://cran.r-project.org/>\
4.  **RStudio Desktop** – <https://posit.co/download/rstudio-desktop/>\
5.  **Quarto CLI** (if you plan to render locally): <https://quarto.org/docs/get-started/>\
6.  **Docker Desktop** – <https://www.docker.com/products/docker-desktop/>
    -   Windows: enable **WSL2 backend** during install\
    -   macOS: choose Intel vs Apple Silicon download appropriately\
7.  (Optional but recommended) **DockerHub account** – <https://hub.docker.com/>

------------------------------------------------------------------------

## 1. Create a New Quarto Project in RStudio (Windows or Mac)

1.  Open **RStudio** → `File > New Project > New Directory > Quarto Project`.\

2.  Name it (e.g., `quarto-docker-demo`) and choose a folder location you remember.\

3.  Check **“Create a Git repository”** (if offered).\

4.  Click **Create Project**.\

5.  Open the `.qmd` file (e.g., `quarto-docker-demo.qmd`).\

6.  Add a code chunk to test (example using the built-in `mtcars` dataset):

    ```` markdown
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

    \`\`\`

7.  Click **Render**. Confirm both `.html` and `.pdf` render without errors.

------------------------------------------------------------------------

## 2. Initialize Git & Push to GitHub

1.  In RStudio, open the **Git** tab (upper-right pane).\

2.  Click **Commit**, select all files, write a message (e.g., “Initial commit”), and commit.\

3.  On GitHub, create a **new empty repo** (no README) with the same name.\

4.  In RStudio’s **Terminal** (or external terminal), run:

    ``` bash
    git remote add origin https://github.com/<YOUR_USERNAME/<REPO_NAME>.git
    git branch -M main
    git push -u origin main
    ```

5.  Refresh your GitHub repo page to confirm files are there.

------------------------------------------------------------------------

## 3. Add a Dockerfile (Defines the Exact Computing Environment)

1.  In RStudio: `File > New File > Text File`, paste:

    ``` dockerfile
    FROM rocker/rstudio:4.3.1

    # Install Quarto CLI
    RUN wget https://quarto.org/download/latest/quarto-linux-amd64.deb && \
        apt-get update && \
        apt-get install -y ./quarto-linux-amd64.deb && \
        rm quarto-linux-amd64.deb

    # Install needed R packages (add more as needed)
    RUN R -e "install.packages(c('datasets', 'tinytex'))" && \
        R -e "tinytex::install_tinytex()"
    ```

2.  Save as **`Dockerfile`** (no extension) in the project root.\

3.  (Optional) Create `.dockerignore` to shrink image size:

    ```         
    .Rproj.user
    .Rhistory
    .RData
    _quarto
    *.pdf
    *.html
    ```

4.  Commit & push these changes (`Git` tab → Commit → Push).

------------------------------------------------------------------------

## 4. Build the Docker Image Locally (Windows PowerShell / macOS Terminal)

1.  Open a terminal and `cd` into your project folder:

    ``` bash
    cd path/to/quarto-docker-demo
    ```

2.  Build the image:

    ``` bash
    docker build -t quarto-docker-demo .
    ```

    -   First build can take several minutes.\
    -   Success message ends with: “Successfully tagged quarto-docker-demo:latest”.

------------------------------------------------------------------------

## 5. Run RStudio Server in Docker (Quick Test, No Mounting)

1.  Run the container:

    ``` bash
    docker run -d -p 8787:8787 -e PASSWORD=pass123 --name rstudio-demo quarto-docker-demo
    ```

2.  Open your browser: <http://localhost:8787>

    -   **Username:** `rstudio`\
    -   **Password:** `pass123`\

3.  You’re now in RStudio Server inside Docker.

> **Note:** Nothing you save here will persist on your computer unless you “mount” a folder. See next step.

------------------------------------------------------------------------

## 6. Mount Your Project Folder (So Work Saves to Your Machine)

**Stop & remove the old container first:**

``` bash
docker stop rstudio-demo
docker rm rstudio-demo
```

Then, from *inside your project folder*, run ONE of these (depending on your shell):

-   **macOS / Linux (bash/zsh):**

    ``` bash
    docker run -d -p 8787:8787 -e PASSWORD=pass123 \
      -v "$(pwd):/home/rstudio/project" \
      --name rstudio-demo \
      quarto-docker-demo
    ```

-   **Windows PowerShell:**

    ``` powershell
    docker run -d -p 8787:8787 -e PASSWORD=pass123 `
      -v "${PWD}:/home/rstudio/project" `
      --name rstudio-demo `
      quarto-docker-demo
    ```

-   **Windows CMD:**

    ``` cmd
    docker run -d -p 8787:8787 -e PASSWORD=pass123 -v "%cd%:/home/rstudio/project" --name rstudio-demo quarto-docker-demo
    ```

Now go to <http://localhost:8787> → open **/home/rstudio/project**.\
Anything you save there appears in your local folder.

------------------------------------------------------------------------

## 7. Create & Push a DockerHub Image (Optional but Recommended for Sharing)

1.  Log in to DockerHub in your terminal:

    ``` bash
    docker login
    ```

2.  Tag your local image for DockerHub (replace `<USER>`):

    ``` bash
    docker tag quarto-docker-demo <USER>/quarto-docker-demo:latest
    ```

3.  Push it:

    ``` bash
    docker push <USER>/quarto-docker-demo:latest
    ```

4.  Share the run command with collaborators:

    ``` bash
    docker run -d -p 8787:8787 -e PASSWORD=pass123 \
      --name rstudio-demo \
      <USER>/quarto-docker-demo:latest
    ```

> Only you (or collaborators you add on DockerHub) can push updates to `<USER>/quarto-docker-demo`. Others can pull/run it or build their own from your GitHub repo.

------------------------------------------------------------------------

## 8. Routine Workflow After Setup

1.  **Edit code/documents locally** in RStudio Desktop (or inside RStudio Server with mounting).\
2.  **Render** your Quarto files to ensure they work.\
3.  **Commit & push to GitHub** frequently.\
4.  **Rebuild & push the Docker image** **only** if the environment changes (new packages, system dependencies).
    -   Tag releases (e.g., `:v0.1`) if you want a frozen snapshot for a paper.

------------------------------------------------------------------------

## 9. Common Maintenance Commands

``` bash
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

------------------------------------------------------------------------

## 10. Troubleshooting Tips

-   **Port 8787 already in use?** Stop other containers: `docker ps` → `docker stop <id>`\
-   **“permission denied” on Windows mounts?** In Docker Desktop: Settings → Resources → File Sharing → add your drive/folder.\
-   **WSL errors on Windows?** Update WSL: `wsl --update` (PowerShell as admin)\
-   **PDF render fails inside container?** Ensure TinyTeX installed (already in Dockerfile).\
-   **Slow DockerHub upload?** Check network or use a `.dockerignore` to shrink context.

------------------------------------------------------------------------

## 11. (Optional) Maintainer Notes: Update the DockerHub Image

Only needed if *you* maintain the image.

``` bash
docker login
docker build -t quarto-docker-demo .
docker tag quarto-docker-demo <USER>/quarto-docker-demo:latest
docker push <USER>/quarto-docker-demo:latest
```

(Replace `<USER>` with your DockerHub username.)

------------------------------------------------------------------------

## 12. License & Citation

Add a `LICENSE` (MIT, CC-BY, etc.) and `CITATION.cff` if you want others to cite this project.

------------------------------------------------------------------------

## 13. You Did It 🎉

You now have: - A Quarto project under version control (GitHub) - A fully reproducible environment (Dockerfile / DockerHub image) - A browser-based RStudio that runs identically on any OS - A workflow your collaborators can follow without “it works on my machine” issues

Happy researching!
