module Main exposing (main)

import Browser
import Canton exposing (Canton)
import Css
import Css.Global
import Css.Media
import Date exposing (Date)
import Dict exposing (Dict)
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes exposing (class, css, href, src)
import Html.Styled.Events exposing (onClick)
import Html.Styled.Lazy
import Http
import Json.Decode as D
import List.Extra
import Translation
import Ui


type alias VotationObjectId =
    Int


type alias VotationObject =
    { id : VotationObjectId
    , name : String
    , date : Date
    , results :
        Dict String
            { yes : Int
            , no : Int
            }
    }


type VoteChoice
    = Yes
    | No


type RemoteData data
    = Loading
    | Loaded data
    | Error


type alias IndexedVotationObjects =
    Dict VotationObjectId VotationObject


type alias Model =
    { votationObjects : RemoteData IndexedVotationObjects
    , groupedVotationObjects : List ( Date, List VotationObject )
    , votationChoices : Dict VotationObjectId VoteChoice
    , showMore : Bool
    , translator : Translation.MultiTranslator
    }


type alias Flags =
    { language : String }



-- INIT


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        language =
            Translation.fromLanguageCode flags.language
    in
    ( emptyModel language, fetchVotationResults language )


emptyModel : Translation.Language -> Model
emptyModel language =
    { votationObjects = Loading
    , groupedVotationObjects = []
    , votationChoices = Dict.empty
    , showMore = False
    , translator = Translation.multiTranslator language
    }



-- UPDATE


