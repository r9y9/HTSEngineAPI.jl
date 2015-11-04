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
        init(p)
        return p
    end
end

function HTS_Engine(voices)
    engine = HTS_Engine()
    return load(engine, voices)
end

function init(engine::HTS_Engine)
    @htscall(:HTS_Engine_initialize, Void, (Ptr{HTS_Engine},), &engine)
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

function set_sampling_frequency(engine::HTS_Engine, fs)
    @htscall(:HTS_Engine_set_sampling_frequency, Void,
             (Ptr{HTS_Engine}, Csize_t), &engine, fs)
end

function get_sampling_frequency(engine::HTS_Engine)
    fs = @htscall(:HTS_Engine_get_sampling_frequency, Csize_t,
                  (Ptr{HTS_Engine},), &engine)
    signed(fs)
end

function set_fperiod(engine::HTS_Engine, fperiod)
    @htscall(:HTS_Engine_set_fperiod, Void,
             (Ptr{HTS_Engine}, Csize_t), &engine, fperiod)
end

function get_fperiod(engine::HTS_Engine)
    fp = @htscall(:HTS_Engine_get_fperiod, Csize_t, (Ptr{HTS_Engine},), &engine)
    signed(fp)
end

function set_audio_buff_size(engine::HTS_Engine, buff_size)
    @htscall(:HTS_Engine_set_audio_buff_size, Void,
             (Ptr{HTS_Engine}, Csize_t), &engine, buff_size)
end

function get_audio_buff_size(engine::HTS_Engine)
    bs = @htscall(:HTS_Engine_get_audio_buff_size, Csize_t,
                  (Ptr{HTS_Engine},), &engine)
    signed(bs)
end

function set_stop_flag(engine::HTS_Engine, stop_flag::Bool)
    @htscall(:HTS_Engine_set_stop_flag, Void,
             (Ptr{HTS_Engine}, HTS_Boolean), &engine, stop_flag)
end

function get_stop_flag(engine::HTS_Engine)
    stop_flag = @htscall(:HTS_Engine_get_stop_flag, HTS_Boolean,
                         (Ptr{HTS_Engine},), &engine)
    convert(Bool, stop_flag)
end

function set_volume(engine::HTS_Engine, volume)
    @htscall(:HTS_Engine_set_volume, Void,
             (Ptr{HTS_Engine}, Cdouble), &engine, volume)
end

function get_volume(engine::HTS_Engine)
    @htscall(:HTS_Engine_get_volume, Cdouble, (Ptr{HTS_Engine},), &engine)
end

function set_msd_threshold(engine::HTS_Engine, stream_index, msd_threshold)
    @htscall(:HTS_Engine_set_msd_threshold, Void,
             (Ptr{HTS_Engine}, Csize_t, Cdouble),
             &engine, stream_index, msd_threshold)
end

function get_msd_threshold(engine::HTS_Engine, stream_index)
    @htscall(:HTS_Engine_get_msd_threshold, Cdouble,
             (Ptr{HTS_Engine}, Csize_t), &engine, stream_index)
end

function set_gv_weight(engine::HTS_Engine, stream_index, gv_weight)
    @htscall(:HTS_Engine_set_gv_weight, Void,
             (Ptr{HTS_Engine}, Csize_t, Cdouble),
             &engine, stream_index, gv_weight)
end

function get_gv_weight(engine::HTS_Engine, stream_index)
    @htscall(:HTS_Engine_get_gv_weight, Cdouble,
             (Ptr{HTS_Engine}, Csize_t), &engine, stream_index)
end

function get_nvoices(engine::HTS_Engine)
    r = @htscall(:HTS_Engine_get_nvoices, Csize_t, (Ptr{HTS_Engine},), &engine)
    signed(r)
end

function get_nstream(engine::HTS_Engine)
    r = @htscall(:HTS_Engine_get_nstream, Csize_t, (Ptr{HTS_Engine},), &engine)
    signed(r)
end

function get_nstate(engine::HTS_Engine)
    r = @htscall(:HTS_Engine_get_nstate, Csize_t, (Ptr{HTS_Engine},), &engine)
    signed(r)
end

function get_total_frame(engine::HTS_Engine)
    r = @htscall(:HTS_Engine_get_total_frame, Csize_t, (Ptr{HTS_Engine},), &engine)
    signed(r)
end

function get_nsamples(engine::HTS_Engine)
    r = @htscall(:HTS_Engine_get_nsamples, Csize_t, (Ptr{HTS_Engine},), &engine)
    signed(r)
end

function get_generated_speech(engine::HTS_Engine, index)
    @htscall(:HTS_Engine_get_generated_speech, Cdouble,
             (Ptr{HTS_Engine}, Csize_t), &engine, index)
end

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

function refresh(engine::HTS_Engine)
    @htscall(:HTS_Engine_refresh, Void, (Ptr{HTS_Engine},), &engine)
end

function clear(engine::HTS_Engine)
    @htscall(:HTS_Engine_clear, Void, (Ptr{HTS_Engine},), &engine)
end
