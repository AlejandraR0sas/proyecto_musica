:- encoding(utf8).
/* ============================================================================
   src/motor.pl                     >>> RESPONSABLE: ALE <<<
   MOTOR DE INFERENCIA (encadenamiento HACIA ADELANTE)
   ============================================================================
   POR QUE ENCADENAMIENTO HACIA ADELANTE (para el reporte):
   Partimos de DATOS (las respuestas del usuario) y no de una meta fija:
   las respuestas permiten inferir la emocion y, con ella, el perfil musical y
   las canciones. Es un proceso dirigido por los datos, en dos etapas
   encadenadas (respuestas -> emocion -> perfil -> canciones).

   ALGORITMO:
     1. Busca la PRIMERA regla (en orden del archivo) que:
          - no se haya disparado ya,
          - tenga todas sus condiciones en la memoria de trabajo,
          - cuya conclusion no este ya en memoria,
          - y que no choque con una conclusion UNICA ya existente.
     2. La dispara: agrega la conclusion como hecho y registra disparada(Id).
     3. Repite hasta que ninguna regla aplique (punto fijo).
   Como siempre se toma la primera regla aplicable, ORDEN EN ARCHIVO = PRIORIDAD.

   CONCLUSIONES UNICAS: solo puede haber un emocion(_) y un perfil(_,_) por
   consulta (resolucion de conflictos: gana la regla mas arriba).

   PREDICADOS PUBLICOS:
     inferir                    : corre el motor sobre lo que haya en memoria
     recomendar(-Canciones)     : hasta 3 canciones (al azar) que cumplen perfil
     ejecutar_consulta(-Res)    : TODO el flujo. Res es uno de:
         ok(Emocion, perfil(E,A), ListaDeCanciones)
         incompleto(VariablesFaltantes)    % faltan respuestas
         sin_emocion                       % ninguna regla dio emocion
         sin_perfil(Emocion)               % hay emocion pero no perfil
         sin_canciones(perfil(E,A))        % hay perfil pero no hay canciones
     (la interfaz y la consola solo tienen que hacer case sobre estos 5)

   NOTA: ejecutar_consulta/1 se puede llamar varias veces seguidas; cada vez
   borra lo deducido antes de inferir de nuevo.
   ============================================================================ */

max_recomendaciones(3).

% Conclusiones de las que solo puede haber UNA por consulta (Nombre/Aridad)
conclusion_unica(emocion/1).
conclusion_unica(perfil/2).

% ---- Inferencia ------------------------------------------------------------
inferir :-
    siguiente_regla(Id, Conclusion),
    !,
    assertz(hecho(Conclusion)),
    assertz(disparada(Id)),
    inferir.
inferir.

siguiente_regla(Id, Conclusion) :-
    regla(Id, Condiciones, Conclusion),
    \+ disparada(Id),
    \+ hecho(Conclusion),
    \+ conflicto(Conclusion),
    todas_se_cumplen(Condiciones).

todas_se_cumplen([]).
todas_se_cumplen([C|Cs]) :-
    se_cumple(C),
    todas_se_cumplen(Cs).

se_cumple(no(C)) :- !, \+ hecho(C).
se_cumple(C)     :- hecho(C).

% Hay conflicto si la conclusion es "unica" y ya existe otra del mismo tipo.
conflicto(Conclusion) :-
    functor(Conclusion, Nombre, Aridad),
    conclusion_unica(Nombre/Aridad),
    functor(Otra, Nombre, Aridad),
    hecho(Otra).

% ---- Recomendacion ---------------------------------------------------------
recomendar(Canciones) :-
    hecho(perfil(Energia, Animo)),
    !,
    findall(cancion(Id, T, Ar, G, Energia, Animo, I, L),
            cancion(Id, T, Ar, G, Energia, Animo, I, L),
            Todas),
    random_permutation(Todas, Mezcladas),
    max_recomendaciones(Max),
    tomar(Max, Mezcladas, Canciones).

tomar(N, Lista, Primeros) :-
    length(Lista, Largo),
    (   Largo > N
    ->  length(Primeros, N),
        append(Primeros, _, Lista)
    ;   Primeros = Lista
    ).

% ---- Flujo completo ----------------------------------------------------------
ejecutar_consulta(Resultado) :-
    faltantes(Faltan),
    (   Faltan \== []
    ->  Resultado = incompleto(Faltan)
    ;   limpiar_derivados,
        inferir,
        resultado_final(Resultado)
    ).

resultado_final(Resultado) :-
    (   \+ hecho(emocion(_))
    ->  Resultado = sin_emocion
    ;   once(hecho(emocion(Emocion))),
        (   \+ hecho(perfil(_, _))
        ->  Resultado = sin_perfil(Emocion)
        ;   once(hecho(perfil(E, A))),
            recomendar(Canciones),
            (   Canciones == []
            ->  Resultado = sin_canciones(perfil(E, A))
            ;   Resultado = ok(Emocion, perfil(E, A), Canciones)
            )
        )
    ).
