module Ui exposing
    ( Size(..)
    , affinityBlockInSidebarBreakpoint
    , buttonPrimary
    , chevronDown
    , chevronUp
    , colors
    , heading1
    , heading2
    , headingStyle
    , listInline
    , loader
    , logoInlineBreakpoint
    , mainContainer
    , progressBar
    , radioThatLooksLikeACheckbox
    , spacing
    )

import Css
import Css.Global
import Css.Media
import Css.Transitions
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes exposing (checked, class, css, type_)
import Html.Styled.Events exposing (onClick)
import Svg.Styled as Svg
import Svg.Styled.Attributes as SvgAttributes


type Size
    = XS
    | S
    | M
    | L
    | XL
    | XXL



-- BREAKPOINTS


minWidthBreakpoint : { compatible | value : String, absoluteLength : Css.Compatible } -> List Css.Style -> Css.Style
minWidthBreakpoint minWidth =
    Css.Media.withMedia [ Css.Media.all [ Css.Media.minWidth minWidth ] ]


affinityBlockInSidebarBreakpoint : List Css.Style -> Css.Style
affinityBlockInSidebarBreakpoint =
    minWidthBreakpoint (Css.px 770)


votationChoicesInlineBreakpoint : List Css.Style -> Css.Style
votationChoicesInlineBreakpoint =
    minWidthBreakpoint (Css.px 600)


logoInlineBreakpoint : List Css.Style -> Css.Style
logoInlineBreakpoint =
    minWidthBreakpoint (Css.px 600)



-- STYLES


headingStyle : Css.Style
headingStyle =
    Css.batch
        [ Css.marginTop Css.zero
        , Css.marginBottom Css.zero
        , Css.fontFamilies [ "BebasNeue" ]
        , Css.letterSpacing (Css.px 1)
        , Css.lineHeight (Css.em 1.2)
        ]


spacing : Size -> Css.Px
spacing size =
    let
        pixelSize =
            case size of
                XS ->
                    2

                S ->
                    4

                M ->
                    8

                L ->
                    16

                XL ->
                    24

                XXL ->
                    40
    in
    Css.px pixelSize


colors : { primary : Css.Color, secondary : Css.Color, secondaryLight : Css.Color, secondaryDark : Css.Color }
colors =
    { primary = Css.hex "db2416"
    , secondary = Css.hex "32CD90"
    , secondaryLight = Css.hex "61daaa"
    , secondaryDark = Css.hex "1cc07f"
    }



-- ELEMENTS


