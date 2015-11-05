using HTSEngine
using Base.Test

using WAV

### Data ###

mei_htsvoice = joinpath(dirname(@__FILE__), "data", "mei_normal.htsvoice")
labelpath = joinpath(dirname(@__FILE__), "data","nitech_jp_atr503_m001_a01.lab")

### Tests ###

function test_hts_engine_synthesis_funcs()
    engine = HTS_Engine(mei_htsvoice)

    # From filepath
    synthesize_from_fn(engine, labelpath)

    synthesized_fn = get_generated_speech(engine)
    refresh(engine)

    # From file contents (lines)
    open(labelpath) do f
        synthesize_from_strings(engine, readlines(f))
    end
    synthesized_strings = get_generated_speech(engine)

    # should be same
    @test synthesized_fn == synthesized_strings
end

function test_hts_engine_fullcontext_label()
    engine = HTS_Engine(mei_htsvoice)
    @test get_fullcontext_label_format(engine) == "HTS_TTS_JPN"
    @test get_fullcontext_label_version(engine) == "1.0"
end

function test_hts_engine_save()
    engine = HTS_Engine(mei_htsvoice)
    synthesize_from_fn(engine, labelpath)

    for savefunc in [
                 save_information,
                 save_label,
                 save_generated_speech,
                 save_riff]
        file = tempname()
        savefunc(engine, file)
        @test isfile(file)
        rm(file)
    end

    clear(engine)
end

function test_hts_engine_synthesis_and_save_wav()
    # Load htsvoice
    engine = HTS_Engine(mei_htsvoice)
    @test get_sampling_frequency(engine) == 48000
    @test get_fperiod(engine) == 240

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

    # get generated waveform
    synthesized = get_generated_speech(engine)
    synthesized = map(Int, map(trunc, synthesized))
    synthesized = map(x -> clamp(x, typemin(Int16), typemax(Int16)), synthesized)

    # check sample-by-sample correctess
    @test all(x .== synthesized)
end

### Run tests ###

info("test: hts_engine synthesis functions")
test_hts_engine_synthesis_funcs()

info("test: hts_engine fullcontext label")
test_hts_engine_fullcontext_label()

info("test: hts_engine save")
test_hts_engine_save()

info("test: hts_engine syntheis and save to wav")
test_hts_engine_synthesis_and_save_wav()
