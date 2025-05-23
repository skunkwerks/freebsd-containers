# destination registries
REGISTRIES?=	cr.skunkwerks.at
		# freebsd \
		# ghcr.io/freebsd


# RELEASES
# https://download.freebsd.org/releases/OCI-IMAGES/14.3-BETA2/aarch64/Latest/
# https://download.freebsd.org/releases/OCI-IMAGES/14.3-BETA2/amd64/Latest/
BASE?=	https://download.freebsd.org/releases/OCI-IMAGES
# SNAPSHOTS
# https://download.freebsd.org/snapshots/OCI-IMAGES/15.0-CURRENT/aarch64/Latest/
# https://download.freebsd.org/snapshots/OCI-IMAGES/15.0-CURRENT/amd64/Latest/
BASE?=	https://download.freebsd.org/releases/OCI-IMAGES
BASE?=	https://download.freebsd.org/snapshots/OCI-IMAGES

# flavours
FLAVOURS?=	static dynamic runtime
# tags
# TAGS?=		14.2 14.2p0 \
# 		14.3-beta2 \
# 		14.snap 14.snap20250415190046 \
# 		15.snap 15.snap20250424035343
TAGS?=	14.3-beta4

.PHONY: export import push

import:
.for tag in ${TAGS}
.for flav in ${FLAVOURS}
# SNAPDATE_${tag}${flav}!=	eval $$(podman run -it --rm -v /usr/local/sbin/pkg-static:/bin/pkg-static oci-archive:FreeBSD-${tag:tu}-amd64-container-image-${flav}.txz pkg-static query %v FreeBSD-caroot 2>/dev/null | egrep -o '^[0-9]+\.snap[0-9]+')
	curl -s -O -O \
		${BASE}/${tag:tu}/aarch64/Latest/FreeBSD-${tag:tu}-arm64-aarch64-container-image-${flav}.txz \
		${BASE}/${tag:tu}/amd64/Latest/FreeBSD-${tag:tu}-amd64-container-image-${flav}.txz
	./podmanic FreeBSD-${tag:tu}-arm64-aarch64-container-image-${flav}.txz \
		FreeBSD-${tag:tu}-amd64-container-image-${flav}.txz \
		freebsd-${flav}:${tag:tl:C/[0-9]+-(stable|current)/snap/}
.endfor
.endfor

export:
.for tag in ${TAGS}
.for flav in ${FLAVOURS}
	podman save --format oci-archive --output \
		freebsd-${flav}-${tag:tl:C/[0-9]+-(stable|current)/snap/}.oci \
		localhost/freebsd-${flav}:${tag:tl:C/[0-9]+-(stable|current)/snap/}
.endfor
.endfor

push:
.for reg in ${REGISTRIES}
.for tag in ${TAGS}
.for flav in ${FLAVOURS}
	skopeo copy --multi-arch=all \
		oci-archive:freebsd-${flav}-${tag:tl:C/[0-9]+-(stable|current)/snap/}.oci \
		docker://${reg}/freebsd-${flav}:${tag:tl:C/[0-9]+-(stable|current)/snap/}
.endfor
.endfor
.endfor
