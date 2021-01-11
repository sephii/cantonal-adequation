module Translation exposing (Language(..), MsgIdTranslator, MultiTranslator, TranslatedString, TranslationMsgId(..), Translator, fromLanguageCode, multiTranslator, translate, translateMsg)


type Language
    = French
    | German


type alias TranslatedString =
    { fr : String
    , de : String
    }


type alias MsgIdTranslator =
    TranslationMsgId -> String


type alias Translator =
    TranslatedString -> String


type alias MultiTranslator =
    { string : Translator
    , msgId : MsgIdTranslator
    , language : Language
    }


type TranslationMsgId
    = Loading
    | HeaderIntro1
    | HeaderIntro2
    | SourceCode
    | DataSource
    | Contact
    | LoadingError
    | Retry
    | MostAffineCanton String
    | MostAffineCantons
    | LeastAffineCanton String
    | LeastAffineCantons
    | VotationFrom String
    | Yes
    | No
    | Instructions
    | MoreDetails
    | LessDetails


translate : Language -> TranslatedString -> String
translate language translatedString =
    let
        languageAccessor =
            case language of
                German ->
                    .de

                French ->
                    .fr
    in
    languageAccessor translatedString


translateMsg : Language -> TranslationMsgId -> String
translateMsg language translationMsgId =
    translation translationMsgId |> translate language


translation : TranslationMsgId -> TranslatedString
translation translationMsgId =
    case translationMsgId of
        Loading ->
            { fr = "Démontage du Röstigraben…"
            , de = "Zerlegung des Röstigrabens…"
            }

        HeaderIntro1 ->
            { fr = "Tout le monde semble voter faux dans votre région\u{202F}?"
            , de = "Jedermann scheint falsch abzustimmen in Ihrer Region?"
            }

        HeaderIntro2 ->
            { fr = "Vérifiez votre adéquation cantonale\u{202F}!"
            , de = "Überprüfen Sie Ihre kantonale Affinität!"
            }

        Instructions ->
            { fr = "Répondez aux objets comme vous l'avez fait lors des votations et vérifiez votre adéquation cantonale."
            , de = "Antworten Sie, wie Sie es anlässlich der letzten Abstimmung getan haben und überprüfen Sie Ihre kantonale Affinität."
            }

        Yes ->
            { fr = "Oui"
            , de = "Ja"
            }

        No ->
            { fr = "Non"
            , de = "Nein"
            }

        SourceCode ->
            { fr = "Code source"
            , de = "Quellcode"
            }

        DataSource ->
            { fr = "Source des données"
            , de = "Datenquelle"
            }

        Contact ->
            { fr = "Contact"
            , de = "Kontakt"
            }

        LoadingError ->
            { fr = "Une erreur s’est produite durant le chargement des données."
            , de = "Ein Fehler ist aufgetreten während dem Laden der Daten."
            }

        Retry ->
            { fr = "Réessayer"
            , de = "Neuer Versuch"
            }

        MostAffineCanton particle ->
            { fr = "Bonne nouvelle\u{202F}! Dans le canton " ++ particle
            , de = "Gute Nachricht! Im Kanton"
            }

        MostAffineCantons ->
            { fr = "des votes sont similaires aux vôtres. Vous pourriez aussi être intéressé·e par les cantons suivants\u{202F}:"
            , de = "der Stimmen sind mit Ihren identisch. Folgende Kantone könnten Sie auch interessieren:"
            }

        LeastAffineCanton particle ->
            { fr = "Évitez le canton " ++ particle
            , de = "Vermeiden Sie den Kanton"
            }

        LeastAffineCantons ->
            { fr = "des votes sont similaires aux vôtres. Laissez aussi tomber les cantons suivants\u{202F}:"
            , de = "der Stimmen sind mit Ihren identisch. Folgende Kantone sollten Sie auch vermeiden:"
            }

        VotationFrom date ->
            { fr = "Votation populaire du " ++ date
            , de = "Volksabstimmung vom " ++ date
            }

        MoreDetails ->
            { fr = "Plus de détails", de = "Mehr Details" }

        LessDetails ->
            { fr = "Moins de détails", de = "Weniger Details" }


multiTranslator : Language -> MultiTranslator
multiTranslator language =
    { string = translate language
    , msgId = translateMsg language
    , language = language
    }


fromLanguageCode : String -> Language
fromLanguageCode languageCode =
    case languageCode of
        "de" ->
            German

        "fr" ->
            French

        _ ->
            French
