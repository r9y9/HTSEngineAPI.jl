using BinDeps
using Compat

@BinDeps.setup

hts_engine = library_dependency("libhts_engine_API",
                                aliases=["libhts_engine_API", "hts_engine_API-1"])

const libhts_engine_API_version = "1.0.9"

github_root = "https://github.com/r9y9/hts_engine_API"
arch = WORD_SIZE == 64 ? "x86_64" : "i686"
major = libhts_engine_API_version[1]

provides(Sources,
         URI("$(github_root)/archive/v$(libhts_engine_API_version).tar.gz"),
         hts_engine,
         unpacked_dir="hts_engine_API-$(libhts_engine_API_version)")

prefix = joinpath(BinDeps.depsdir(hts_engine), "usr")
srcdir = joinpath(BinDeps.depsdir(hts_engine), "src",
                  "hts_engine_API-$(libhts_engine_API_version)")

provides(SimpleBuild,
          (@build_steps begin
              GetSources(hts_engine)
              @build_steps begin
                  ChangeDirectory(srcdir)
                  `./waf configure --prefix=$prefix`
                  `./waf build`
                  `./waf install`
              end
           end), hts_engine, os = :Unix)

@BinDeps.install @compat Dict(:libhts_engine_API => :libhts_engine_API)
