__precompile__(@unix? true : false)

"""
HTSEngineAPI is a wrapper of hts_engine_API that provides speech waveform
synthesis from Hidden Markov Models (HMMs)  trained by the HMM-based
speech synthesis system (HTS).
"""
module HTSEngineAPI

export
    # Internal types
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

    # The speech synthesis engine
    HTSEngine,

    initialize,
    load,
    refresh,
    clear,

    # Set/Get parameters of HTS engine
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
    set_speed,
    set_alpha,
    get_alpha,
    set_beta,
    get_beta,
    add_half_tone,
    set_duration_interpolation_weight,
    get_duration_interpolation_weight,
    set_parameter_interpolation_weight,
    get_parameter_interpolation_weight,
    set_gv_interpolation_weight,
    get_gv_interpolation_weight,

    get_total_state,
    get_state_duration,
    get_nvoices,
    get_nstream,
    get_nstate,
    get_fullcontext_label_format,
    get_fullcontext_label_version,
    get_total_frame,
    get_nsamples,

    get_generated_parameter,
    get_generated_speech,

    # Synthesis
    synthesize_from_fn,
    synthesize_from_strings,

    # Save
    save_information,
    save_label,
    save_generated_parameter,
    save_generated_speech,
    save_riff

using BinDeps

# Load dependency
deps = joinpath(Pkg.dir("HTSEngineAPI"), "deps", "deps.jl")
if isfile(deps)
    include(deps)
else
    error("HTSEngineAPI not properly installed. Please run Pkg.build(\"HTSEngineAPI\")")
end

for fname in [
              "macros",
              "internals",
              "htsengine"
              ]
    include(string(fname, ".jl"))
end

end # module HTSEngineAPI
