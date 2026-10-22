:- encoding(utf8).
/* ============================================================================
   src/interfaz.pl                  >>> RESPONSABLE: ANTULIO <<<
   INTERFAZ GRAFICA EN PROLOG (XPCE, incluida en SWI-Prolog)
   ============================================================================
   Si la GUI no abre (o XPCE no esta instalado), main.pl cae automaticamente al
   modo consola, asi que el sistema nunca se queda sin interfaz.

   CONTRATO: main.pl llama a  iniciar_gui/0.
     - Si abre la ventana y regresa (true)      -> se usa la GUI.
     - Si FALLA o lanza excepcion               -> se usa la consola.
   (El stub de abajo falla a proposito hasta que Antulio lo implemente.)

   LO QUE LA VENTANA DEBE TENER (requisito del proyecto):
     1. Un control por cada variable de entrada, GENERADO desde variable/3
        (menu desplegable con los valores permitidos + la pregunta como etiqueta).
        Asi, si Osiel agrega una variable, aparece sola.
     2. Boton "Recomendar"      -> lee los menus, llama capturar/2 por cada uno y
                                   luego ejecutar_consulta(Resultado).
     3. Zona de resultado       -> segun Resultado (ver abajo) muestra emocion,
                                   perfil y las canciones (texto_cancion/2).
     4. Boton "Abrir cancion"   -> llama reproducir/1 con la cancion elegida.
     5. Boton "Por que?"        -> muestra explicar/1 (o explicar_lineas/1).
     6. Boton "Nueva consulta"  -> limpiar_hechos y reiniciar los menus.
     7. Mensajes claros en: datos invalidos, datos incompletos, sin emocion,
        sin perfil, sin canciones.
     8. CAMPO "Escribe tu emocion" (opcional) + aprendizaje. Ver el modo
        consola en main.pl (preguntar_emocion_libre/1 y aprender_dialogo/2),
        que es la referencia de como debe comportarse:
        - normalizar(+Texto,-Nombre) y resolver_emocion(+Nombre,-Emocion)
        - si resolver_emocion FALLA -> pedir 2 perfiles (acompanar y cambiar)
          con menus de energia y animo, y llamar
          aprender_emocion(Nombre, perfil(E1,A1), perfil(E2,A2)).
        - luego: capturar contexto y objetivo, declarar_emocion(Emocion) y
            ejecutar_consulta_directa(Resultado) (en vez de ejecutar_consulta/1).


   PREDICADOS DE LOS DEMAS QUE USARAS (no los reimplementes):
     capturar(+Var,+Valor)  validar(+Var,+Valor)  mensaje_invalido(+V,+Val,-Msg)
     limpiar_hechos         ejecutar_consulta(-Resultado)
     explicar(-Texto)       texto_cancion(+Cancion,-Texto)   reproducir(+Cancion)
     variable(Nombre, Valores, Pregunta)   % para construir los menus

   FORMA DE Resultado (hacer un caso por cada uno):
     ok(Emocion, perfil(E,A), Canciones)   incompleto(Faltantes)
     sin_emocion                           sin_perfil(Emocion)
     sin_canciones(perfil(E,A))

   EJEMPLO ORIENTATIVO DE XPCE (NO PROBADO: adaptenlo y prueben en su PC).
   Referencia: documentacion de XPCE / "pce" en SWI-Prolog.

     :- use_module(library(pce)).
     :- dynamic menu_gui/2.

     iniciar_gui :-
         new(D, dialog('Recomendador musical por emocion')),
         forall(variable(V, Valores, Pregunta),
                ( new(M, menu(V, cycle)),
                  send(M, label, Pregunta),
                  send_list(M, append, Valores),
                  send(D, append, M),
                  assertz(menu_gui(V, M)) )),
         send(D, append, button('Recomendar', message(@prolog, accion_recomendar))),
         send(D, append, button('Nueva consulta', message(@prolog, accion_nueva))),
         send(D, open).

     accion_recomendar :-
         limpiar_hechos,
         forall(menu_gui(V, M),
                ( get(M, selection, Val), capturar(V, Val) )),
         ejecutar_consulta(Resultado),
         mostrar(Resultado).        % <- Antulio: escribe mostrar/1 con un caso por Resultado

   Para mostrar resultados puede servir una ventana nueva con un `view` o un
   `editor`:  send(View, append, Texto). Si es mucho lio, usen un dialogo de
   alerta:  send(@display, inform, Texto).

   TAREAS DE ANTULIO (checklist)
   [ ] Miercoles: confirmar que XPCE abre en TU PC y abrir una ventana vacia
   [ ] Miercoles: boton que abra un enlace con reproducir/1
   [ ] Jueves: conectar con el motor real (ejecutar_consulta/1)
   [ ] Viernes: pulir, probar todos los casos de Resultado y tomar capturas
   [ ] Responsable tambien de musica.pl y de las secciones del reporte
       indicadas en el README
   ============================================================================ */

% STUB: falla a proposito para que main.pl use el modo consola por ahora.
iniciar_gui :-
    format('(La interfaz grafica aun no esta implementada.)~n'),
    fail.
