# destination registries
REGISTRIES?=	cr.skunkwerks.at \
		ghcr.io/skunkwerks \
		skunkwerks

# flavours
FLAVOURS=	static dynamic minimal
# tags
TAGS=		14.2 14.2p0 \
		14.snap 14.snap20250415190046 \
		15.snap 15.snap20250415180349

.PHONY: push

push:
.for reg in ${REGISTRIES}
.for tag in ${TAGS}
.for flav in ${FLAVOURS}
	skopeo copy --multi-arch=all oci-archive:freebsd-${flav}-${tag}.oci \
		docker://${reg}/freebsd-${flav}:${tag}
.endfor
.endfor
.endfor
