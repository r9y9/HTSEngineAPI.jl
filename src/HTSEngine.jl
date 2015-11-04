__precompile__(@unix? true : false)

"""
HTSEngine is a wrapper of hts_engine_API that provides speech waveform
synthesis from Hidden Markov Models (HMMs)  trained by the HMM-based
speech synthesis system (HTS).
"""
module HTSEngine

export
    HTS_Audio,
    HTS_Window,
    HTS_Pattern,
    HTS_Question,
    HTS_Node,
    HTS_Tree,
    HTS_Model,
    HTS_ModelSet,
    HTS_LabelString,
    HTS_Label,
    HTS_SStream,
    HTS_SStreamSet,
    HTS_SMatrices,
    HTS_PStream,
    HTS_PStreamSet,
    HTS_GStream,
    HTS_GStreamSet,
    HTS_Condition,

    HTS_Engine,
    init,
    load,

    set_sampling_frequency,
    get_sampling_frequency,
    set_fperiod,
    get_fperiod,
    set_audio_buff_size,
    get_audio_buff_size,
    set_stop_flag,
    get_stop_flag,
    set_volume,
    get_volume,
    set_msd_threshold,
    get_msd_threshold,
    set_gv_weight,
    get_gv_weight,

    get_nvoices,
    get_nstream,
    get_nstate,
    get_total_frame,
    get_nsamples,
    get_generated_speech,

    synthesize_from_fn,
    save_riff,

    refresh,
    clear

using BinDeps

# Load dependency
deps = joinpath(Pkg.dir("HTSEngine"), "deps", "deps.jl")
if isfile(deps)
    include(deps)
else
    error("HTSEngine not properly installed. Please run Pkg.build(\"HTSEngine\")")
end

typealias HTS_Boolean Cchar

immutable HTS_Audio
    sampling_frequency::Csize_t
    max_buff_size::Csize_t
    buff::Ptr{Cshort}
    buff_size::Csize_t
    audio_interface::Ptr{Void}

    HTS_Audio() = new(0, 0, 0, 0, 0)
end

immutable HTS_Window
    size::Csize_t
    l_width::Ptr{Cint}
    r_width::Ptr{Cint}
    coefficient::Ptr{Ptr{Cdouble}}
    max_width::Csize_t

    HTS_Window() = new(0, 0, 0, 0, 0)
end

immutable HTS_Pattern
    string::Ptr{Cchar}
    next::Ptr{HTS_Pattern}

    HTS_Pattern() = new(0, 0)
end

immutable HTS_Question
    string::Ptr{Cchar}
    head::Ptr{HTS_Pattern}
    next::Ptr{HTS_Question}

    HTS_Question() = new(0, 0, 0)
end

immutable HTS_Node
    index::Cint
    pdf::Csize_t
    yes::Ptr{HTS_Node}
    no::Ptr{HTS_Node}
    next::Ptr{HTS_Node}
    quest::Ptr{HTS_Question}

    HTS_Node() = new(0, 0, 0, 0, 0, 0)
end

immutable HTS_Tree
    head::Ptr{HTS_Pattern}
    next::Ptr{HTS_Tree}
    root::Ptr{HTS_Node}
    state::Csize_t

    HTS_Tree() = new(0, 0, 0, 0)
end

immutable HTS_Model
    vector_length::Csize_t
    num_windows::Csize_t
    is_msd::HTS_Boolean
    ntree::Csize_t
    npdf::Ptr{Csize_t}
    pdf::Ptr{Ptr{Ptr{Csize_t}}}
    tree::Ptr{HTS_Tree}
    question::Ptr{HTS_Question}

    HTS_Model() = new(0, 0, 0, 0, 0, 0, 0, 0)
end

