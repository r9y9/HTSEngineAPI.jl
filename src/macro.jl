macro htscall(f, rettype, argtypes, args...)
    args = map(esc, args)
    quote
        ccall(($f, HTSEngine.libhts_engine_API),
              $rettype, $argtypes, $(args...))
    end
end
