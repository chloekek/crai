{ curl, git, gnuplot, gnutar, lib, libressl, perl, raku, rakudo, rsync, sassc
, sqlite }:
let
    meta6 = builtins.fromJSON (builtins.readFile ./META6.json);
    get-depend = p: raku."${builtins.replaceStrings ["::"] ["-"] p}";
in
    raku.rakuPackage {
        name = "crai";
        src = ./.;
        buildInputs = [ sassc ];
        depends = map get-depend meta6.depends;
        preInstallPhase = ''
            extraPATH=${git}/bin:${gnuplot}/bin:${gnutar}/bin:${rsync}/bin
            extraLD_LIBRARY_PATH=${lib.makeLibraryPath [ curl libressl sqlite ]}

            export PATH=$extraPATH:$PATH
            export LD_LIBRARY_PATH=$extraLD_LIBRARY_PATH:$LD_LIBRARY_PATH
        '';
        postInstallPhase = ''
            makeWrapper ${perl}/bin/prove $out/bin/crai-prove       \
                --prefix PERL6LIB , "$(< $out/PERL6LIB)"            \
                --prefix PATH            : "$extraPATH"             \
                --prefix LD_LIBRARY_PATH : "$extraLD_LIBRARY_PATH"  \
                --add-flags --exec                                  \
                --add-flags ${rakudo}/bin/raku

            for p in $out/bin/crai-{fastcgi,cron}{,.profile}; do
                wrapProgram $p                                      \
                    --prefix PATH            : "$extraPATH"         \
                    --prefix LD_LIBRARY_PATH : "$extraLD_LIBRARY_PATH"
            done

            mkdir --parents $out
            mv static $out
        '';
    }
