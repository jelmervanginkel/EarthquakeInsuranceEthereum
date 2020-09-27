FROM python
MAINTAINER Oraclize "info@oraclize.it"

COPY risk.py /
COPY earthquakes.csv /

RUN pip3 install requests
RUN pip3 install numpy
RUN pip3 install pandas
CMD python ./risk.py