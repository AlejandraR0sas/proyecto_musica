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

   ORDEN DE CARGA: conocimiento (reglas, canciones, aprendido) -> hechos ->
   motor -> explicacion -> aprendizaje -> musica -> interfaz -> pruebas.
   Las rutas son relativas a ESTE archivo.
   ============================================================================ */

:- [ '../conocimiento/reglas',
     '../conocimiento/canciones',
     '../conocimiento/aprendido',
     hechos,
     motor,
     explicacion,
     aprendizaje,
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

% ---- Modo consola (plan B, y referencia de comportamiento para la GUI) ------
consola :-
    format('~n=== Recomendador de musica por emocion ===~n'),
    consulta_consola,
    (   confirmar('~nQuieres hacer otra consulta? (s/n): ')
    ->  consola
    ;   format('Hasta luego!~n')
    ).

consulta_consola :-
    limpiar_hechos,
    preguntar_emocion_libre(Emocion),
    (   Emocion == ninguna
    ->  % camino 1: 5 preguntas, el sistema infiere la emocion
        forall(variable(V, _, _), preguntar_variable(V)),
        ejecutar_consulta(Resultado)
    ;   % camino 2: el usuario dijo su emocion, solo falta contexto y objetivo
        forall(member(V, [contexto, objetivo]), preguntar_variable(V)),
        declarar_emocion(Emocion),
        ejecutar_consulta_directa(Resultado)
    ),
    mostrar_resultado(Resultado).

% ---- Emocion escrita por el usuario (con aprendizaje) -------------------------
preguntar_emocion_libre(Emocion) :-
    emociones_conocidas(Lista),
    atomic_list_concat(Lista, ', ', Txt),
    format('~nComo te sientes? Escribe una emocion (conocidas: ~w).~n', [Txt]),
    format('Si escribes una que no conozco, te pedire ayuda para aprenderla.~n'),
    format('O presiona Enter para que te haga unas preguntas.~n> '),
    leer_atomo(Texto),
    (   Texto == ''
    ->  Emocion = ninguna
    ;   emocion_desde_texto(Texto, Emocion)
    ).

% Devuelve una emocion conocida (o recien aprendida) o 'ninguna'.
emocion_desde_texto(Texto, Emocion) :-
    normalizar(Texto, Nombre),
    (   resolver_emocion(Nombre, E)
    ->  Emocion = E
    ;   aprender_dialogo(Nombre, Emocion)
    ).

aprender_dialogo(Nombre, Emocion) :-
    format('~nNo conozco la emocion "~w". Ayudame a aprenderla.~n', [Nombre]),
    format('Si quisieras ACOMPANAR esa emocion, que musica te iria bien?~n'),
    preguntar_perfil(P1),
    format('Y si quisieras CAMBIARLA, que musica te ayudaria?~n'),
    preguntar_perfil(P2),
    (   catch(aprender_emocion(Nombre, P1, P2), Error,
              ( print_message(error, Error), fail ))
    ->  format('~nListo, aprendi "~w" y la guarde en conocimiento/aprendido.pl.~n',
               [Nombre]),
        Emocion = Nombre
    ;   format('~nNo pude guardar esa emocion (nombre no valido).~n'),
        Emocion = ninguna
    ).

preguntar_perfil(perfil(E, A)) :-
    variable(energia, ValoresE, _),
    variable(animo,   ValoresA, _),
    preguntar_valor('Energia de la musica', ValoresE, E),
    preguntar_valor('Animo de la musica',   ValoresA, A).

preguntar_valor(Pregunta, Valores, Valor) :-
    atomic_list_concat(Valores, ' / ', Opciones),
    format('  ~w (~w): ', [Pregunta, Opciones]),
    leer_atomo(R),
    (   memberchk(R, Valores)
    ->  Valor = R
    ;   format('  Valor no valido.~n'),
        preguntar_valor(Pregunta, Valores, Valor)
    ).

% ---- Preguntas normales ------------------------------------------------------
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
    format('~nEmocion: ~w~n', [Emocion]),
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
    mostrar_explicacion,
    ofrecer_decir_emocion.
mostrar_resultado(sin_perfil(Emocion)) :-
    !,
    format('~nDetecte la emocion "~w", pero no hay una regla para elegir musica con tu objetivo.~n',
           [Emocion]),
    mostrar_explicacion.
mostrar_resultado(sin_canciones(perfil(E, A))) :-
    !,
    format('~nHay un perfil (energia ~w, animo ~w) pero no hay canciones en el catalogo.~n',
           [E, A]),
    mostrar_explicacion.

% Cuando el sistema no logra inferir la emocion, se la pide al usuario
% (y la aprende si no la conoce).
ofrecer_decir_emocion :-
    format('~nSi me dices con una palabra como te sientes, lo intento (Enter para omitir): '),
    leer_atomo(Texto),
    (   Texto == ''
    ->  true
    ;   emocion_desde_texto(Texto, Emocion),
        Emocion \== ninguna
    ->  declarar_emocion(Emocion),
        ejecutar_consulta_directa(Resultado),
        mostrar_resultado(Resultado)
    ;   true
    ).

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