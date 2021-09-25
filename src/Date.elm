module Date exposing
    ( Date
    , Month(..)
    , dateDecoder
    , humanizeDate
    , toString
    )

import Json.Decode as D
import Parser exposing ((|.), (|=), Parser)
import Translation


type Month
    = January
    | February
    | March
    | April
    | May
    | June
    | July
    | August
    | September
    | October
    | November
    | December


type Date
    = Date
        { year : Int
        , month : Month
        , day : Int
        }


monthParser : Int -> Parser Month
monthParser month =
    case month of
        1 ->
            Parser.succeed January

        2 ->
            Parser.succeed February

        3 ->
            Parser.succeed March

        4 ->
            Parser.succeed April

        5 ->
            Parser.succeed May

        6 ->
            Parser.succeed June

        7 ->
            Parser.succeed July

        8 ->
            Parser.succeed August

        9 ->
            Parser.succeed September

        10 ->
            Parser.succeed October

        11 ->
            Parser.succeed November

        12 ->
            Parser.succeed December

        _ ->
            Parser.problem "Unknown month"


dateParser : Parser Date
dateParser =
    let
        dropLeadingZero =
            Parser.oneOf [ Parser.chompIf ((==) '0'), Parser.succeed () ]

        createDate year month day =
            Date { year = year, month = month, day = day }
    in
    Parser.succeed createDate
        |= Parser.int
        |. Parser.symbol "-"
        |. dropLeadingZero
        |= (Parser.int |> Parser.andThen monthParser)
        |. Parser.symbol "-"
        |. dropLeadingZero
        |= Parser.int
        |. Parser.end


monthToString : Month -> Translation.TranslatedString
monthToString month =
    case month of
        January ->
            { fr = "janvier", de = "Januar" }

        February ->
            { fr = "février", de = "Februar" }

        March ->
            { fr = "mars", de = "März" }

        April ->
            { fr = "avril", de = "April" }

        May ->
            { fr = "mai", de = "Mai" }

        June ->
            { fr = "juin", de = "Juni" }

        July ->
            { fr = "juillet", de = "Juli" }

        August ->
            { fr = "août", de = "August" }

        September ->
            { fr = "septembre", de = "September" }

        October ->
            { fr = "octobre", de = "Oktober" }

        November ->
            { fr = "novembre", de = "November" }

        December ->
            { fr = "décembre", de = "Dezember" }


monthToInt : Month -> Int
monthToInt month =
    case month of
        January ->
            1

        February ->
            2

        March ->
            3

        April ->
            4

        May ->
            5

        June ->
            6

        July ->
            7

        August ->
            8

        September ->
            9

        October ->
            10

        November ->
            11

        December ->
            12


parseDate : String -> Maybe Date
parseDate dateStr =
    Parser.run dateParser dateStr
        |> Result.toMaybe


toString : Date -> String
toString (Date date) =
    let
        pad =
            String.padLeft 2 '0'
    in
    String.fromInt date.year ++ "-" ++ pad (String.fromInt (monthToInt date.month)) ++ "-" ++ pad (String.fromInt date.day)


humanizeDate : Translation.Language -> Date -> String
humanizeDate language (Date date) =
    let
        month =
            Translation.translate language (monthToString date.month)
    in
    case language of
        Translation.French ->
            String.fromInt date.day ++ " " ++ month ++ " " ++ String.fromInt date.year

        Translation.German ->
            String.fromInt date.day ++ ". " ++ month ++ " " ++ String.fromInt date.year


dateDecoder : D.Decoder Date
dateDecoder =
    D.map parseDate D.string
        |> D.andThen
            (\v ->
                case v of
                    Nothing ->
                        D.fail "Unable to parse date"

                    Just date ->
                        D.succeed date
            )
