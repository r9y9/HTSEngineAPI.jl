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
