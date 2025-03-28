FROM python:slim
RUN pip install --no-cache-dir rexi
RUN mv /usr/local/bin/rexi /usr/local/bin/rexi_original && \
	echo '#!/bin/sh\n/usr/local/bin/rexi_original -i /etc/passwd' > /usr/local/bin/rexi && \
	chmod +x /usr/local/bin/rexi
