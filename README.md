# Quarto Docker Demo

This project demonstrates how to create a reproducible RStudio and Quarto environment using Docker.

## 🔧 Project Overview

This repo includes:
- A `Dockerfile` to create an RStudio + Quarto environment
- A sample Quarto document (`quarto-docker-demo.qmd`)
- Rendered outputs: HTML and PDF
- Project-specific packages tracked via `renv`
- A `.dockerignore` and `.gitignore` to manage what gets built and committed

## 🐳 Option 1: Run Pre-Built Docker Image (Fastest)

If you have [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed, run this in your terminal:

docker run -e PASSWORD=pass123 -p 8787:8787 marcusharrisuconn/quarto-docker-demo

Then visit: [http://localhost:8787](http://localhost:8787)  
Login credentials:
- Username: `rstudio`
- Password: `pass123`

You’ll find the project under `/home/rstudio`.

## 🛠 Option 2: Build the Image Yourself (From This Repo)

git clone https://github.com/MarcusHarrisUConn/quarto-docker-demo.git
cd quarto-docker-demo
docker build -t quarto-docker-demo .
docker run -e PASSWORD=pass123 -p 8787:8787 -v "${PWD}:/home/rstudio/project" --name rstudio-container quarto-docker-demo


## 🧪 Repository Contents

- `quarto-docker-demo.qmd`: Source Quarto doc using example data
- `quarto-docker-demo.pdf` / `.html`: Rendered outputs
- `renv.lock`: Package versions
- `.dockerignore`, `.gitignore`: Clean up what gets copied or committed
- `Dockerfile`: Builds the containerized RStudio + Quarto environment

## 💡 Reproducibility Notes

This project uses:
- `rocker/rstudio` as the base image
- Quarto installed in the image
- R packages installed via `renv` and `install.packages()`
- Outputs generated with `quarto render`

To ensure complete reproducibility, version tags can be used for the Docker image and all packages are pinned using `renv.lock`.

## 📦 Requirements

- Docker (Desktop or CLI)
- macOS (Intel or Apple Silicon), Windows, or Linux

## 🔁 Updating the DockerHub Image

docker login
docker tag quarto-docker-demo marcusharrisuconn/quarto-docker-demo
docker push marcusharrisuconn/quarto-docker-demo


## 🤝 Credits

Created by Marcus Harris, UConn  
For demonstrating reproducible R and Quarto workflows using Docker.
