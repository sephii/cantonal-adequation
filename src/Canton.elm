module Canton exposing (Canton(..), cantonParticle, toCanton, toFullName)

import Translation


type Canton
    = ZH
    | BE
    | LU
    | UR
    | SZ
    | OW
    | NW
    | GL
    | ZG
    | FR
    | SO
    | BS
    | BL
    | SH
    | AR
    | AI
    | SG
    | GR
    | AG
    | TG
    | TI
    | VD
    | VS
    | NE
    | GE
    | JU


cantonParticle : Canton -> String
cantonParticle canton =
    case canton of
        UR ->
            "d’"

        OW ->
            "d’"

        AR ->
            "d’"

        AI ->
            "d’"

        GR ->
            "des"

        AG ->
            "d’"

        TI ->
            "du"

        VS ->
            "du"

        JU ->
            "du"

        _ ->
            "de"


toFullName : Canton -> Translation.TranslatedString
toFullName canton =
    case canton of
        ZH ->
            { fr = "Zurich", de = "Zürich" }

        BE ->
            { fr = "Berne", de = "Bern" }

        LU ->
            { fr = "Lucerne", de = "Luzern" }

        UR ->
            { fr = "Uri", de = "Uri" }

        SZ ->
            { fr = "Schwytz", de = "Schwyz" }

        OW ->
            { fr = "Obwald", de = "Obwalden" }

        NW ->
            { fr = "Nidwald", de = "Nidwalden" }

        GL ->
            { fr = "Glaris", de = "Glarus" }

        ZG ->
            { fr = "Zug", de = "Zug" }

        FR ->
            { fr = "Fribourg", de = "Freiburg" }

        SO ->
            { fr = "Soleure", de = "Solothurn" }

        BS ->
            { fr = "Bâle-ville", de = "Basel-Stadt" }

        BL ->
            { fr = "Bâle-campagne", de = "Basel-Landschaft" }

        SH ->
            { fr = "Schaffhouse", de = "Schaffhausen" }

        AR ->
            { fr = "Appenzell Rhodes-Extérieures", de = "Appenzell Ausserrhoden" }

        AI ->
            { fr = "Appenzell Rhodes-Intérieures", de = "Appenzell Innerrhoden" }

        SG ->
            { fr = "Saint-Gall", de = "St. Gallen" }

        GR ->
            { fr = "Grisons", de = "Graubünden" }

        AG ->
            { fr = "Argovie", de = "Aargau" }

        TG ->
            { fr = "Thurgovie", de = "Thurgau" }

        TI ->
            { fr = "Tessin", de = "Tessin" }

        VD ->
            { fr = "Vaud", de = "Waadt" }

        VS ->
            { fr = "Valais", de = "Wallis" }

        NE ->
            { fr = "Neuchâtel", de = "Neuenburg" }

        GE ->
            { fr = "Genève", de = "Genf" }

        JU ->
            { fr = "Jura", de = "Jura" }


toCanton : String -> Maybe Canton
toCanton canton =
    case canton of
        "ZH" ->
            Just ZH

        "BE" ->
            Just BE

        "LU" ->
            Just LU

        "UR" ->
            Just UR

        "SZ" ->
            Just SZ

        "OW" ->
            Just OW

        "NW" ->
            Just NW

        "GL" ->
            Just GL

        "ZG" ->
            Just ZG

        "FR" ->
            Just FR

        "SO" ->
            Just SO

        "BS" ->
            Just BS

        "BL" ->
            Just BL

        "SH" ->
            Just SH

        "AR" ->
            Just AR

        "AI" ->
            Just AI

        "SG" ->
            Just SG

        "GR" ->
            Just GR

        "AG" ->
            Just AG

        "TG" ->
            Just TG

        "TI" ->
            Just TI

        "VD" ->
            Just VD

        "VS" ->
            Just VS

        "NE" ->
            Just NE

        "GE" ->
            Just GE

        "JU" ->
            Just JU

        _ ->
            Nothing
