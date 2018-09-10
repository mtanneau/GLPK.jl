using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, String["libglpk"], :libglpk),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/juan-pablo-vielma/GLPKBuilder/releases/download/v4.64-beta"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, :glibc) => ("$bin_prefix/GLPKBuilder.v4.64.0.aarch64-linux-gnu.tar.gz", "d9b337aa792809693cf33f6389247725e892fa876fa30d4ed18754e239883a00"),
    Linux(:aarch64, :musl) => ("$bin_prefix/GLPKBuilder.v4.64.0.aarch64-linux-musl.tar.gz", "5a32347c79f6073c71b3a6d55ce33d8bcf3d62f3610cac1c40dff0b6139441e8"),
    Linux(:armv7l, :glibc, :eabihf) => ("$bin_prefix/GLPKBuilder.v4.64.0.arm-linux-gnueabihf.tar.gz", "4a571d0277e81d1a5f3b2bc68b70a4c8e158e8eb7bcf0b15b6e17901d7b7a37b"),
    Linux(:armv7l, :musl, :eabihf) => ("$bin_prefix/GLPKBuilder.v4.64.0.arm-linux-musleabihf.tar.gz", "f3ff358e43df5306e2302b7db7bbb7301ef8ff5775f69ac8176c82348635655b"),
    Linux(:i686, :glibc) => ("$bin_prefix/GLPKBuilder.v4.64.0.i686-linux-gnu.tar.gz", "40d7d4beb0c53ef76128c60a251ed88ad92c0e3167efbd5cf4a70c8f95f333ec"),
    Linux(:i686, :musl) => ("$bin_prefix/GLPKBuilder.v4.64.0.i686-linux-musl.tar.gz", "f63768f7cba97f28ae052bd701816ba2931ad6c1f9c0f97039261ba33d1dc193"),
    Windows(:i686) => ("$bin_prefix/GLPKBuilder.v4.64.0.i686-w64-mingw32.tar.gz", "1716e6e1cd35344589d554e8b9b91312af4a54adb2a43b2043ee6e500d0adb3f"),
    Linux(:powerpc64le, :glibc) => ("$bin_prefix/GLPKBuilder.v4.64.0.powerpc64le-linux-gnu.tar.gz", "cc4ecc96c0ee6f8a554616e5bda71107dca6278b9e70c8d0de372b161f54864c"),
    MacOS(:x86_64) => ("$bin_prefix/GLPKBuilder.v4.64.0.x86_64-apple-darwin14.tar.gz", "0ed3bbd5fe510d37873ec45ce307c6136ad4a4dde7c4bf29a468a5ffbdeaa476"),
    Linux(:x86_64, :glibc) => ("$bin_prefix/GLPKBuilder.v4.64.0.x86_64-linux-gnu.tar.gz", "1e92c8e934593a49c2ee974dac7dcaba13c4b39e848f5bd1b1f9e7b8388740de"),
    Linux(:x86_64, :musl) => ("$bin_prefix/GLPKBuilder.v4.64.0.x86_64-linux-musl.tar.gz", "c0aa4263ff46d3b2c402566d7caf1651501ab568f32e19479b2c9409a560eb48"),
    Windows(:x86_64) => ("$bin_prefix/GLPKBuilder.v4.64.0.x86_64-w64-mingw32.tar.gz", "e3e36b766a115e111c819f6da5a6c42ab0634fda788613555e4562c2f932fbc0"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    # Check if this build.jl is providing new versions of the binaries, and
    # if so, ovewrite the current binaries even if they were installed by the user 
    if unsatisfied || !isinstalled(url, tarball_hash; prefix=prefix) 
        # Download and install binaries
        evalfile("build_GMP.v6.1.2.jl")  # We do not check for already installed GMP libraries
        install(url, tarball_hash; prefix=prefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform $(triplet(platform_key())) is not supported by this package!")
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)

