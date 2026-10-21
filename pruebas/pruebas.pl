:- encoding(utf8).
/* ============================================================================
   pruebas/pruebas.pl               >>> RESPONSABLE: ALE <<<
   CASOS DE PRUEBA AUTOMATICOS (la tabla de "Pruebas y validacion" del reporte)
   ============================================================================
   USO:   ?- correr_pruebas.     (imprime PASS/FAIL por caso y el total)

   FORMATO:
     caso(IdCaso, Entrada, ReglasEsperadas, ResultadoEsperado).

     IdCaso            : t01, t02... (en el reporte: T01, T02...)
     Entrada           : lista Variable-Valor, ej. [animo-bajo, energia-baja, ...]
     ReglasEsperadas   : IDs de reglas que deben dispararse, EN ORDEN DE DISPARO
     ResultadoEsperado : uno de
         ok(Emocion, perfil(E,A))
         incompleto
         invalido(Variable)        % se capturo un valor no permitido
         sin_emocion
         sin_perfil(Emocion)
         sin_canciones(perfil(E,A))

   TIPOS DE CASO QUE EL PROYECTO EXIGE (cubran todos):
     - normales (una por emocion y por objetivo)
     - datos invalidos         - datos incompletos
     - sin regla aplicable     - nueva consulta (limpiar y repetir)
   Cuando Osiel agregue reglas, hay que revisar que el caso "sin_emocion"
   siga siendo una combinacion no cubierta (si las reglas cubren todo, quiten
   el caso y expliquen en el reporte por que no existe).
   Las canciones elegidas son al azar entre las que cumplen el perfil, por eso
   la prueba compara emocion y perfil, no la cancion.
   ============================================================================ */

:- discontiguous caso/4.

caso(t01, [animo-bajo, energia-baja, tension-baja, contexto-relajarse, objetivo-acompanar],
     [r01, r31], ok(tristeza, perfil(baja, bajo))).
caso(t02, [animo-bajo, energia-baja, tension-baja, contexto-relajarse, objetivo-cambiar],
     [r01, r32], ok(tristeza, perfil(media, alto))).
caso(t03, [animo-bajo, energia-baja, tension-baja, contexto-dormir, objetivo-acompanar],
     [r01, r30], ok(tristeza, perfil(baja, neutro))).     % r30 gana por prioridad
caso(t04, [animo-neutro, energia-alta, tension-alta, contexto-estudiar, objetivo-cambiar],
     [r02, r33], ok(estres, perfil(baja, neutro))).
caso(t05, [animo-alto, energia-alta, tension-baja, contexto-fiesta, objetivo-acompanar],
     [r03, r34], ok(alegria, perfil(alta, alto))).
caso(t06, [animo-alto, energia-alta, tension-baja, contexto-fiesta, objetivo-cambiar],
     [r03], sin_perfil(alegria)).
caso(t07, [animo-neutro, energia-media, tension-media, contexto-estudiar, objetivo-acompanar],
     [], sin_emocion).
caso(t08, [animo-bajo, energia-baja],
     [], incompleto).
caso(t09, [animo-triste, energia-baja, tension-baja, contexto-relajarse, objetivo-acompanar],
     [], invalido(animo)).
caso(t10, [],
     [], incompleto).
% TODO Ale: un caso normal por cada emocion nueva (enojo, calma, motivacion),
%           un caso sin_canciones (si aplica) y uno de "nueva consulta".

% ---- Ejecucion ---------------------------------------------------------------
correr_pruebas :-
    format('~n===== PRUEBAS =====~n'),
    findall(Estado,
            ( caso(Id, Entrada, ReglasEsp, Esperado),
              ejecutar_caso(Id, Entrada, ReglasEsp, Esperado, Estado) ),
            Estados),
    include(==(pass), Estados, Pasan),
    length(Pasan, NPasan),
    length(Estados, Total),
    format('~n~w de ~w pruebas pasaron.~n', [NPasan, Total]),
    limpiar_hechos.

ejecutar_caso(Id, Entrada, ReglasEsp, Esperado, Estado) :-
    limpiar_hechos,
    capturar_entrada(Entrada, Invalida),
    (   Invalida = inv(Var)
    ->  Obtenido = invalido(Var)
    ;   ejecutar_consulta(R0),
        resumen(R0, Obtenido)
    ),
    findall(R, disparada(R), ReglasObt),
    (   Obtenido == Esperado, ReglasObt == ReglasEsp
    ->  Estado = pass, Etiqueta = 'PASS'
    ;   Estado = fail, Etiqueta = 'FAIL'
    ),
    upcase_atom(Id, IdMay),
    format('~w  ~w~n', [IdMay, Etiqueta]),
    format('    entrada : ~w~n', [Entrada]),
    format('    esperado: ~w  reglas ~w~n', [Esperado, ReglasEsp]),
    format('    obtenido: ~w  reglas ~w~n', [Obtenido, ReglasObt]).

capturar_entrada([], ninguna).
capturar_entrada([V-Val | Resto], Invalida) :-
    (   capturar(V, Val)
    ->  capturar_entrada(Resto, Invalida)
    ;   Invalida = inv(V)
    ).

resumen(ok(E, P, _), ok(E, P))        :- !.
resumen(incompleto(_), incompleto)    :- !.
resumen(Otro, Otro).
