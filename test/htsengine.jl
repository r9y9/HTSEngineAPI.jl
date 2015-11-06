using HTSEngineAPI
using Base.Test

using WAV

### Data ###

mei_htsvoice = joinpath(dirname(@__FILE__), "data", "mei_normal.htsvoice")
labelpath = joinpath(dirname(@__FILE__), "data","nitech_jp_atr503_m001_a01.lab")

### Tests ###

function test_hts_engine_properties()
    engine = HTSEngine()

    for (name, val) in [
                        (:sampling_frequency, 48000),
                        (:fperiod, 240),
                        (:audio_buff_size, 10),
                        (:stop_flag, false),
                        (:volume, 2.0),
                        (:alpha, 0.42),
                        (:beta, 0.01)
                       ]
        setter = eval(symbol(:set_, name))
        getter = eval(symbol(:get_, name))
        println("test setter/getter property: $name")

        setter(engine, val)
        @test_approx_eq getter(engine) val
    end

    # no throws
    set_speed(engine, 0.7)
    set_phoneme_alignment_flag(engine, false)
    add_half_tone(engine, 0.5)

    engine = HTSEngine(mei_htsvoice)

    for stream_index in 1:get_nstream(engine)
        for (name, val) in [
                            (:msd_threshold, 0.5),
                            (:gv_weight, 0.5)
                            ]
            setter = eval(symbol(:set_, name))
            getter = eval(symbol(:get_, name))
            println("test setter/getter property: $name")

            setter(engine, stream_index, val)
            @test_approx_eq getter(engine, stream_index) val
        end
    end

    for voice_index in 1:get_nvoices(engine)
        for (name, val) in [
                            (:duration_interpolation_weight, 0.5)
                            ]
            setter = eval(symbol(:set_, name))
            getter = eval(symbol(:get_, name))
            println("test setter/getter property: $name")

            setter(engine, voice_index, val)
            @test_approx_eq getter(engine, voice_index) val
        end
    end

    for voice_index in 1:get_nvoices(engine)
        for stream_index in 1:get_nstream(engine)
            for (name, val) in [
                                (:parameter_interpolation_weight, 0.5),
                                (:gv_interpolation_weight, 0.5)
                                ]
                setter = eval(symbol(:set_, name))
                getter = eval(symbol(:get_, name))
                println("test setter/getter property: $name")

                setter(engine, voice_index, stream_index, val)
                @test_approx_eq getter(engine, voice_index, stream_index) val
            end
        end
    end

    open(labelpath) do f
        synthesize_from_strings(engine, readlines(f))
    end

    @test get_total_state(engine) > 0
    for state_index in 1:get_nstate(engine)
        @test get_state_duration(engine, state_index) > 0
    end
    @test get_total_frame(engine) > 0
    @test get_nsamples(engine) > 0

    clear(engine)
end

function test_hts_engine_synthesis_funcs()
    engine = HTSEngine(mei_htsvoice)

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
    @test length(synthesized_fn) == get_nsamples(engine)
end

function test_hts_engine_fullcontext_label()
    engine = HTSEngine(mei_htsvoice)
    @test get_fullcontext_label_format(engine) == "HTS_TTS_JPN"
    @test get_fullcontext_label_version(engine) == "1.0"
end

function test_hts_engine_save()
    engine = HTSEngine(mei_htsvoice)
    synthesize_from_fn(engine, labelpath)

    for savefunc in [
                     save_information,
                     save_label,
                     save_generated_speech,
                     save_riff
                     ]
        file = tempname()
        savefunc(engine, file)
        @test isfile(file)
        rm(file)
    end

    for stream_index = 1:get_nstream(engine)
        file = tempname()
        save_generated_parameter(engine, stream_index, file)
        @test isfile(file)
        rm(file)
    end

    clear(engine)
end

function test_hts_engine_synthesis_and_save_wav()
    # Load htsvoice
    engine = HTSEngine(mei_htsvoice)
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

info("test: hts engine properties")
test_hts_engine_properties()

info("test: hts_engine synthesis functions")
test_hts_engine_synthesis_funcs()

info("test: hts_engine fullcontext label")
test_hts_engine_fullcontext_label()

info("test: hts_engine save")
test_hts_engine_save()

info("test: hts_engine syntheis and save to wav")
test_hts_engine_synthesis_and_save_wav()
