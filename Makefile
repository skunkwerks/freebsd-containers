# destination registries
REGISTRIES?=	freebsd \
		ghcr.io/freebsd

# flavours
FLAVOURS?=	static dynamic runtime
# tags
TAGS?=		14.2 14.2p0 \
		14.3-beta2 \
		14.snap 14.snap20250415190046 \
		15.snap 15.snap20250424035343

OCIBASE?=	https://download.freebsd.org/releases/OCI-IMAGES/14.3-BETA2

.PHONY: export import push

import:
.for tag in ${TAGS}
.for flav in ${FLAVOURS}
curl -sLO ${OCIBASE}/aarch64/Latest/FreeBSD-${TAG:tu}-arm64-aarch64-container-image-${flav}.txz
curl -sLO ${OCIBASE}/amd64/Latest/FreeBSD-${TAG:tu}-amd64-container-image-${flav}.txz
.endfor
.for flav in ${FLAVOURS}
	./podmanic FreeBSD-${TAG:tu}-arm64-aarch64-container-image-${TAG}.txz \
		FreeBSD-${TAG}-amd64-container-image-$t.txz \
		freebsd-$t-${TAG}
.endfor
.endfor

export:
.for tag in ${TAGS}
.for flav in ${FLAVOURS}
	podman save --format oci-archive --output \
		freebsd-${flav}-${tag}.oci \
		localhost/freebsd-${flav}:${tag}
.endfor
.endfor

push:
.for reg in ${REGISTRIES}
.for tag in ${TAGS}
.for flav in ${FLAVOURS}
	skopeo copy --multi-arch=all \
		oci-archive:freebsd-${flav}-${tag}.oci \
		docker://${reg}/freebsd-${flav}:${tag}
.endfor
.endfor
.endfor
