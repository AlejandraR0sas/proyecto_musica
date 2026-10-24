:- encoding(utf8).
/* ============================================================================
   propuestas/validar_propuesta.pl
   Verifica la propuesta SIN tocar conocimiento/reglas.pl ni canciones.pl.
   USO (desde cualquier carpeta):
       swipl propuestas/validar_propuesta.pl -g reportar -t halt
   ============================================================================ */

:- prolog_load_context(directory, Dir),
   atom_concat(Dir, '/reglas.pl', R),
   atom_concat(Dir, '/canciones.pl', C),
   atom_concat(Dir, '/../src/hechos.pl', H),
   atom_concat(Dir, '/../src/motor.pl', M),
   [R, C, H, M].

:- dynamic fallo/1, sim_disparada/1.

ok(Goal) :- ( call(Goal) -> true ; assertz(fallo(Goal)), fail ).

reportar :-
    retractall(fallo(_)),
    retractall(sim_disparada(_)),
    format('~n== VALIDACION DE LA PROPUESTA ==~n'),
    validar_canciones,
    validar_reglas,
    validar_emociones,
    validar_variables,
    validar_consultas,
    validar_cobertura_reglas,
    (   findall(F, fallo(F), Fallos),
        Fallos == []
    ->  format('~nRESULTADO: TODO OK~n')
    ;   format('~nRESULTADO: ~w FALLOS~n', [Fallos]),
        forall(member(F, Fallos), format('  FALLO: ~w~n', [F]))
    ).

validar_canciones :-
    findall(Id, cancion(Id, _, _, _, _, _, _, _), Ids),
    length(Ids, N),
    format('~nCanciones: ~w~n', [N]),
    ok(N =:= 30),
    sort(Ids, Unicos),
    length(Unicos, NU),
    ok(NU =:= N),
    forall(cancion(Id, T, A, G, E, An, I, L),
           ( ok(Id \== ''), ok(T \== ''), ok(A \== ''), ok(G \== ''),
             ok(memberchk(E, [baja, media, alta])),
             ok(memberchk(An, [bajo, neutro, alto])),
             ok(memberchk(I, [espanol, ingles, instrumental, otro])),
             ok(atom_concat('https://www.youtube.com/results?search_query=', _, L))
           )),
    findall(Perfil-Nc,
            ( member(Perfil, [perfil(baja,bajo), perfil(media,alto), perfil(media,bajo),
                              perfil(baja,neutro), perfil(alta,bajo), perfil(alta,alto),
                              perfil(media,neutro)]),
              findall(Id, ( Perfil = perfil(PE, PA),
                            cancion(Id, _, _, _, PE, PA, _, _) ), Ids2),
              length(Ids2, Nc) ),
            Cobertura),
    format('Cobertura de perfiles (canciones):~n'),
    forall(member(P-Nc, Cobertura),
           ( format('  ~w -> ~w~n', [P, Nc]), ok(Nc >= 1) )),
    forall(cancion(Id, _, _, _, E, A, _, _),
           ( regla(_, _, perfil(E, A))
           -> true
           ;  assertz(fallo(cancion_sin_regla(Id, perfil(E, A))))
           )).

validar_reglas :-
    findall(Id, regla(Id, _, _), Ids),
    length(Ids, N),
    sort(Ids, Unicos),
    length(Unicos, NU),
    format('~nReglas: ~w~n', [N]),
    ok(NU =:= N),
    forall(regla(Id, Conds, Concl),
           ( ok(descripcion(Id, _)),
             validar_condiciones(Conds),
             validar_conclusion(Concl)
           )),
    findall(Id, descripcion(Id, _), DIds),
    forall(member(D, DIds),
           ( regla(D, _, _) -> true ; assertz(fallo(descripcion_sin_regla(D))) )),
    findall(Conds, regla(_, Conds, _), Todas),
    forall(( member(C1, Todas), member(C2, Todas), C1 \== C2,
             msort(C1, C1s), msort(C2, C2s), C1s == C2s ),
           assertz(fallo(condiciones_repetidas(C1)))).

validar_condiciones([]).
validar_condiciones([C|Cs]) :-
    (   C = no(H) -> validar_condiciones([H|Cs])
    ;   C =.. [Var, Valor],
        (   variable(Var, Valores, _)
        ->  ( memberchk(Valor, Valores) -> true ; assertz(fallo(valor_invalido(C))) )
        ;   Var == emocion
        ->  ( catalogo_emocion(Valor, _) -> true ; assertz(fallo(emocion_invalida(C))) )
        ;   assertz(fallo(condicion_desconocida(C)))
        ),
        validar_condiciones(Cs)
    ).

