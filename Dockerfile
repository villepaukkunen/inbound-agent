FROM docker.io/jenkins/inbound-agent:3355.v388858a_47b_33-2
USER root
RUN apt-get update && apt-get install -y rsync
RUN HUGO_VERSION=$(curl -sX GET https://raw.githubusercontent.com/gohugoio/hugo/refs/heads/master/hugoreleaser.env | grep HUGORELEASER_TAG | awk -F 'v' '/HUGORELEASER_TAG/{print $2;exit}') && \
    curl -LJO https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb && \
    apt-get install ./hugo_extended_${HUGO_VERSION}_linux-amd64.deb && \
    rm hugo_extended_${HUGO_VERSION}_linux-amd64.deb
USER jenkins