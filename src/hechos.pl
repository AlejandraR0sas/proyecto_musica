:- encoding(utf8).
/* ============================================================================
   src/hechos.pl                    >>> RESPONSABLE: ALE <<<
   BASE DE HECHOS / MEMORIA DE TRABAJO
   ============================================================================
   Aqui viven los datos de LA CONSULTA ACTUAL (lo que respondio el usuario y lo
   que el motor fue deduciendo). Todo es dinamico y se borra en cada consulta.

   REPRESENTACION:
     hecho(animo(bajo))          <- respuesta del usuario (variable de ENTRADA)
     hecho(emocion(tristeza))    <- hecho DEDUCIDO por una regla
     hecho(perfil(baja, bajo))   <- hecho DEDUCIDO por una regla
     disparada(r01)              <- la regla r01 se aplico (en orden de disparo)

   PREDICADOS PUBLICOS (los usan interfaz, main y pruebas):
     validar(+Var, +Valor)              : true si Valor esta permitido para Var
     mensaje_invalido(+Var,+Valor,-Msg) : texto de error listo para mostrar
     capturar(+Var, +Valor)             : valida y guarda. FALLA si es invalido.
                                          Si Var ya tenia respuesta, la reemplaza.
     respuesta(?Var, ?Valor)            : consulta una respuesta capturada
     faltantes(-Lista)                  : variables aun sin respuesta
     limpiar_derivados                  : borra lo deducido (emocion, perfil,
                                          disparadas) pero CONSERVA las respuestas
     limpiar_hechos                     : borra TODO (nueva consulta)

   EJEMPLO:
     ?- capturar(animo, bajo).        % true
     ?- capturar(animo, triste).      % false  (no es un valor permitido)
     ?- faltantes(L).                 % L = [energia, tension, contexto, objetivo]
   ============================================================================ */

:- dynamic hecho/1, disparada/1, emocion_declarada/1.

% validar(+Var, +Valor): usa variable/3 de conocimiento/reglas.pl
validar(Var, Valor) :-
    variable(Var, Valores, _),
    memberchk(Valor, Valores).

mensaje_invalido(Var, Valor, Texto) :-
    (   variable(Var, Valores, _)
    ->  atomic_list_concat(Valores, ', ', Lista),
        format(atom(Texto),
               'El valor "~w" no es valido para ~w. Opciones: ~w.',
               [Valor, Var, Lista])
    ;   format(atom(Texto), 'La variable "~w" no existe.', [Var])
    ).

capturar(Var, Valor) :-
    validar(Var, Valor),
    borrar_variable(Var),
    Hecho =.. [Var, Valor],
    assertz(hecho(Hecho)).

borrar_variable(Var) :-
    Patron =.. [Var, _],
    retractall(hecho(Patron)).

respuesta(Var, Valor) :-
    Patron =.. [Var, Valor],
    hecho(Patron).

faltantes(Lista) :-
    findall(V, (variable(V, _, _), \+ respuesta(V, _)), Lista).

limpiar_derivados :-
    retractall(disparada(_)),
    retractall(hecho(emocion(_))),
    retractall(hecho(perfil(_, _))),
    forall(regla(_, _, Conclusion), retractall(hecho(Conclusion))).

limpiar_hechos :-
    retractall(hecho(_)),
    retractall(emocion_declarada(_)),
    retractall(disparada(_)).

