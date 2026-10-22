:- encoding(utf8).
/* ============================================================================
   src/aprendizaje.pl               >>> RESPONSABLE: ALE <<<
   APRENDIZAJE DE EMOCIONES NUEVAS (la base de conocimientos crece sola)
   ============================================================================
   IDEA (como el ejemplo "pais -> comida tipica"): si el usuario escribe una
   emocion que el sistema no conoce, el sistema lo reconoce, pregunta que
   musica le corresponde, la GUARDA en conocimiento/aprendido.pl y a partir de
   ahi ya la conoce (tambien en futuras ejecuciones).

   QUE SE GUARDA por cada emocion nueva (3 tipos de hechos):
     catalogo_emocion(nostalgia, 'Emocion aprendida del usuario.')
     regla(r60, [emocion(nostalgia), objetivo(acompanar)], perfil(baja, bajo))
     regla(r61, [emocion(nostalgia), objetivo(cambiar)],   perfil(media, alto))
     descripcion(r60, '...'), descripcion(r61, '...')
   Asi el motor y la explicacion funcionan SIN cambios: son reglas normales.

   FLUJO "EMOCION DIRECTA" (el usuario dice la emocion en vez de contestar 5
   preguntas): solo se piden contexto y objetivo, y se llama
   ejecutar_consulta_directa/1 (en motor.pl) en lugar de ejecutar_consulta/1.

   PREDICADOS PUBLICOS (la consola ya los usa; Antulio los usa en la GUI):
     normalizar(+Texto, -Atomo)         : 'Estoy Triste' -> estoy_triste, sin acentos
     resolver_emocion(+Nombre, -Emocion): true si Nombre es una emocion conocida
                                          o sinonimo (sinonimo/2 en reglas.pl).
                                          FALLA si no la conoce -> hay que aprenderla.
     emociones_conocidas(-Lista)
     aprender_emocion(+Nombre, +PerfilAcompanar, +PerfilCambiar)
                                        : registra en memoria y guarda en disco.
                                          Falla si el nombre no es valido, ya
                                          existe, o el perfil tiene valores malos.
         PerfilX = perfil(Energia, Animo), ej. perfil(baja, bajo)
     registrar_emocion/3                : igual pero SOLO en memoria (pruebas)
     olvidar_emocion(+Nombre)           : borra de MEMORIA (no edita el archivo)
     declarar_emocion(+Emocion)         : marca la emocion que dijo el usuario

   EJEMPLO:
     ?- resolver_emocion(nostalgia, E).                 % false (no la conoce)
     ?- aprender_emocion(nostalgia, perfil(baja,bajo), perfil(media,alto)).
     ?- resolver_emocion(nostalgia, E).                 % E = nostalgia
   ============================================================================ */

:- dynamic dir_aprendizaje/1.
:- prolog_load_context(directory, D), assertz(dir_aprendizaje(D)).

% ---- Normalizacion de texto ------------------------------------------------
normalizar(Texto, Atomo) :-
    text_to_string(Texto, S0),
    string_lower(S0, S1),
    normalize_space(string(S2), S1),
    string_chars(S2, Cs0),
    maplist(limpiar_char, Cs0, Cs),
    string_chars(S3, Cs),
    atom_string(Atomo, S3).

limpiar_char(' ', '_') :- !.
limpiar_char(C, L) :-
    (   acento(C, L0) -> L = L0 ; L = C ).

acento('á', a). acento('é', e). acento('í', i). acento('ó', o).
acento('ú', u). acento('ü', u). acento('ñ', n).

% ---- Consulta de emociones --------------------------------------------------
resolver_emocion(Nombre, Emocion) :-
    (   catalogo_emocion(Nombre, _)
    ->  Emocion = Nombre
    ;   sinonimo(Nombre, Canonica),
        catalogo_emocion(Canonica, _)
    ->  Emocion = Canonica
    ).

emociones_conocidas(Lista) :-
    findall(E, catalogo_emocion(E, _), Lista).

declarar_emocion(Emocion) :-
    retractall(emocion_declarada(_)),
    assertz(emocion_declarada(Emocion)).

% ---- Validaciones ------------------------------------------------------------
nombre_valido(Nombre) :-
    atom(Nombre),
    Nombre \== '',
    forall(sub_atom(Nombre, _, 1, _, C),
           ( char_type(C, alnum) ; C == '_' )).

perfil_valido(perfil(E, A)) :-
    variable(energia, ValoresE, _),
    variable(animo,   ValoresA, _),
    memberchk(E, ValoresE),
    memberchk(A, ValoresA).

% ---- Aprender ------------------------------------------------------------------
aprender_emocion(Nombre, P1, P2)  :- agregar_emocion(disco,   Nombre, P1, P2).
registrar_emocion(Nombre, P1, P2) :- agregar_emocion(memoria, Nombre, P1, P2).

agregar_emocion(Modo, Nombre, perfil(E1, A1), perfil(E2, A2)) :-
    nombre_valido(Nombre),
    \+ catalogo_emocion(Nombre, _),
    perfil_valido(perfil(E1, A1)),
    perfil_valido(perfil(E2, A2)),
    agregar(Modo, catalogo_emocion(Nombre, 'Emocion aprendida del usuario.')),
    agregar_regla(Modo, Nombre, acompanar, perfil(E1, A1)),
    agregar_regla(Modo, Nombre, cambiar,   perfil(E2, A2)).

agregar_regla(Modo, Nombre, Objetivo, perfil(E, A)) :-
    nuevo_id_regla(Id),
    agregar(Modo, regla(Id, [emocion(Nombre), objetivo(Objetivo)], perfil(E, A))),
    format(atom(Desc),
           'Regla aprendida: para ~w con objetivo ~w conviene musica de energia ~w y animo ~w.',
           [Nombre, Objetivo, E, A]),
    agregar(Modo, descripcion(Id, Desc)).

% Las reglas aprendidas usan IDs desde r60.
nuevo_id_regla(Id) :-
    findall(N,
            ( regla(I, _, _),
              sub_atom(I, 0, 1, _, r),
              sub_atom(I, 1, _, 0, NumAtom),
              atom_number(NumAtom, N) ),
            Ns),
    max_list([59 | Ns], Max),
    N1 is Max + 1,
    atom_concat(r, N1, Id).

agregar(Modo, Hecho) :-
    assertz(Hecho),
    (   Modo == disco -> guardar_en_archivo(Hecho) ; true ).

archivo_aprendido(Ruta) :-
    dir_aprendizaje(D),
    atomic_list_concat([D, '/../conocimiento/aprendido.pl'], Ruta).

guardar_en_archivo(Hecho) :-
    archivo_aprendido(Ruta),
    setup_call_cleanup(
        open(Ruta, append, Stream, [encoding(utf8)]),
        format(Stream, '~q.~n', [Hecho]),
        close(Stream)).

% ---- Olvidar (solo memoria; para pruebas) ----------------------------------
olvidar_emocion(Nombre) :-
    forall(( regla(Id, Condiciones, _), memberchk(emocion(Nombre), Condiciones) ),
           ( retract(regla(Id, _, _)), retractall(descripcion(Id, _)) )),
    retractall(catalogo_emocion(Nombre, _)).