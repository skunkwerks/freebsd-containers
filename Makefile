# destination registries
REGISTRIES?=	cr.skunkwerks.at \
		ghcr.io/skunkwerks \
		skunkwerks

# flavours
FLAVOURS?=	static dynamic runtime
# tags
TAGS?=		14.2 14.2p0 \
		14.3-prerelease \
		14.snap 14.snap20250415190046 \
		15.snap 15.snap20250424035343

.PHONY: export push

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
