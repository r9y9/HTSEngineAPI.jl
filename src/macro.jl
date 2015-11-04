### Macros ###

macro htscall(f, rettype, argtypes, args...)
    args = map(esc, args)
    quote
        ccall(($f, HTSEngine.libhts_engine_API),
              $rettype, $argtypes, $(args...))
    end
end

macro signed(ty)
    ty = esc(ty)
    quote
        if isa($ty, Unsigned)
            return signed($ty)
        else
            return $ty
        end
    end
end
