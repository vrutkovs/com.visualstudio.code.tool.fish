all: prepare-repo install-deps build clean-cache update-repo copy-to-export

prepare-repo:
	[[ -d repo ]] || ostree init --mode=archive-z2 --repo=repo
	[[ -d repo/refs/remotes ]] || mkdir -p repo/refs/remotes && touch repo/refs/remotes/.gitkeep

install-deps:
	flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak --user install -y flathub org.freedesktop.Platform//20.08 org.freedesktop.Sdk//20.08 com.visualstudio.code-oss//stable || true

build:
	flatpak-builder --force-clean --ccache --require-changes --repo=repo \
		--subject="Fish, `date`" \
		${EXPORT_ARGS} app com.visualstudio.code.tool.fish.yml

clean-cache:
	rm -rf .flatpak-builder/build

update-repo:
	flatpak build-update-repo --prune --prune-depth=20 --generate-static-deltas repo
	rm -rf repo/.lock

copy-to-export:
	rm -rf export && mkdir export
	cp -rf repo/ export/
