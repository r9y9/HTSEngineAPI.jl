using HTSEngine
using Base.Test

using WAV

mei_htsvoice = joinpath(dirname(@__FILE__), "data", "mei_normal.htsvoice")
labelpath = joinpath(dirname(@__FILE__), "data", "nitech_jp_atr503_m001_a01.lab")

function test_hts_engine_basics()
    # Load htsvoice
    engine = HTS_Engine(mei_htsvoice)
    @test get_sampling_frequency(engine) == 48000

    # Synthesize waveform from label file
    synthesize_from_fn(engine, labelpath)

    # Save as wav file
    file = tempname()
    save_riff(engine, file)
    @test isfile(file)

    # Load wavfile
    x, fs = wavread(file, format="native")
    @test fs == get_sampling_frequency(engine)
    rm(file)

    @test length(x) == get_nsamples(engine)

    # check sample-by-sample correctess
    for i in 1:get_nsamples(engine)
        value_in_engine = trunc(Int, get_generated_speech(engine, i-1))
        value_in_engine = clamp(value_in_engine, typemin(Int16), typemax(Int16))
        value_in_wav = x[i]
        @test value_in_wav == value_in_engine
    end
end

info("test hts_engine basics")
test_hts_engine_basics()