immutable HTS_ModelSet
    hts_voice_version::Ptr{Cchar}
    sampling_frequency::Csize_t
    frame_period::Csize_t
    num_voices::Csize_t
    num_states::Csize_t
    num_streams::Csize_t
    stream_type::Ptr{Cchar}
    fullcontext_format::Ptr{Cchar}
    fullcontext_version::Ptr{Cchar}
    gv_off_context::Ptr{HTS_Question}
    option::Ptr{Ptr{Cchar}}
    duration::Ptr{HTS_Model}
    window::Ptr{HTS_Window}
    stream::Ptr{Ptr{HTS_Model}}
    gv::Ptr{Ptr{HTS_Model}}

    HTS_ModelSet() = new(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
end

immutable HTS_LabelString
    next::Ptr{HTS_LabelString}
    name::Ptr{Cchar}
    start::Cdouble
    c_end::Cdouble

    HTS_LabelString() = new(0, 0, 0, 0)
end

immutable HTS_Label
    head::Ptr{HTS_LabelString}
    size::Csize_t

    HTS_Label() = new(0, 0)
end

immutable HTS_SStream
    vector_length::Csize_t
    mean::Ptr{Ptr{Cdouble}}
    vari::Ptr{Ptr{Cdouble}}
    msd::Ptr{Cdouble}
    win_l_width::Ptr{Int}
    win_r_width::Ptr{Int}
    win_coefficient::Ptr{Ptr{Cdouble}}
    win_max_width::Csize_t
    gv_mean::Ptr{Cdouble}
    gv_vari::Ptr{Cdouble}
    gv_switch::Ptr{HTS_Boolean}

    HTS_SStream() = new(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
end

immutable HTS_SStreamSet
    sstream::Ptr{HTS_SStream}
    nstream::Csize_t
    nstate::Csize_t
    duration::Ptr{Csize_t}
    total_state::Csize_t
    total_frame::Csize_t

    HTS_SStreamSet() = new(0, 0, 0, 0, 0, 0)
end

immutable HTS_SMatrices
    mean::Ptr{Ptr{Cdouble}}
    ivar::Ptr{Ptr{Cdouble}}
    g::Ptr{Cdouble}
    wuw::Ptr{Ptr{Cdouble}}
    wum::Ptr{Cdouble}

    HTS_SMatrices() = new(0, 0, 0, 0, 0)
end

immutable HTS_PStream
    vector_length::Csize_t
    length::Csize_t
    width::Csize_t
    par::Ptr{Ptr{Cdouble}}
    sm::HTS_SMatrices
    win_size::Csize_t
    win_l_width::Ptr{Int}
    win_r_width::Ptr{Int}
    win_coefficient::Ptr{Ptr{Cdouble}}
    msd_flag::HTS_Boolean
    gv_mean::Ptr{Cdouble}
    gv_vari::Ptr{Cdouble}
    gv_switch::Ptr{HTS_Boolean}
    gv_length::Csize_t

    HTS_PStream() = new(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
end

immutable HTS_PStreamSet
    pstream::Ptr{HTS_PStream}
    nstream::Csize_t
    total_frame::Csize_t

    HTS_PStreamSet() = new(0, 0, 0)
end

immutable HTS_GStream
    vector_length::Csize_t
    par::Ptr{Ptr{Cdouble}}

    HTS_GStream() = new(0, 0)
end

immutable HTS_GStreamSet
    total_nsample::Csize_t
    total_frame::Csize_t
    nstream::Csize_t
    gstream::Ptr{HTS_GStream}
    gspeech::Ptr{Cdouble}

    HTS_GStreamSet() = new(0, 0, 0, 0, 0)
end

immutable HTS_Condition
    sampling_frequency::Csize_t
    fperiod::Csize_t
    audio_buff_size::Csize_t
    stop::HTS_Boolean
    volume::Cdouble
    msd_threshold::Ptr{Cdouble}
    gv_weight::Ptr{Cdouble}
    phoneme_alignment_flag::HTS_Boolean
    speed::Cdouble
    stage::Csize_t
    use_log_gain::HTS_Boolean
    alpha::Cdouble
    beta::Cdouble
    additional_half_tone::Cdouble
    duration_iw::Ptr{Cdouble}
    parameter_iw::Ptr{Ptr{Cdouble}}
    gv_iw::Ptr{Ptr{Cdouble}}

    HTS_Condition() = new(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
end

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

macro htscall(f, rettype, argtypes, args...)
    args = map(esc, args)
    quote
        ccall(($f, HTSEngine.libhts_engine_API),
              $rettype, $argtypes, $(args...))
    end
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

end # module HTSEngine
