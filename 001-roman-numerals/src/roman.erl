-module(roman).
-author('Adam Rutkowski <hq@mtod.org>').
-export([to_arabic/1]).
-export([to_roman/1]).

%% http://codingdojo.org/cgi-bin/wiki.pl?KataRomanNumerals

-ifdef(TEST).
-include_lib("proper/include/proper.hrl").
-include_lib("eunit/include/eunit.hrl").
-endif.

-define(r(X), primitive(roman, X)).
-define(a(X), primitive(arabic, X)).

-type roman_prim()    :: 73 | 86 | 88 | 76 | 67 | 68 | 77.
-type arabic_prim()   :: 1  | 5 | 50 | 100 | 500 | 1000.
-type arabic_number() :: 1..3000.
-type roman_number()  :: list(roman_prim()).

-spec to_arabic(roman_number()) -> arabic_number().
to_arabic([ ])            -> 0;
to_arabic([ L ])          -> ?r(L);
to_arabic([ X, Y | Rest]) -> decode(?r(X), ?r(Y)) + to_arabic([Y|Rest]).

-spec to_roman(arabic_number()) -> roman_number().
to_roman(0)->
    [];
to_roman(X) when X >= 1  andalso  X < 10 ->
    encode(X, [ ?a(N) || N <- [1, 5, 10 ] ]);
to_roman(X) when X >= 10, X < 100 ->
    encode(X div 10 , [ ?a(N) || N <- [10, 50, 100] ]) ++ to_roman(X rem 10);
to_roman(X) when X >= 100, X < 1000 ->
    encode(X div 100, [ ?a(N) || N <- [100, 500, 1000] ]) ++ to_roman(X rem 100);
to_roman(X) when X >= 1000, X =< 3000 ->
    [ ?a(1000) | to_roman(X - 1000) ].

-spec encode(arabic_prim(), [roman_prim()]) -> [roman_prim()].
encode(1, [X, _, _]) -> [X];
encode(2, [X, _, _]) -> [X, X];
encode(3, [X, _, _]) -> [X, X, X];
encode(4, [X, Y, _]) -> [X, Y];
encode(5, [_, X, _]) -> [X];
encode(6, [X, Y, _]) -> [Y, X];
encode(7, [X, Y, _]) -> [Y, X, X];
encode(8, [X, Y, _]) -> [Y, X, X, X];
encode(9, [X, _, Y]) -> [X, Y].

-spec decode(non_neg_integer(), non_neg_integer()) -> integer().
decode(X, Y) when X < Y -> -X;
decode(X, _)            -> X.

-spec primitive(roman,  roman_prim())   -> arabic_prim();
               (arabic, arabic_prim())  -> roman_prim().
primitive(roman, $I)    -> 1;
primitive(roman, $V)    -> 5;
primitive(roman, $X)    -> 10;
primitive(roman, $L)    -> 50;
primitive(roman, $C)    -> 100;
primitive(roman, $D)    -> 500;
primitive(roman, $M)    -> 1000;

primitive(arabic, 1)    -> $I;
primitive(arabic, 5)    -> $V;
primitive(arabic, 10)   -> $X;
primitive(arabic, 50)   -> $L;
primitive(arabic, 100)  -> $C;
primitive(arabic, 500)  -> $D;
primitive(arabic, 1000) -> $M;

primitive(_, _)         -> erlang:error(badarg).

-ifdef(TEST).

prop_encode_decode() ->
    ?FORALL(Num, arabic_number(),
          begin
            Encoded = to_roman(Num),
            to_arabic(Encoded) =:= Num
          end).

qc() ->
    proper:quickcheck(?MODULE:prop_encode_decode(),
                      [{numtests, 1000}]).

proper_test() ->
    ?assertEqual(true, qc()).

roman_test() ->
    ?assertEqual("X"        , to_roman(10)),
    ?assertEqual("III"      , to_roman(3)),
    ?assertEqual("IV"       , to_roman(4)),
    ?assertEqual("VI"       , to_roman(6)),
    ?assertEqual("L"        , to_roman(50)),
    ?assertEqual("C"        , to_roman(100)),
    ?assertEqual("LI"       , to_roman(51)),
    ?assertEqual("XCIX"     , to_roman(99)),
    ?assertEqual("LXXIX"    , to_roman(79)),
    ?assertEqual("M"        , to_roman(1000)),
    ?assertEqual("MCMXC"    , to_roman(1990)),
    ?assertEqual("MMM"      , to_roman(3000)),
    ?assertEqual("MMCMXCIX" , to_roman(2999)).

arabic_test() ->
    ?assertEqual(10   , to_arabic("X")),
    ?assertEqual(11   , to_arabic("XI")),
    ?assertEqual(1    , to_arabic("I")),
    ?assertEqual(4    , to_arabic("IV")),
    ?assertEqual(51   , to_arabic("LI")),
    ?assertEqual(99   , to_arabic("XCIX")),
    ?assertEqual(19   , to_arabic("XIX")),
    ?assertEqual(79   , to_arabic("LXXIX")),
    ?assertEqual(1000 , to_arabic("M")),
    ?assertEqual(1990 , to_arabic("MCMXC")),
    ?assertEqual(3000 , to_arabic("MMM")),
    ?assertEqual(2999 , to_arabic("MMCMXCIX")).

-endif.
