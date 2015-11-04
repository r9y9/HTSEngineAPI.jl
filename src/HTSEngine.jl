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
    initialize,
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
    set_speed,
    set_alpha,
    get_alpha,
    set_beta,
    get_beta,

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

for fname in [
              "macro",
              "internal",
              "hts_engine"
              ]
    include(string(fname, ".jl"))
end

end # module HTSEngine
