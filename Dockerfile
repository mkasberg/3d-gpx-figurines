FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    apt-transport-https \
    wget \
    git \
    ruby-dev \
    build-essential \
    fnt

RUN fnt update && fnt install roboto && fnt install robotomono

# We need OpenSCAD Nightly for faster builds:
# https://ochafik.com/jekyll/update/2022/02/09/openscad-fast-csg-contibution.html

# Install OpenSCAD GPG Key
RUN wget -qO- https://files.openscad.org/OBS-Repository-Key.pub | tee /etc/apt/trusted.gpg.d/obs-openscad-nightly.asc
# Add OpenSCAD Nightly Repo
RUN echo "deb https://download.opensuse.org/repositories/home:/t-paul/xUbuntu_22.04/ ./" > /etc/apt/sources.list.d/openscad.list
RUN apt-get update && apt-get install -y openscad-nightly

RUN gem install bundler -v 2.4.13
