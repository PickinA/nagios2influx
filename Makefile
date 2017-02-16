NAME=		nagios2influx
VERSION=	1.0
RELEASE=	00

RPM=		${HOME}/rpmbuild/RPMS/x86_64/${NAME}-${VERSION}-${RELEASE}.el7.x86_64.rpm
DEB=		${NAME}-${VERSION}-${RELEASE}.deb

BUILD=		${NAME}-${VERSION}-${RELEASE}
DEBIAN=		${BUILD}/DEBIAN
SPEC=		${NAME}.spec
TMPL=		${NAME}.tmpl

all:	deb rpm

clean:
	@rm -rf ${SPEC} ${RPM} ${DEB} nagios2influx.1.gz nagios2influx.cfg.5.gz ${BUILD}

${RPM}: ${SPEC}
	@echo "Building ${NAME} rpm ..."
	@rm -f ${RPM}
	@rpmbuild -bb ${SPEC}

${SPEC}:	${TMPL} ${MAKEFILE}
	@sed -s 's/__NAME__/${NAME}/g;s/__RELEASE__/${RELEASE}/g;s/__VERSION__/${VERSION}/g;' ${TMPL} > ${SPEC}
rpm:	${RPM}
deb:	${DEB}

install:
	@pod2man nagios2influx | gzip > /usr/share/man/man1/nagios2influx.1.gz
	@pod2man --section 5 nagios2influx.cfg.pod | gzip > /usr/share/man/man5/nagios2influx.cfg.5.gz
	@install -m 0755 nagios-perf /usr/bin
	@install -m 0755 nagios2influx /usr/bin
	@install -m 0640 nagios2influx.cfg /etc/nagios

${BUILD}:
	@mkdir -p ${NAME}-${VERSION}-${RELEASE}

${DEBIAN}: ${BUILD}
	@mkdir -p ${DEBIAN}

${DEB}:	${DEBIAN} control nagios2influx.cfg nagios2influx.cfg.pod nagios2influx
	@sed -s 's/__NAME__/${NAME}/g;s/__RELEASE__/${RELEASE}/g;s/__VERSION__/${VERSION}/g;' control > ${DEBIAN}/control
	@echo /etc/nagios/nagios2influx.cfg > ${DEBIAN}/conffiles
	@mkdir -p ${BUILD}/usr/bin ${BUILD}/etc/nagios ${BUILD}/usr/share/man/man1 ${BUILD}/usr/share/man/man5
	@install -m 0755 nagios-perf ${BUILD}/usr/bin
	@install -m 0755 nagios2influx ${BUILD}/usr/bin
	@install -m 0640 nagios2influx.cfg ${BUILD}/etc/nagios
	@pod2man nagios2influx | gzip > ${BUILD}/usr/share/man/man1/nagios2influx.1.gz
	@pod2man --section 5 nagios2influx.cfg.pod | gzip > ${BUILD}/usr/share/man/man5/nagios2influx.cfg.5.gz
	@dpkg-deb --build ${BUILD}
	@rm -rf ${BUILD}
