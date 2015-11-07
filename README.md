# HTSEngineAPI

[![Build Status](https://travis-ci.org/r9y9/HTSEngineAPI.jl.svg?branch=master)](https://travis-ci.org/r9y9/HTSEngineAPI.jl)
[![Coverage Status](https://coveralls.io/repos/r9y9/HTSEngineAPI.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/r9y9/HTSEngineAPI.jl?branch=master)


HTSEngineAPI is a wrapper of [hts_engine_API](http://hts-engine.sourceforge.net/) that provides speech waveform synthesis from Hidden Markov Models (HMMs) trained by the [HMM-based speech synthesis system (HTS)](http://hts.sp.nitech.ac.jp/).

The package is designed to be minimum and API-consistent to the hts_engine_API. Function `HTS_engine_xxx` in hts_engine_API can be accessed as `xxx` (without `HTS_Engine` prefix) in HTSEngineAPI.

**NOTE**: This wrapper is based on a modified version of hts_engine_API [(r9y9/hts_engine_API)](https://github.com/r9y9/hts_engine_API).

## Installation

```jl
Pkg.clone("https://github.com/r9y9/HTSEngineAPI.jl")
Pkg.build("HTSEngineAPI")
```

## A minimum example

```jl
using HTSEngineAPI

# Setup engine
engine = HTS_Engine("your_hts_voice_path")

# Synthesis
synthesize_from_fn(engine, "your_fullcontext_label_path")

# Get waveform
synthesized = get_generated_speech(engine)

# Save to wav file
save_riff(engine, "synthesized.wav")
```

## @htscall

For now `HTS_Engine_xxx` are only wrapped in Julia, however, you can call any function in libhts_engine_API with @htscall.

e.g.

```jl
using HTSEngineAPI

engine = HTS_Engine("your_hts_voice_path")
synthesize_from_fn(engine, "your_fullcontext_label_path")

# Get number of generated samples directly from GStream
nsamples = @htscall(:HTS_GStreamSet_get_total_nsamples, Csize_t,
                   (Ptr{HTS_GStreamSet},), &engine.gss))
```
