:- encoding(utf8).
/* ============================================================================
   src/explicacion.pl               >>> RESPONSABLE: ALE <<<
   MODULO DE EXPLICACION
   ============================================================================
   Muestra POR QUE el sistema llego a su resultado: los datos capturados y las
   reglas que se dispararon (en orden), escritas como SI ... ENTONCES ....

   PREDICADOS PUBLICOS:
     explicar_lineas(-Lineas) : lista de atomos, una por linea (util para la GUI)
     explicar(-Texto)         : un solo atomo con saltos de linea (util en consola)

   EJEMPLO DE SALIDA:
     Datos capturados:
       - animo = bajo
       - energia = baja
     Reglas aplicadas:
       [R01] SI animo=bajo Y energia=baja ENTONCES emocion=tristeza  (Un animo bajo ...)
       [R31] SI emocion=tristeza Y objetivo=acompanar ENTONCES perfil=baja,bajo  (...)

   Funciona tambien cuando NO hay resultado (muestra que reglas si se aplicaron
   o avisa que no se aplico ninguna). Las descripciones salen de descripcion/2
   en conocimiento/reglas.pl.
   ============================================================================ */

explicar_lineas(Lineas) :-
    findall(Txt,
            ( variable(V, _, _), respuesta(V, Val),
              format(atom(Txt), '  - ~w = ~w', [V, Val]) ),
            LineasDatos),
    findall(Txt2,
            ( disparada(Id), linea_regla(Id, Txt2) ),
            LineasReglas),
    (   LineasReglas == []
    ->  Cuerpo = ['  (no se aplico ninguna regla)']
    ;   Cuerpo = LineasReglas
    ),
    append(['Datos capturados:' | LineasDatos],
           ['Reglas aplicadas:' | Cuerpo],
           Lineas).

explicar(Texto) :-
    explicar_lineas(Lineas),
    atomic_list_concat(Lineas, '\n', Texto).

linea_regla(Id, Txt) :-
    regla(Id, Condiciones, Conclusion),
    maplist(termino_texto, Condiciones, CondTxts),
    atomic_list_concat(CondTxts, ' Y ', CondTxt),
    termino_texto(Conclusion, ConclTxt),
    (   descripcion(Id, Desc) -> true ; Desc = '' ),
    upcase_atom(Id, IdMay),
    format(atom(Txt), '  [~w] SI ~w ENTONCES ~w  (~w)',
           [IdMay, CondTxt, ConclTxt, Desc]).

termino_texto(no(T), Txt) :-
    !,
    termino_texto(T, X),
    format(atom(Txt), 'NO ~w', [X]).
termino_texto(T, Txt) :-
    T =.. [Functor | Args],
    atomic_list_concat(Args, ',', ArgsTxt),
    format(atom(Txt), '~w=~w', [Functor, ArgsTxt]).