validar_conclusion(emocion(E)) :- !, catalogo_emocion(E, _).
validar_conclusion(perfil(E, A)) :-
    memberchk(E, [baja, media, alta]),
    memberchk(A, [bajo, neutro, alto]),
    (   cancion(_, _, _, _, E, A, _, _)
    ->  true
    ;   assertz(fallo(perfil_sin_canciones(perfil(E, A))))
    ).
validar_conclusion(Otra) :- assertz(fallo(conclusion_invalida(Otra))).

validar_emociones :-
    format('~nCobertura de emociones:~n'),
    forall(catalogo_emocion(E, _),
           (   ( regla(_, _, emocion(E)) -> true ; assertz(fallo(sin_regla_etapa1(E))) ),
               ( tiene_regla(E, acompanar) -> true ; assertz(fallo(sin_regla_acompanar(E))) ),
               ( tiene_regla(E, cambiar) -> true ; assertz(fallo(sin_regla_cambiar(E))) ),
               format('  ~w: etapa 1 + acompanar + cambiar~n', [E])
           )).

tiene_regla(E, Obj) :-
    regla(_, Conds, _),
    memberchk(emocion(E), Conds),
    memberchk(objetivo(Obj), Conds).

validar_variables :-
    forall(variable(V, _, _),
           (   ( regla(_, Conds, _), member(C, Conds), C =.. [V|_] )
           ->  true
           ;   assertz(fallo(variable_sin_uso(V)))
           )).

validar_consultas :-
    format('~nSimulacion de consultas (motor real):~n'),
    forall(member(Fila, [
        fila(tristeza, relajarse, bajo, baja, baja, acompanar, baja, bajo),
        fila(tristeza, relajarse, bajo, baja, baja, cambiar, media, alto),
        fila(estres, estudiar, neutro, alta, alta, acompanar, media, bajo),
        fila(estres, estudiar, neutro, alta, alta, cambiar, baja, neutro),
        fila(enojo, estudiar, bajo, alta, alta, acompanar, alta, bajo),
        fila(enojo, estudiar, bajo, alta, alta, cambiar, media, alto),
        fila(calma, relajarse, neutro, baja, baja, acompanar, baja, neutro),
        fila(calma, relajarse, neutro, baja, baja, cambiar, media, alto),
        fila(calma, relajarse, neutro, media, baja, acompanar, baja, neutro),
        fila(motivacion, ejercicio, alto, alta, media, acompanar, alta, alto),
        fila(motivacion, ejercicio, alto, alta, media, cambiar, media, neutro),
        fila(alegria, fiesta, alto, alta, baja, acompanar, alta, alto),
        fila(alegria, fiesta, alto, alta, baja, cambiar, media, neutro),
        fila(tristeza, dormir, bajo, baja, baja, acompanar, baja, neutro)
    ]),
        (   Fila = fila(Emo, Ctx, An, En, Te, Obj, PE, PA),
            limpiar_hechos,
            capturar(animo, An), capturar(energia, En), capturar(tension, Te),
            capturar(contexto, Ctx), capturar(objetivo, Obj),
            ejecutar_consulta(Res),
            (   Res = ok(Emo, perfil(PE, PA), Canciones),
                Canciones \== []
            ->  format('  OK  ~w + ~w -> ~w~n', [Emo, Obj, perfil(PE, PA)]),
                forall(disparada(R), assertz(sim_disparada(R)))
            ;   assertz(fallo(consulta(Emo, Obj, Res))),
                format('  FALLO ~w + ~w -> ~w~n', [Emo, Obj, Res])
            )
        )).

validar_cobertura_reglas :-
    findall(Id, regla(Id, _, _), Todas),
    findall(Id, sim_disparada(Id), Simuladas),
    sort(Todas, TodasS),
    sort(Simuladas, SimuladasS),
    format('~nReglas disparadas en la simulacion: ~w~n', [SimuladasS]),
    forall(member(Id, TodasS),
           ( memberchk(Id, SimuladasS)
           -> true
           ;  assertz(fallo(regla_no_simulada(Id)))
           )).
