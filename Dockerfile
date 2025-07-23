FROM rocker/rstudio:4.3.1

# Install Quarto CLI
RUN wget https://quarto.org/download/latest/quarto-linux-amd64.deb && \
    apt-get update && \
    apt-get install -y ./quarto-linux-amd64.deb && \
    rm quarto-linux-amd64.deb

# Install R packages
RUN R -e "install.packages(c('datasets', 'tinytex'))" && \
    R -e "tinytex::install_tinytex()"

# Set RStudio login password
ENV PASSWORD=pass123
