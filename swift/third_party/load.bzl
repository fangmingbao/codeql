load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

# TODO: remove `remove-result-of.patch` once we update to a Swift version containing
# https://github.com/apple/swift/commit/2ed2cea2
# (probably when updating to 5.9)
_swift_prebuilt_version = "swift-5.8.1-RELEASE.210"
_swift_sha_map = {
    "Linux-X64": "d8c715044c3989683b3f986a377647697245ed6bbdc2add13890433c9dc732a4",
    "macOS-ARM64": "2ca169f299bce61034bd011f081a55be07a19f20fd7ea855b241f43fe0fb76d2",
    "macOS-X64": "80e2e8cefbd78d71e54923c1da36cac3511b4c69c4841cf35bef383bc6750d18",
}

_swift_arch_map = {
    "Linux-X64": "linux",
    "macOS-X64": "darwin_x86_64",
}

def _github_archive(*, name, repository, commit, build_file = None, sha256 = None):
    github_name = repository[repository.index("/") + 1:]
    maybe(
        repo_rule = http_archive,
        name = name,
        url = "https://github.com/%s/archive/%s.zip" % (repository, commit),
        strip_prefix = "%s-%s" % (github_name, commit),
        build_file = build_file,
        sha256 = sha256,
    )

def _build(workspace_name, package):
    return "@%s//swift/third_party:BUILD.%s.bazel" % (workspace_name, package)

def load_dependencies(workspace_name):
    for repo_arch, arch in _swift_arch_map.items():
        sha256 = _swift_sha_map[repo_arch]

        http_archive(
            name = "swift_prebuilt_%s" % arch,
            url = "https://github.com/dsp-testing/codeql-swift-artifacts/releases/download/%s/swift-prebuilt-%s.zip" % (
                _swift_prebuilt_version,
                repo_arch,
            ),
            build_file = _build(workspace_name, "swift-llvm-support"),
            sha256 = sha256,
            patch_args = ["-p1"],
            patches = [
                "@%s//swift/third_party/swift-llvm-support:patches/%s.patch" % (workspace_name, patch_name)
                for patch_name in (
                    "remove-result-of",
                    "remove-redundant-operators",
                    "add-constructor-to-Compilation",
                )
            ],
        )

    _github_archive(
        name = "picosha2",
        build_file = _build(workspace_name, "picosha2"),
        repository = "okdshin/PicoSHA2",
        commit = "27fcf6979298949e8a462e16d09a0351c18fcaf2",
        sha256 = "d6647ca45a8b7bdaf027ecb68d041b22a899a0218b7206dee755c558a2725abb",
    )

    _github_archive(
        name = "binlog",
        build_file = _build(workspace_name, "binlog"),
        repository = "morganstanley/binlog",
        commit = "3fef8846f5ef98e64211e7982c2ead67e0b185a6",
        sha256 = "f5c61d90a6eff341bf91771f2f465be391fd85397023e1b391c17214f9cbd045",
    )

    _github_archive(
        name = "absl",
        repository = "abseil/abseil-cpp",
        commit = "d2c5297a3c3948de765100cb7e5cccca1210d23c",
        sha256 = "735a9efc673f30b3212bfd57f38d5deb152b543e35cd58b412d1363b15242049",
    )

    _github_archive(
        name = "json",
        repository = "nlohmann/json",
        commit = "6af826d0bdb55e4b69e3ad817576745335f243ca",
        sha256 = "702bb0231a5e21c0374230fed86c8ae3d07ee50f34ffd420e7f8249854b7d85b",
    )

    _github_archive(
        name = "fmt",
        repository = "fmtlib/fmt",
        build_file = _build(workspace_name, "fmt"),
        commit = "a0b8a92e3d1532361c2f7feb63babc5c18d00ef2",
        sha256 = "ccf872fd4aa9ab3d030d62cffcb258ca27f021b2023a0244b2cf476f984be955",
    )