mainContainer : List (Html.Attribute msg) -> List (Html msg) -> Html msg
mainContainer attributes children =
    let
        defaultAttributes =
            css
                [ Css.boxShadow5 Css.zero Css.zero (Css.px 60) Css.zero (Css.rgba 0 0 0 0.6)
                , Css.maxWidth (Css.px 1200)
                , Css.marginLeft Css.auto
                , Css.marginRight Css.auto
                , Css.backgroundColor (Css.hex "fff")
                , Css.Media.withMedia
                    [ Css.Media.all
                        [ Css.Media.minWidth (Css.px 1200) ]
                    ]
                    [ Css.marginTop (Css.px 20)
                    , Css.marginBottom (Css.px 20)
                    ]
                ]

        globalStyle =
            Css.Global.global
                [ Css.Global.typeSelector "body"
                    [ Css.backgroundColor (Css.hex "eee") ]
                , Css.Global.class "votation-object"
                    [ Css.borderBottom3 (Css.px 1) Css.solid (Css.hex "000")
                    , Css.lastChild [ Css.borderBottomWidth Css.zero ]
                    , votationChoicesInlineBreakpoint [ Css.displayFlex ]
                    ]
                , Css.Global.class "votation-object__name"
                    [ Css.paddingTop (spacing L)
                    , Css.paddingRight (spacing M)
                    , votationChoicesInlineBreakpoint
                        [ Css.borderRight3 (Css.px 1) Css.solid (Css.hex "000")
                        , Css.flex (Css.int 1)
                        , Css.paddingBottom (spacing L)
                        ]
                    ]
                , Css.Global.class "votation-object__choices"
                    [ Css.flexBasis (Css.px 150)
                    , Css.displayFlex
                    , Css.padding2 (spacing L) Css.zero
                    , Css.paddingLeft (spacing M)
                    ]
                , Css.Global.class "votation-object__choice"
                    [ Css.flexBasis (Css.pct 50)
                    , Css.textAlign Css.center
                    ]
                , Css.Global.class "checkradio"
                    [ Css.property "display" "grid"
                    , Css.property "grid-template-rows" "min-content auto"
                    , Css.property "row-gap" (spacing S |> .value)
                    , Css.color (Css.hex "666666")
                    ]
                , Css.Global.class "checkradio__input"
                    [ Css.property "display" "grid"
                    , Css.property "grid-template-areas" "checkbox"
                    , Css.Global.children
                        [ Css.Global.typeSelector "input"
                            [ Css.opacity Css.zero
                            , Css.width (Css.px 22)
                            , Css.height (Css.px 22)
                            , Css.property "grid-area" "checkbox"
                            , Css.focus
                                [ Css.Global.adjacentSiblings
                                    [ Css.Global.class "checkradio__control"
                                        [ Css.property "box-shadow" "0 0 0 2px #fff, 0 0 3px 3px currentColor"
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                , Css.Global.class "checkradio__control"
                    [ Css.border3 (Css.px 1) Css.solid Css.currentColor
                    , Css.width (Css.px 22)
                    , Css.height (Css.px 22)
                    , Css.display Css.inlineBlock
                    , Css.property "grid-area" "checkbox"
                    ]
                ]
    in
    Html.div (defaultAttributes :: attributes) (globalStyle :: children)


heading1 : List (Html.Attribute msg) -> List (Html msg) -> Html msg
heading1 attributes =
    Html.h1
        (css
            [ headingStyle
            , Css.fontSize (Css.em 2.2)
            , Css.lineHeight (Css.em 1.2)
            ]
            :: attributes
        )


heading2 : List (Html.Attribute msg) -> List (Html msg) -> Html msg
heading2 attributes =
    Html.h2
        (css
            [ headingStyle
            , Css.fontSize (Css.em 1.8)
            ]
            :: attributes
        )


progressBar : Float -> Css.Color -> Html msg
progressBar width backgroundColor =
    let
        minWidth =
            30

        barText =
            String.fromFloat width ++ "%"

        barPadding =
            Css.px 4
    in
    Html.div
        [ css
            [ Css.backgroundColor <| Css.hex "eeeeee"
            , Css.displayFlex
            ]
        ]
        [ Html.div
            [ css
                [ Css.textAlign Css.center
                , Css.backgroundColor backgroundColor
                , Css.color <| Css.hex "ffffff"
                , Css.overflow Css.hidden
                , Css.width <| Css.pct width
                , Css.padding2 barPadding Css.zero
                , Css.Transitions.transition [ Css.Transitions.width3 400 0 Css.Transitions.easeInOut ]
                ]
            ]
            [ if width > minWidth then
                Html.text barText

              else
                Html.text ""
            ]
        , if width > minWidth then
            Html.text ""

          else
            Html.div
                [ css
                    [ Css.padding2 barPadding Css.zero
                    , Css.color backgroundColor
                    , Css.marginLeft (spacing S)
                    ]
                ]
                [ Html.text barText ]
        ]


radioThatLooksLikeACheckbox :
    { name : String
    , label : String
    , isChecked : Bool
    , msg : msg
    }
    -> Html msg
radioThatLooksLikeACheckbox { name, label, isChecked, msg } =
    Html.label
        [ checked isChecked
        , class "checkradio"
        ]
        [ Html.span [] [ Html.text label ]
        , Html.span
            [ class "checkradio__input" ]
            [ Html.input
                [ type_ "radio"
                , onClick msg
                , Html.Styled.Attributes.name name
                ]
                []
            , Html.span
                [ class "checkradio__control" ]
                [ if isChecked then
                    crossIcon

                  else
                    Html.text ""
                ]
            ]
        ]


buttonPrimary : Css.Style
buttonPrimary =
    Css.batch
        [ Css.backgroundColor colors.secondary
        , Css.color (Css.hex "fff")
        , Css.padding (spacing L)
        , Css.borderStyle Css.none
        , Css.cursor Css.pointer
        , Css.hover [ Css.backgroundColor colors.secondaryLight ]
        , Css.active [ Css.backgroundColor colors.secondaryDark ]
        , Css.Transitions.transition [ Css.Transitions.backgroundColor3 120 0 Css.Transitions.easeInOut ]
        ]


listInline : Css.Length compatible units -> Css.Style
listInline spacing_ =
    Css.batch
        [ Css.displayFlex
        , Css.paddingLeft Css.zero
        , Css.listStyleType Css.none
        , Css.Global.children
            [ Css.Global.typeSelector "li"
                [ Css.padding2 Css.zero spacing_
                , Css.Global.adjacentSiblings
                    [ Css.Global.typeSelector "li" [ Css.borderLeft3 (Css.px 1) Css.solid Css.currentColor ]
                    ]
                , Css.firstChild [ Css.paddingLeft Css.zero ]
                , Css.lastChild [ Css.paddingRight Css.zero ]
                ]
            ]
        ]



-- ICONS


crossIcon : Html msg
crossIcon =
    let
        animationDuration =
            "0.2s"
    in
    Svg.svg [ SvgAttributes.viewBox "0 0 24 24" ]
        [ Svg.line
            [ SvgAttributes.x1 "0"
            , SvgAttributes.y1 "24"
            , SvgAttributes.x2 "0"
            , SvgAttributes.y2 "24"
            , SvgAttributes.stroke "black"
            , SvgAttributes.strokeWidth "2"
            ]
            [ Svg.animate
                [ SvgAttributes.attributeName "x2"
                , SvgAttributes.values "0;24"
                , SvgAttributes.dur animationDuration
                , SvgAttributes.fill "freeze"
                ]
                []
            , Svg.animate
                [ SvgAttributes.attributeName "y2"
                , SvgAttributes.values "24;0"
                , SvgAttributes.dur animationDuration
                , SvgAttributes.fill "freeze"
                ]
                []
            ]
        , Svg.line
            [ SvgAttributes.x1 "0"
            , SvgAttributes.y1 "0"
            , SvgAttributes.x2 "0"
            , SvgAttributes.y2 "0"
            , SvgAttributes.stroke "black"
            , SvgAttributes.strokeWidth "2"
            ]
            [ Svg.animate
                [ SvgAttributes.attributeName "x2"
                , SvgAttributes.values "0;24"
                , SvgAttributes.dur animationDuration
                , SvgAttributes.begin animationDuration
                , SvgAttributes.fill "freeze"
                ]
                []
            , Svg.animate
                [ SvgAttributes.attributeName "y2"
                , SvgAttributes.values "0;24"
                , SvgAttributes.dur animationDuration
                , SvgAttributes.begin animationDuration
                , SvgAttributes.fill "freeze"
                ]
                []
            ]
        ]


loader : Int -> Html msg
loader width =
    let
        animationValues1 =
            "20;45;57;80;64;32;66;45;64;23;66;13;64;56;34;34;2;23;76;79;20 "

        animationValues2 =
            "80;55;33;5;75;23;73;33;12;14;60;80"

        animationValues3 =
            "50;34;78;23;56;23;34;76;80;54;21;50"

        animationValues4 =
            "30;45;13;80;56;72;45;76;34;23;67;30"

        barAnimation animationValues duration =
            Svg.animate
                [ SvgAttributes.attributeName "width"
                , SvgAttributes.dur duration
                , SvgAttributes.values animationValues
                , SvgAttributes.repeatCount "indefinite"
                ]
                []
    in
    Svg.svg
        [ SvgAttributes.viewBox "0 0 80 55"
        , SvgAttributes.fill "currentColor"
        , String.fromInt width |> SvgAttributes.width
        ]
        [ Svg.rect
            [ SvgAttributes.width "20"
            , SvgAttributes.height "10"
            , SvgAttributes.rx "3"
            ]
            [ barAnimation animationValues1 "4.3s" ]
        , Svg.rect
            [ SvgAttributes.y "15"
            , SvgAttributes.width "80"
            , SvgAttributes.height "10"
            , SvgAttributes.rx "3"
            ]
            [ barAnimation animationValues2 "2s" ]
        , Svg.rect
            [ SvgAttributes.y "30"
            , SvgAttributes.width "50"
            , SvgAttributes.height "10"
            , SvgAttributes.rx "3"
            ]
            [ barAnimation animationValues3 "1.4s" ]
        , Svg.rect
            [ SvgAttributes.y "45"
            , SvgAttributes.width "30"
            , SvgAttributes.height "10"
            , SvgAttributes.rx "3"
            ]
            [ barAnimation animationValues4 "2s" ]
        ]


chevron : Int -> List (Svg.Attribute msg) -> Html msg
chevron width attributes =
    let
        strokeWidth =
            6
    in
    Svg.svg
        ([ SvgAttributes.viewBox "0 0 128 64"
         , SvgAttributes.width <| String.fromInt width
         , SvgAttributes.fill "currentColor"
         ]
            ++ attributes
        )
        [ Svg.line
            [ SvgAttributes.x1 "0"
            , SvgAttributes.y1 "0"
            , SvgAttributes.x2 "64"
            , SvgAttributes.y2 "64"
            , SvgAttributes.strokeLinecap "round"
            , SvgAttributes.strokeWidth <| String.fromInt strokeWidth
            , SvgAttributes.stroke "currentColor"
            ]
            []
        , Svg.line
            [ SvgAttributes.x1 "128"
            , SvgAttributes.y1 "0"
            , SvgAttributes.x2 "64"
            , SvgAttributes.y2 "64"
            , SvgAttributes.strokeLinecap "round"
            , SvgAttributes.strokeWidth <| String.fromInt strokeWidth
            , SvgAttributes.stroke "currentColor"
            ]
            []
        ]


chevronDown : Int -> Html msg
chevronDown width =
    chevron width []


chevronUp : Int -> Html msg
chevronUp width =
    chevron width [ SvgAttributes.css [ Css.transform (Css.rotate (Css.deg 180)) ] ]
