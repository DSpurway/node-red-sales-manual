FROM cunlifs/ubuntu:v0.5
RUN useradd -m -l -d /usr/src/node-red -u 1000730033 -g 0 nodered -p abc1234
COPY sales_manual_finder.py /usr/src/node-red/sales_manual_finder.py
COPY sales_manual_product_lifecycle_extractor.py /usr/src/node-red/sales_manual_product_lifecycle_extractor.py
COPY sales-manual-reader-flow.json /usr/src/node-red/sales-manual-reader-flow.json
COPY package.json /usr/src/node-red/package.json

ENV http_proxy http://9.196.156.29:3128
ENV https_proxy http://9.196.156.29:3128

# Db2 client support
RUN npm install ibm_db
RUN apt-get update && apt-get install -y numactl gnupg2 wget locales

# Ensure that we always use UTF-8 and with GB English locale, as the Python scripts had coding issues
RUN locale-gen en_GB.UTF-8

ENV LC_ALL=en_GB.UTF-8
ENV LANG=en_GB.UTF-8
ENV LANGUAGE=en_GB.UTF-8

# install libibmc++
RUN wget -q http://public.dhe.ibm.com/software/server/POWER/Linux/xl-compiler/eval/ppc64le/ubuntu/public.gpg -O- | apt-key add -
RUN echo "deb http://public.dhe.ibm.com/software/server/POWER/Linux/xl-compiler/eval/ppc64le/ubuntu/ trusty main" | tee /etc/apt/sources.list.d/ibm-xl-compiler-eval.list
RUN apt-get update
#RUN curl -sL http://public.dhe.ibm.com/software/server/POWER/Linux/xl-compiler/eval/ppc64le/ubuntu/public.gpg
RUN apt-get install -y xlc.16.1.1

EXPOSE 1880/tcp
RUN chmod 750 /usr/src/node-red/sales-manual-reader-flow.json
##RUN chown -R node-red:node-red /usr/src/node-red
RUN chmod 777 /usr/src/node-red

RUN python3 -m venv /usr/src/node-red/venv --system-site-packages
#RUN useradd -m -l -d /home/nodered -u 1000730033 -g 0 nodered -p abc1234

#install Watson service nodes and dashdb clinet for Db2
RUN npm install -g --unsafe-perm node-red-nodes-cf-sqldb-dashdb

USER nodered
ENV HOME /usr/src/node-red
WORKDIR /usr/src/node-red
#CMD sleep 60000
#CMD node-red /usr/src/node-red/sales-manual-reader-flow.json
CMD node-red
