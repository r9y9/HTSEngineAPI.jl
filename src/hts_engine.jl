"""
HTS_Engine is the main interface for hts_engine_API
"""
type HTS_Engine
    condition::HTS_Condition
    audio::HTS_Audio
    ms::HTS_ModelSet
    label::HTS_Label
    sss::HTS_SStreamSet
    pss::HTS_PStreamSet
    gss::HTS_GStreamSet
    function HTS_Engine()
        p = new(HTS_Condition(), HTS_Audio(), HTS_ModelSet(), HTS_Label(),
                HTS_SStreamSet(), HTS_PStreamSet(), HTS_GStreamSet())
        initialize(p)
        return p
    end
end

function HTS_Engine(voices)
    engine = HTS_Engine()
    return load(engine, voices)
end

for name in [:initialize, :refresh, :clear]
    fsymbol = QuoteNode(symbol(:HTS_Engine_, name))
    @eval begin
        function $name(engine::HTS_Engine)
            @htscall($fsymbol, Void, (Ptr{HTS_Engine},), &engine)
        end
    end
end

### Setter ###

for (name, argtype) in [
                         (:set_sampling_frequency, Csize_t),
                         (:set_fperiod, Csize_t),
                         (:set_audio_buff_size, Csize_t),
                         (:set_stop_flag, HTS_Boolean),
                         (:set_volume, Cdouble),
                         (:set_speed, Cdouble),
                         (:set_alpha, Cdouble),
                         (:set_beta, Cdouble)
                         ]
    fsymbol = QuoteNode(symbol(:HTS_Engine_, name))
    @eval begin
        function $name(engine::HTS_Engine, val)
            @htscall($fsymbol, Void, (Ptr{HTS_Engine}, $argtype), &engine)
        end
    end
end

for (name, argtypes) in [
                         (:set_msd_threshold, (Csize_t, Cdouble)),
                         (:set_gv_weight, (Csize_t, Cdouble)),
                         ]
    fsymbol = QuoteNode(symbol(:HTS_Engine_, name))
    @eval begin
        function $name(engine::HTS_Engine, stream_index, val)
            @htscall($fsymbol, Void, (Ptr{HTS_Engine}, ($argtypes)...),
                     &engine, stream_index, val)
        end
    end
end

### Getter ###

for (name, rettype) in [
                         (:get_sampling_frequency, Csize_t),
                         (:get_fperiod, Csize_t),
                         (:get_audio_buff_size, Csize_t),
                         (:get_volume, Cdouble),
                         (:get_alpha, Cdouble),
                         (:get_beta, Cdouble),
                         (:get_nvoices, Csize_t),
                         (:get_nstream, Csize_t),
                         (:get_nstate, Csize_t),
                         (:get_total_frame, Csize_t),
                         (:get_nsamples, Csize_t)
                         ]
    fsymbol = QuoteNode(symbol(:HTS_Engine_, name))
    @eval begin
        function $name(engine::HTS_Engine)
            r = @htscall($fsymbol, $rettype, (Ptr{HTS_Engine},), &engine)
            @signed r # for convenience
        end
    end
end

for (name, rettype, argtype) in [
                                 (:get_msd_threshold, Cdouble, Csize_t),
                                 (:get_gv_weight, Cdouble, Csize_t)
                                 ]
    fsymbol = QuoteNode(symbol(:HTS_Engine_, name))
    @eval begin
        function $name(engine::HTS_Engine, stream_index)
            @htscall($fsymbol, $rettype, (Ptr{HTS_Engine}, $argtype),
                     &engine, stream_index)
        end
    end
end


function load{T<:AbstractString}(engine::HTS_Engine, voices::Vector{T})
    for voice in voices
        if !isfile(voice)
            error("$voice doesn't exists")
        end
    end
    c_voices = Vector{Vector{Cchar}}(length(voices))
    for i in 1 : length(voices)
        c_voices[i] = collect(voices[i])
    end
    ret = @htscall(:HTS_Engine_load, HTS_Boolean,
                 (Ptr{HTS_Engine}, Ptr{Ptr{Cchar}}, Csize_t),
                 &engine, c_voices, length(c_voices))
    r = convert(Bool, ret)
    if !r
        error("failed to initialize HTS_Engine")
    end

    engine
end

function load{T<:AbstractString}(engine::HTS_Engine, voice::T)
    load(engine, [voice])
end

function get_stop_flag(engine::HTS_Engine)
    stop_flag = @htscall(:HTS_Engine_get_stop_flag, HTS_Boolean,
                         (Ptr{HTS_Engine},), &engine)
    convert(Bool, stop_flag)
end

function get_generated_speech(engine::HTS_Engine, index)
    @htscall(:HTS_Engine_get_generated_speech, Cdouble,
             (Ptr{HTS_Engine}, Csize_t), &engine, index)
end

### Synthesize ###

function synthesize_from_fn(engine::HTS_Engine, labelpath)
    if !isfile(labelpath)
        error("Input lable file doesn't exists")
    end
    ret = @htscall(:HTS_Engine_synthesize_from_fn, HTS_Boolean,
                   (Ptr{HTS_Engine}, Ptr{Cchar}), &engine, labelpath)
    r = convert(Bool, ret)
    if !r
        error("failed to synthesize waveform")
    end
end

function save_riff(engine::HTS_Engine, wavpath)
    fp = ccall(:fopen, Ptr{Void}, (Ptr{Cchar}, Ptr{Cchar}), wavpath, "wb")
    @assert fp != C_NULL
    @htscall(:HTS_Engine_save_riff, Void,
             (Ptr{HTS_Engine}, Ptr{Void}), &engine, fp)
    ccall(:fclose, Void, (Ptr{Void},), fp)
end
