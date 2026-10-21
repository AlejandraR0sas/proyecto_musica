:- encoding(utf8).
/* ============================================================================
   src/main.pl                      >>> RESPONSABLE: ALE <<<
   PUNTO DE ENTRADA: carga todos los modulos y define el modo consola.
   ============================================================================
   COMO CORRER (desde la carpeta raiz del proyecto):
       swipl src/main.pl
       ?- iniciar.            % GUI si existe, si no, consola
       ?- consola.            % fuerza el modo consola
       ?- correr_pruebas.     % corre todos los casos de pruebas/pruebas.pl

   ORDEN DE CARGA: conocimiento -> hechos -> motor -> explicacion -> musica ->
   interfaz -> pruebas. Las rutas son relativas a ESTE archivo.
   ============================================================================ */

:- [ '../conocimiento/reglas',
     '../conocimiento/canciones',
     hechos,
     motor,
     explicacion,
     musica,
     interfaz,
     '../pruebas/pruebas' ].

% ---- Arranque --------------------------------------------------------------
iniciar :-
    (   catch(iniciar_gui, Error, ( print_message(warning, Error), fail ))
    ->  true
    ;   format('~nUsando modo consola.~n'),
        consola
    ).

% ---- Modo consola (plan B, y sirve para depurar sin GUI) -------------------
consola :-
    format('~n=== Recomendador de musica por emocion ===~n'),
    consulta_consola,
    (   confirmar('~nQuieres hacer otra consulta? (s/n): ')
    ->  consola
    ;   format('Hasta luego!~n')
    ).

consulta_consola :-
    limpiar_hechos,
    forall(variable(V, _, _), preguntar_variable(V)),
    ejecutar_consulta(Resultado),
    mostrar_resultado(Resultado).

preguntar_variable(V) :-
    variable(V, Valores, Pregunta),
    atomic_list_concat(Valores, ' / ', Opciones),
    format('~n~w~n  Opciones: ~w~n> ', [Pregunta, Opciones]),
    leer_atomo(Respuesta),
    (   capturar(V, Respuesta)
    ->  true
    ;   mensaje_invalido(V, Respuesta, Mensaje),
        format('~w~n', [Mensaje]),
        preguntar_variable(V)
    ).

% Lee una linea y la devuelve como atomo en minusculas, sin espacios extra.
leer_atomo(Atomo) :-
    read_line_to_string(user_input, Linea),
    (   Linea == end_of_file
    ->  halt
    ;   normalize_space(string(Limpia), Linea),
        string_lower(Limpia, Minus),
        atom_string(Atomo, Minus)
    ).

confirmar(Prompt) :-
    format(Prompt),
    leer_atomo(R),
    memberchk(R, [s, si, y, yes]).

% ---- Presentacion de resultados -------------------------------------------
mostrar_resultado(ok(Emocion, perfil(E, A), Canciones)) :-
    !,
    format('~nEmocion detectada: ~w~n', [Emocion]),
    format('Perfil musical: energia ~w, animo ~w~n', [E, A]),
    format('~nTe recomiendo:~n'),
    forall(nth1(N, Canciones, C),
           ( texto_cancion(C, T), format('  ~w) ~w~n', [N, T]) )),
    mostrar_explicacion,
    ofrecer_reproduccion(Canciones).
mostrar_resultado(incompleto(Faltantes)) :-
    !,
    format('~nFaltan datos por responder: ~w~n', [Faltantes]).
mostrar_resultado(sin_emocion) :-
    !,
    format('~nNo pude determinar tu emocion con esas respuestas (ninguna regla aplica).~n'),
    mostrar_explicacion.
mostrar_resultado(sin_perfil(Emocion)) :-
    !,
    format('~nDetecte la emocion "~w", pero no hay una regla para elegir musica con tu objetivo.~n', [Emocion]),
    mostrar_explicacion.
mostrar_resultado(sin_canciones(perfil(E, A))) :-
    !,
    format('~nHay un perfil (energia ~w, animo ~w) pero no hay canciones en el catalogo.~n', [E, A]),
    mostrar_explicacion.

mostrar_explicacion :-
    explicar(Texto),
    format('~n--- Por que? ---~n~w~n', [Texto]).

ofrecer_reproduccion(Canciones) :-
    format('~nEscribe el numero de la cancion para abrirla (o Enter para omitir): '),
    leer_atomo(R),
    (   atom_number(R, N), nth1(N, Canciones, C)
    ->  reproducir(C)
    ;   true
    ).

:- format('~nProyecto cargado. Escribe  ?- iniciar.   o   ?- correr_pruebas.~n').
