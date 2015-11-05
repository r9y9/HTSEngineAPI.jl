"""
HTSEngine is the main interface for hts_engine_API
"""
type HTSEngine
    condition::HTS_Condition
    audio::HTS_Audio
    ms::HTS_ModelSet
    label::HTS_Label
    sss::HTS_SStreamSet
    pss::HTS_PStreamSet
    gss::HTS_GStreamSet
    function HTSEngine()
        p = new(HTS_Condition(), HTS_Audio(), HTS_ModelSet(), HTS_Label(),
                HTS_SStreamSet(), HTS_PStreamSet(), HTS_GStreamSet())
        initialize(p)
        finalizer(p, clear)
        p
    end
end

# NOTE: `HTSEngine` is a Julia equivalent type of C-struct `HTS_Engine`
typealias HTS_Engine HTSEngine

function HTSEngine(voices)
    engine = HTSEngine()
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

# TODO: remove dupulicate code

for (name, argtype) in [
                         (:set_sampling_frequency, Csize_t),
                         (:set_fperiod, Csize_t),
                         (:set_audio_buff_size, Csize_t),
                         (:set_stop_flag, HTS_Boolean),
                         (:set_volume, Cdouble),
                         (:set_speed, Cdouble),
                         (:set_phoneme_alignment_flag, HTS_Boolean),
                         (:set_alpha, Cdouble),
                         (:set_beta, Cdouble),
                         (:add_half_tone, Cdouble)
                         ]
    fsymbol = QuoteNode(symbol(:HTS_Engine_, name))
    @eval begin
        function $name(engine::HTS_Engine, val)
            @htscall($fsymbol, Void, (Ptr{HTS_Engine}, $argtype), &engine)
        end
    end
end

for (name, argt1, argt2) in [
                             (:set_msd_threshold, Csize_t, Cdouble),
                             (:set_gv_weight, Csize_t, Cdouble),
                             (:set_duration_interpolation_weight, Csize_t, Cdouble),
                             ]
    fsymbol = QuoteNode(symbol(:HTS_Engine_, name))
    @eval begin
        function $name(engine::HTS_Engine, index, val)
            @htscall($fsymbol, Void, (Ptr{HTS_Engine}, $argt1, $argt2),
                     &engine, index, val)
        end
    end
end

for (name, argt1, argt2, argt3) in [
                                    (:set_parameter_interpolation_weight,
                                     Csize_t, Csize_t, Cdouble),
                                    (:set_gv_interpolation_weight,
                                     Csize_t, Csize_t, Cdouble)
                                    ]
    fsymbol = QuoteNode(symbol(:HTS_Engine_, name))
    @eval begin
        function $name(engine::HTS_Engine, voice_index, stream_index, val)
            @htscall($fsymbol, Void, (Ptr{HTS_Engine}, $argt1, $argt2, $argt3),
                     &engine, voiece_index, stream_index, val)
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
                        (:get_total_state, Csize_t),
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
                                 (:get_gv_weight, Cdouble, Csize_t),
                                 (:get_duration_interpolation_weight,
                                  Cdouble, Csize_t),
                                 (:get_state_duration, Csize_t, Csize_t)
                                 ]
    fsymbol = QuoteNode(symbol(:HTS_Engine_, name))
    @eval begin
        function $name(engine::HTS_Engine, index)
            @htscall($fsymbol, $rettype, (Ptr{HTS_Engine}, $argtype),
                     &engine, index)
        end
    end
end

for (name, rettype, argt1, argt2) in [
                                      (:get_parameter_interpolation_weight,
                                       Cdouble, Csize_t, Csize_t),
                                      (:get_gv_interpolation_weight,
                                       Cdouble, Csize_t, Csize_t)
                                      ]
    fsymbol = QuoteNode(symbol(:HTS_Engine_, name))
    @eval begin
        function $name(engine::HTS_Engine, voice_index, stream_index)
            @htscall($fsymbol, $rettype, (Ptr{HTS_Engine}, $argt1, $argt2),
                     &engine, voiece_index, stream_index)
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
    for i in 1:length(voices)
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

function get_fullcontext_label_format(engine::HTS_Engine)
    ret = @htscall(:HTS_Engine_get_fullcontext_label_format,
                   Ptr{Cchar}, (Ptr{HTS_Engine},), &engine)
    bytestring(ret)
end

function get_fullcontext_label_version(engine::HTS_Engine)
    ret = @htscall(:HTS_Engine_get_fullcontext_label_version,
                   Ptr{Cchar}, (Ptr{HTS_Engine},), &engine)
    bytestring(ret)
end

function get_generated_parameter(engine::HTS_Engine,
                                 stream_index, frame_index, vector_index)
    @htscall(:HTS_Engine_get_generated_parameter, Cdouble,
             (Ptr{HTS_Engine}, Csize_t, Csize_t, Csize_t),
             &engine, stream_index, frame_index, vector_index)
end

function get_generated_speech(engine::HTS_Engine, index)
    @assert index > 0 # 1-origin for Julia interface
    @htscall(:HTS_Engine_get_generated_speech, Cdouble,
             (Ptr{HTS_Engine}, Csize_t), &engine, index-1)
end

function get_generated_speech(engine::HTS_Engine)
    speech = Vector{Float64}(get_nsamples(engine))

    @inbounds for i in eachindex(speech)
        speech[i] = get_generated_speech(engine, i)
    end

    speech
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

function synthesize_from_strings(engine::HTS_Engine, lines)
    clines = Vector{Vector{Cchar}}(length(lines))
    for i in 1:length(lines)
        clines[i] = collect(lines[i])
    end

    ret = @htscall(:HTS_Engine_synthesize_from_strings, HTS_Boolean,
                   (Ptr{HTS_Engine}, Ptr{Ptr{Cchar}}, Csize_t),
                   &engine, clines, length(clines))
    r = convert(Bool, ret)
    if !r
        error("failed to synthesize waveform")
    end
end

### Save ###

for (name, mode) = [
                    (:save_information, "wt"),
                    (:save_label, "wt"),
                    (:save_generated_speech, "wb"),
                    (:save_riff, "wb")
                    ]
    fsymbol = QuoteNode(symbol(:HTS_Engine_, name))
    @eval begin
        function $name(engine::HTS_Engine, path)
            fp = ccall(:fopen, Ptr{Void}, (Ptr{Cchar}, Ptr{Cchar}),
                       path, $mode)
            @assert fp != C_NULL
            @htscall($fsymbol, Void,
                     (Ptr{HTS_Engine}, Ptr{Void}), &engine, fp)
            ccall(:fclose, Void, (Ptr{Void},), fp)
        end
    end
end

function save_generated_parameter(engine::HTS_Engine, stream_index, path)
    fp = ccall(:fopen, Ptr{Void}, (Ptr{Cchar}, Ptr{Cchar}), path, "wb")
    @assert fp != C_NULL
    @htscall(:HTS_Engine_save_generated_parameter, Void,
             (Ptr{HTS_Engine}, Ptr{Void}), &engine, fp)
    ccall(:fclose, Void, (Ptr{Void},), fp)
end
