FROM frolvlad/alpine-python3
MAINTAINER Oraclize "info@oraclize.it"

COPY claim.py /

RUN pip3 install requests
CMD python ./claim.py