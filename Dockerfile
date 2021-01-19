FROM cunlifs/ubuntu:v0.5
 
#ENV http_proxy http://9.196.156.29:3128
#ENV https_proxy http://9.196.156.29:3128
ENV http_proxy http://9.196.148.19:3128
ENV https_proxy http://9.196.148.19:3128

COPY package.json /usr/src/node-red/package.json

# Db2 client support
RUN npm install ibm_db

# runtime support to enable npm build capabilities
# RUN apt-get install -y numactl
# RUN apt-get install -y gnupg2
# RUN apt-get install -y wget
# RUN apt-get install -y locales
RUN apt-get install -y numactl gnupg2 wget locales

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

RUN python3 -m venv /usr/src/node-red/venv --system-site-packages

#install Watson service nodes and dashdb clinet for Db2
RUN npm install -g --unsafe-perm node-red-nodes-cf-sqldb-dashdb

COPY List_Bond_Films.py /usr/src/node-red/List_Bond_Films.py
COPY List_Bond_Girls.py /usr/src/node-red/List_Bond_Girls.py
COPY bond-film-flow.json /usr/src/node-red/bond-film-flow.json

RUN chmod 750 /usr/src/node-red/bond-film-flow.json
RUN chown -R node-red:node-red /usr/src/node-red

USER node-red

CMD node-red /usr/src/node-red/bond-film-flow.json
