
:- encoding(utf8).
:- use_module(library(www_browser)).
:- use_module(library(uri)).

% ============================================================
% REPRESENTACION DE CANCIONES
% cancion(Id, Titulo, Artista, Genero, Energia, Animo, Idioma, Enlace)
% ============================================================

texto_cancion(
    cancion(_, Titulo, Artista, Genero, Energia, Animo, Idioma, _),
    Texto
) :-
    format(
        atom(Texto),
        '~w - ~w | Genero: ~w | Idioma: ~w | Energia: ~w | Animo: ~w',
        [Titulo, Artista, Genero, Idioma, Energia, Animo]
    ).

% ============================================================
% REPRODUCCION
% ============================================================

reproducir(
    cancion(_, Titulo, Artista, _, _, _, _, EnlaceOriginal)
) :-
    obtener_enlace_valido(
        Titulo,
        Artista,
        EnlaceOriginal,
        EnlaceFinal
    ),
    (
        catch(www_open_url(EnlaceFinal), _, fail)
    ->
        true
    ;
        format(
            '~nNo pude abrir el navegador automaticamente.~nEnlace: ~w~n',
            [EnlaceFinal]
        )
    ).

reproducir_todas([]).

reproducir_todas([Cancion|Resto]) :-
    reproducir(Cancion),
    reproducir_todas(Resto).

% ============================================================
% ENLACES
% ============================================================

obtener_enlace_valido(_, _, Enlace, Enlace) :-
    nonvar(Enlace),
    atom(Enlace),
    Enlace \== '',
    sub_atom(Enlace, 0, 8, _, 'https://'),
    !.

obtener_enlace_valido(Titulo, Artista, _, Enlace) :-
    format(atom(Busqueda), '~w ~w', [Titulo, Artista]),
    uri_encoded(query_value, Busqueda, Codificada),
    format(
        atom(Enlace),
        'https://www.youtube.com/results?search_query=~w',
        [Codificada]
    ).

% ============================================================
% CONSTRUCCION DE UNA CANCION SUGERIDA
% Compatible con el formato usado por el proyecto.
% ============================================================

crear_cancion_sugerida(
    Titulo,
    Artista,
    Genero,
    Idioma,
    cancion(
        sugerida,
        Titulo,
        Artista,
        Genero,
        media,
        neutro,
        Idioma,
        ''
    )
) :-
    maplist(atom, [Titulo, Artista, Genero, Idioma]).