type Msg
    = GotResultsByCanton (Result Http.Error (List VotationObject))
    | ClickedVoteChoice VoteChoice VotationObject
    | ClickedFetchResults
    | ClickedToggleShowMore


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotResultsByCanton result ->
            case result of
                Err _ ->
                    ( { model | votationObjects = Error }, Cmd.none )

                Ok votationResults ->
                    let
                        indexedVotationObjects =
                            votationResults |> toIndexedVotationObjects

                        groupedVotationObjects =
                            indexedVotationObjects
                                |> Dict.values
                                |> sortByReversed (.date >> Date.toString)
                                |> List.Extra.groupWhile (\a b -> a.date == b.date)
                                |> List.map (\( a, b ) -> ( a.date, a :: b ))
                    in
                    ( { model
                        | votationObjects = Loaded indexedVotationObjects
                        , groupedVotationObjects = groupedVotationObjects
                      }
                    , Cmd.none
                    )

        ClickedVoteChoice voteChoice votationObject ->
            let
                votationChoices =
                    if Dict.get votationObject.id model.votationChoices == Just voteChoice then
                        Dict.remove votationObject.id model.votationChoices

                    else
                        Dict.insert votationObject.id voteChoice model.votationChoices
            in
            ( { model | votationChoices = votationChoices }, Cmd.none )

        ClickedFetchResults ->
            ( { model | votationObjects = Loading }, fetchVotationResults model.translator.language )

        ClickedToggleShowMore ->
            ( { model | showMore = not model.showMore }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    let
        contents =
            case model.votationObjects of
                Loading ->
                    viewLoading model.translator

                Loaded votationObjects ->
                    viewVotationObjects model.translator votationObjects model.groupedVotationObjects model.votationChoices model.showMore

                Error ->
                    viewError model.translator
    in
    Ui.mainContainer
        []
        [ Html.div
            [ css
                [ Css.backgroundColor Ui.colors.primary
                , Css.color (Css.hex "fff")
                , Css.padding (Ui.spacing Ui.L)
                ]
            ]
            [ Html.div
                [ css
                    [ Ui.logoInlineBreakpoint [ Css.displayFlex ] ]
                ]
                [ Html.div
                    [ css
                        [ Css.textAlign Css.center
                        , Css.marginBottom (Ui.spacing Ui.L)
                        , Ui.logoInlineBreakpoint
                            [ Css.marginRight (Ui.spacing Ui.XL)
                            , Css.textAlign Css.left
                            , Css.marginBottom Css.zero
                            ]
                        ]
                    ]
                    [ Html.img [ src "/assets/images/ch_map.svg", css [ Css.width (Css.px 140) ] ] [] ]
                , Ui.heading1
                    []
                    [ Html.text (model.translator.msgId Translation.HeaderIntro1)
                    , Html.br [] []
                    , Html.text (model.translator.msgId Translation.HeaderIntro2)
                    ]
                ]
            , Html.ul
                [ css
                    [ Ui.listInline (Ui.spacing Ui.M)
                    , Css.justifyContent Css.flexEnd
                    , Css.margin Css.zero
                    ]
                ]
                (let
                    headerLink url title =
                        Html.a [ css [ Css.color (Css.hex "fff") ], href url ] [ Html.text title ]
                 in
                 [ Html.li [] [ headerLink "https://adequation-cantonale.ch/" "FR" ]
                 , Html.li [] [ headerLink "https://kantonale-affinitaet.ch/" "DE" ]
                 ]
                )
            ]
        , Html.div
            [ css
                [ Css.padding (Ui.spacing Ui.L)
                ]
            ]
            [ contents ]
        , viewFooter model.translator
        ]


viewIntro : Translation.MultiTranslator -> Html Msg
viewIntro translator =
    Html.div
        [ css
            [ Css.backgroundColor (Css.hex "eee")
            , Css.padding (Ui.spacing Ui.M)
            , Css.marginBottom (Ui.spacing Ui.L)
            ]
        ]
        [ Html.p
            [ css [ Css.margin Css.zero ] ]
            [ translator.msgId Translation.Instructions |> Html.text ]
        ]


viewFooter : Translation.MultiTranslator -> Html Msg
viewFooter translator =
    let
        footerLink url label =
            Html.a [ css [ Css.color Ui.colors.secondary ], href url, Html.Styled.Attributes.target "_blank" ] [ Html.text label ]
    in
    Html.footer
        [ css [ Css.backgroundColor (Css.hex "444"), Css.padding (Ui.spacing Ui.L), Css.color (Css.hex "fff") ] ]
        [ Html.ul
            [ css
                [ Ui.listInline (Ui.spacing Ui.L)
                , Css.textAlign Css.center
                , Css.color Ui.colors.secondary
                ]
            ]
            [ Html.li []
                [ footerLink "https://opendata.swiss/fr/dataset/echtzeitdaten-am-abstimmungstag-zu-eidgenoessischen-abstimmungsvorlagen" (translator.msgId Translation.DataSource) ]
            , Html.li []
                [ footerLink "https://github.com/sephii/cantonal-adequation" (translator.msgId Translation.SourceCode) ]
            , Html.li []
                [ footerLink "https://sylvain.fankhauser.name/" (translator.msgId Translation.Contact) ]
            ]
        ]


viewLoading : Translation.MultiTranslator -> Html Msg
viewLoading translator =
    Html.div
        [ css [ Css.textAlign Css.center ] ]
        [ Html.div
            [ css
                [ Css.color (Css.hex "ddd")
                ]
            ]
            [ Ui.loader 80 ]
        , Html.p [] [ Html.text (translator.msgId Translation.Loading) ]
        ]


viewError : Translation.MultiTranslator -> Html Msg
viewError translator =
    Html.div [ css [ Css.textAlign Css.center ] ]
        [ Html.p [ css [ Css.marginTop Css.zero ] ] [ Html.text (translator.msgId Translation.LoadingError) ]
        , Html.button [ css [ Ui.buttonPrimary ], onClick ClickedFetchResults ] [ Html.text (translator.msgId Translation.Retry) ]
        ]


viewVotationObjects : Translation.MultiTranslator -> IndexedVotationObjects -> List ( Date, List VotationObject ) -> Dict VotationObjectId VoteChoice -> Bool -> Html Msg
viewVotationObjects translator votationObjects groupedVotationObjects votationChoices showMoreAffinities =
    let
        affinities =
            cantonsByAffinity votationObjects votationChoices
                |> List.map
                    (\( canton, score ) ->
                        ( canton, score / toFloat (Dict.size votationChoices) * 100 )
                    )

        votationObjectsBlock =
            Html.div []
                (groupedVotationObjects
                    |> List.map
                        (\( date, objects ) ->
                            viewVotationGroup translator date objects votationChoices
                        )
                )
    in
    Html.div
        [ css
            [ Css.Media.withMedia
                [ Css.Media.all [ Css.Media.minWidth (Css.px 900) ] ]
                [ Css.property "grid-template-columns" "3fr 1fr" ]
            , Ui.affinityBlockInSidebarBreakpoint
                [ Css.property "grid-template-columns" "5fr 2fr"
                , Css.property "display" "grid"
                , Css.property "gap" (Ui.spacing Ui.XL |> .value)
                ]
            ]
        ]
        [ Html.main_
            [ css
                [ Ui.affinityBlockInSidebarBreakpoint
                    [ Css.property "grid-column" "1"
                    , Css.property "grid-row" "1"
                    ]
                ]
            ]
            [ viewIntro translator, votationObjectsBlock ]
        , Html.aside
            [ css
                [ Css.bottom Css.zero
                , Css.property "position" "-webkit-sticky"
                , Css.position Css.sticky
                , Ui.affinityBlockInSidebarBreakpoint
                    [ Css.position Css.relative
                    , Css.bottom Css.unset
                    ]
                ]
            ]
            [ if not (List.isEmpty affinities) then
                Html.div
                    [ css
                        [ Css.top (Css.px 0)
                        , Css.width (Css.pct 100)
                        , Css.backgroundColor (Css.hex "fff")
                        , Css.zIndex (Css.int 100)
                        , Ui.affinityBlockInSidebarBreakpoint
                            [ Css.property "grid-column" "2"
                            , Css.property "grid-row" "1"
                            , Css.property "position" "-webkit-sticky"
                            , Css.position Css.sticky
                            ]
                        ]
                    ]
                    [ viewAffinitiesBlock translator showMoreAffinities affinities ]

              else
                Html.text ""
            ]
        ]


viewAffinityBlock :
    { mainCanton : ( Canton, Float )
    , otherCantons : List ( Canton, Float )
    , color : Css.Color
    , primaryText : String
    , secondaryText : String
    , blockNumber : Int
    , showMore : Bool
    , translator : Translation.MultiTranslator
    }
    -> Html Msg
viewAffinityBlock { mainCanton, otherCantons, color, primaryText, secondaryText, blockNumber, showMore, translator } =
    let
        mainCantonName =
            Tuple.first mainCanton
                |> Canton.toFullName
                |> translator.string

        mainCantonScore =
            Tuple.second mainCanton |> truncateScore

        viewSecondaryAffinity canton score =
            let
                cantonName =
                    canton
                        |> Canton.toFullName
                        |> translator.string

                cantonScore =
                    truncateScore score
            in
            Html.li []
                [ Html.span
                    [ css [ Css.color color ] ]
                    [ Html.text cantonName ]
                , Html.text " "
                , Html.span []
                    [ Html.text (String.fromFloat cantonScore ++ "%") ]
                ]

        onlyIfShowMore =
            if showMore then
                Css.batch []

            else
                Css.batch [ Css.display Css.none ]
    in
    Html.div
        [ css
            [ Css.padding (Ui.spacing Ui.M)
            , Css.marginBottom (Ui.spacing Ui.M)
            , Css.border3 (Css.px 2) Css.solid color
            , Css.property "grid-column" (String.fromInt blockNumber)
            , Css.displayFlex
            , Css.flexFlow2 Css.column Css.noWrap
            , Ui.affinityBlockInSidebarBreakpoint
                [ Css.marginBottom (Ui.spacing Ui.L)
                , Css.padding (Ui.spacing Ui.L)
                ]
            ]
        ]
        [ Html.div
            [ css
                [ Css.marginBottom (Ui.spacing Ui.S)
                ]
            ]
            [ Html.span
                [ css
                    [ onlyIfShowMore
                    , Ui.affinityBlockInSidebarBreakpoint [ Css.display Css.unset ]
                    ]
                ]
                [ Html.text primaryText ]
            , Html.div
                [ css
                    [ Ui.headingStyle
                    , Css.fontSize (Css.em 1.3)
                    , Css.color color
                    , Ui.affinityBlockInSidebarBreakpoint
                        [ Css.marginTop (Ui.spacing Ui.M) ]
                    ]
                ]
                [ Html.text mainCantonName ]
            ]
        , Html.div
            [ css
                [ Css.batch
                    (if showMore then
                        [ Css.flex (Css.int 0) ]

                     else
                        [ Css.flex (Css.int 1), Css.displayFlex ]
                    )
                , Css.justifyContent Css.flexEnd
                , Css.flexDirection Css.column
                , Ui.affinityBlockInSidebarBreakpoint
                    [ Css.flex (Css.int 0), Css.display Css.unset ]
                ]
            ]
            [ Html.div [] [ Ui.progressBar mainCantonScore color ]
            , Html.div
                [ css
                    [ onlyIfShowMore
                    , Ui.affinityBlockInSidebarBreakpoint [ Css.display Css.unset ]
                    ]
                ]
                [ Html.div
                    [ css
                        [ Css.marginTop (Ui.spacing Ui.M) ]
                    ]
                    [ Html.text secondaryText ]
                , Html.ul
                    [ css
                        [ Css.paddingLeft Css.zero
                        , Css.listStyleType Css.none
                        , Css.marginBottom Css.zero
                        , Css.marginTop (Ui.spacing Ui.M)
                        ]
                    ]
                    (otherCantons
                        |> List.map (\( canton, score ) -> viewSecondaryAffinity canton score)
                    )
                ]
            ]
        ]


viewAffinitiesBlock : Translation.MultiTranslator -> Bool -> List ( Canton, Float ) -> Html Msg
viewAffinitiesBlock translator showMore affinities =
    let
        mostAffineBlock =
            case List.take 3 affinities of
                [] ->
                    Html.text ""

                x :: xs ->
                    viewAffinityBlock
                        { mainCanton = x
                        , otherCantons = xs
                        , color = Ui.colors.secondary
                        , primaryText = Canton.cantonParticle (Tuple.first x) |> Translation.MostAffineCanton |> translator.msgId
                        , secondaryText = translator.msgId Translation.MostAffineCantons
                        , blockNumber = 1
                        , showMore = showMore
                        , translator = translator
                        }

        leastAffineBlock =
            case List.reverse affinities |> List.take 3 of
                [] ->
                    Html.text ""

                x :: xs ->
                    viewAffinityBlock
                        { mainCanton = x
                        , otherCantons = xs
                        , color = Ui.colors.primary
                        , primaryText = Canton.cantonParticle (Tuple.first x) |> Translation.LeastAffineCanton |> translator.msgId
                        , secondaryText = translator.msgId Translation.LeastAffineCantons
                        , blockNumber = 2
                        , showMore = showMore
                        , translator = translator
                        }

        showMoreButton =
            if List.isEmpty affinities then
                Html.text ""

            else
                Html.button
                    [ css
                        [ Css.textTransform Css.uppercase
                        , Css.backgroundColor Css.transparent
                        , Css.borderStyle Css.none
                        , Css.color
                            (if showMore then
                                Ui.colors.primary

                             else
                                Ui.colors.secondary
                            )
                        , Css.display Css.block
                        , Css.width (Css.pct 100)
                        , Css.padding2 (Ui.spacing Ui.S) Css.zero
                        , Css.cursor Css.pointer
                        , Ui.affinityBlockInSidebarBreakpoint
                            [ Css.display Css.none ]
                        ]
                    , onClick ClickedToggleShowMore
                    ]
                    (if not showMore then
                        [ Ui.chevronUp 32
                        , Html.div [ css [ Css.marginTop (Ui.spacing Ui.S) ] ] [ Html.text <| translator.msgId Translation.MoreDetails ]
                        ]

                     else
                        [ Html.div [ css [ Css.marginBottom (Ui.spacing Ui.S) ] ] [ Html.text <| translator.msgId Translation.LessDetails ]
                        , Ui.chevronDown 32
                        ]
                    )
    in
    Html.div [ css [ Css.padding2 (Ui.spacing Ui.M) Css.zero ] ]
        [ Html.div
            [ css
                [ Css.property "display" "grid"
                , Css.property "grid-template-columns" "1fr 1fr"
                , Css.property "gap" (Ui.spacing Ui.M |> .value)
                , Ui.affinityBlockInSidebarBreakpoint
                    [ Css.display Css.unset
                    , Css.property "gap" "unset"
                    , Css.property "grid-template-columns" "unset"
                    ]
                ]
            ]
            [ mostAffineBlock
            , leastAffineBlock
            ]
        , showMoreButton
        ]


viewVotationGroup : Translation.MultiTranslator -> Date -> List VotationObject -> Dict VotationObjectId VoteChoice -> Html Msg
viewVotationGroup translator date votationObjects votationChoices =
    Html.div
        [ css [ Css.marginBottom (Ui.spacing Ui.L) ] ]
        [ Ui.heading2 []
            [ Html.text
                (translator.msgId (Translation.VotationFrom (Date.humanizeDate translator.language date)))
            ]
        , Html.div []
            (votationObjects
                |> List.map
                    (\v -> Html.Styled.Lazy.lazy3 viewVotationObject translator v (Dict.get v.id votationChoices))
            )
        ]


viewVotationObject : Translation.MultiTranslator -> VotationObject -> Maybe VoteChoice -> Html Msg
viewVotationObject translator votationObject maybeChoice =
    let
        radioName =
            "vote_" ++ String.fromInt votationObject.id

        viewVotationObjectCheckbox votationChoice label =
            Ui.radioThatLooksLikeACheckbox
                { name = radioName
                , label = label
                , isChecked = maybeChoice == Just votationChoice
                , msg = ClickedVoteChoice votationChoice votationObject
                }
    in
    Html.div [ class "votation-object" ]
        [ Html.div
            [ class "votation-object__name" ]
            [ Html.text votationObject.name
            ]
        , Html.div
            [ class "votation-object__choices"
            ]
            [ Html.div
                [ class "votation-object__choice" ]
                [ viewVotationObjectCheckbox Yes (translator.msgId Translation.Yes) ]
            , Html.div
                [ class "votation-object__choice" ]
                [ viewVotationObjectCheckbox No (translator.msgId Translation.No) ]
            ]
        ]



-- HELPERS


truncateToDigits : Int -> Float -> Float
truncateToDigits nbDigits number =
    number
        * toFloat (10 ^ nbDigits)
        |> truncate
        |> toFloat
        |> (\v -> v / toFloat (10 ^ nbDigits))


truncateScore : Float -> Float
truncateScore =
    truncateToDigits 2


sortByReversed : (a -> comparable) -> List a -> List a
sortByReversed derive =
    List.sortWith (\a b -> compare (derive b) (derive a))


cantonsByAffinity : IndexedVotationObjects -> Dict VotationObjectId VoteChoice -> List ( Canton, Float )
cantonsByAffinity votationObjects choices =
    let
        cantonsScores : VotationObjectId -> VoteChoice -> Dict String Float
        cantonsScores votationObjectId voteChoice =
            Dict.get votationObjectId votationObjects
                |> Maybe.map (.results >> pointsByCanton voteChoice)
                |> Maybe.withDefault Dict.empty

        sumScores : Dict String Float -> Dict String Float -> Dict String Float
        sumScores scores1 scores2 =
            Dict.merge
                (\k a dict -> Dict.insert k a dict)
                (\k a b dict -> Dict.insert k (a + b) dict)
                (\k b dict -> Dict.insert k b dict)
                scores1
                scores2
                Dict.empty
    in
    choices
        |> Dict.map cantonsScores
        |> Dict.values
        |> List.foldl sumScores Dict.empty
        |> Dict.toList
        |> List.filterMap
            (\( cantonStr, score ) ->
                Canton.toCanton cantonStr
                    |> Maybe.map (\canton -> ( canton, score ))
            )
        |> sortByReversed Tuple.second


pointsByCanton : VoteChoice -> Dict String { yes : Int, no : Int } -> Dict String Float
pointsByCanton voteChoice resultsByCanton =
    let
        score yes no =
            case voteChoice of
                Yes ->
                    toFloat yes / (toFloat yes + toFloat no)

                No ->
                    toFloat no / (toFloat yes + toFloat no)
    in
    resultsByCanton
        |> Dict.map (\_ v -> score v.yes v.no)


toIndexedVotationObjects : List VotationObject -> Dict VotationObjectId VotationObject
toIndexedVotationObjects votationObjects =
    votationObjects
        |> List.map (\votationObject -> ( votationObject.id, votationObject ))
        |> Dict.fromList



-- JSON


votationResultsDecoder : Translation.Language -> D.Decoder (List VotationObject)
votationResultsDecoder language =
    let
        resultsDecoder =
            D.dict
                (D.map2 (\yes no -> { yes = yes, no = no })
                    (D.field "yes" D.int)
                    (D.field "no" D.int)
                )

        languageCode =
            case language of
                Translation.French ->
                    "fr"

                Translation.German ->
                    "de"
    in
    D.list
        (D.map4 VotationObject
            (D.field "id" D.int)
            (D.at [ "titles", languageCode ] D.string)
            (D.field "date" Date.dateDecoder)
            (D.field "results" resultsDecoder)
        )



-- HTTP


fetchVotationResults : Translation.Language -> Cmd Msg
fetchVotationResults language =
    Http.get { url = "/results.json", expect = Http.expectJson GotResultsByCanton (votationResultsDecoder language) }



-- MAIN


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view >> Html.toUnstyled
        , update = update
        , subscriptions = \_ -> Sub.none
        }
