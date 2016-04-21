FROM java:8-jdk

ENV PATH /usr/local/tomee/bin:$PATH
RUN mkdir -p /usr/local/tomee

WORKDIR /usr/local/tomee

# curl -fsSL 'https://www.apache.org/dist/tomee/KEYS' | awk -F ' = ' '$1 ~ /^ +Key fingerprint$/ { gsub(" ", "", $2); print $2 }' | sort -u
ENV GPG_KEYS \
	223D3A74B068ECA354DC385CE126833F9CF64915 \
	7A2744A8A9AAF063C23EB7868EBE7DBE8D050EEF \
	82D8419BA697F0E7FB85916EE91287822FDB81B1 \
	9056B710F1E332780DE7AF34CBAEBE39A46C4CA1 \
	A57DAF81C1B69921F4BA8723A8DE0A4DB863A7C1 \
	B7574789F5018690043E6DD9C212662E12F3E1DD \
	B8B301E6105DF628076BD92C5483E55897ABD9B9 \
	DBCCD103B8B24F86FFAAB025C8BB472CD297D428 \
	F067B8140F5DD80E1D3B5D92318242FE9A0B1183 \
	FAA603D58B1BA4EDF65896D0ED340E0E6D545F97
RUN set -xe \
	&& for key in $GPG_KEYS; do \
		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	done

RUN set -x \
	&& curl -fSL https://dist.apache.org/repos/dist/release/tomee/tomee-1.7.3/apache-tomee-1.7.3-jaxrs.tar.gz.asc -o tomee.tar.gz.asc \
	&& curl -fSL http://apache.rediris.es/tomee/tomee-1.7.3/apache-tomee-1.7.3-jaxrs.tar.gz -o tomee.tar.gz \
	&& gpg --batch --verify tomee.tar.gz.asc tomee.tar.gz \
	&& tar -zxf tomee.tar.gz \
	&& mv apache-tomee-jaxrs-1.7.3/* /usr/local/tomee \
	&& rm -Rf apache-tomee-jaxrs-1.7.3 \
	&& rm bin/*.bat \
	&& rm tomee.tar.gz* \
  && rm -rf /usr/local/tomee/webapps \
  && mkdir /usr/local/tomee/webapps \
  && rm -rf /usr/local/tomee/lib/slf4j-jdk14-1.7.7.jar

RUN apt-get update \
    && apt-get -q -y install netcat \
    && apt-get -q -y install less \
    && apt-get -q -y install vim

EXPOSE 8080 8000
# run with default jpda debug values for debugging from the IDE


COPY ./lib /usr/local/tomee/lib/

COPY ./entrypoint.sh /
# contains the check for a linked and named DB:3306
ENTRYPOINT ["/entrypoint.sh"]

CMD ["catalina.sh","jpda","run"]

