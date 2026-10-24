
:- encoding(utf8).
:- use_module(library(pce)).
:- use_module(musica).

% ============================================================
% ESTADO DE LA INTERFAZ
% ============================================================

:- dynamic ventana_inicio/1.
:- dynamic ventana_aprendizaje/1.
:- dynamic ventana_preferencias/1.
:- dynamic ventana_resultado/1.
:- dynamic campo_emocion/1.
:- dynamic emocion_consulta/1.
:- dynamic canciones_actuales_cache/1.
:- dynamic perfil_actual/1.

% ============================================================
% INICIO
% ============================================================

iniciar_gui :-
    cerrar_todas_ventanas,
    limpiar_hechos,
    retractall(emocion_consulta(_)),
    retractall(canciones_actuales_cache(_)),
    retractall(perfil_actual(_)),
    abrir_ventana_inicio.

abrir_ventana_inicio :-
    new(D, dialog('Recomendador musical')),
    send(D, size, size(390, 170)),
    send(D, append, label(titulo, '¿Como te sientes?')),
    send(D, append,
         label(instruccion, 'Escribe una emocion para comenzar.')),
    new(Campo, text_item(emocion)),
    send(Campo, length, 28),
    send(D, append, Campo),
    send(D, append,
         button('Consultar',
                message(@prolog, accion_consulta_directa))),
    send(D, append,
         button('Cerrar',
                message(@prolog, accion_cerrar))),
    assertz(ventana_inicio(D)),
    assertz(campo_emocion(Campo)),
    send(D, open_centered).

% ============================================================
% PASO 1: CONSULTAR LA EMOCION
% ============================================================

accion_consulta_directa :-
    (   campo_emocion(Campo)
    ->  get(Campo, selection, Texto),
        normalizar(Texto, Nombre),
        (   Nombre == ''
        ->  mostrar_mensaje(
                'Falta la emocion',
                'Escribe como te sientes para continuar.')
        ;   procesar_emocion(Nombre)
        )
    ;   mostrar_mensaje(
            'Error',
            'No se encontro el campo de emocion.')
    ).

procesar_emocion(Nombre) :-
    (   resolver_emocion(Nombre, Emocion)
    ->  retractall(emocion_consulta(_)),
        assertz(emocion_consulta(Emocion)),
        cerrar_ventana_inicio,
        abrir_ventana_preferencias
    ;   cerrar_ventana_inicio,
        abrir_aprendizaje_emocion(Nombre)
    ).

% ============================================================
% PASO 2: APRENDER UNA EMOCION DESCONOCIDA
% ============================================================

abrir_aprendizaje_emocion(Nombre) :-
    new(D, dialog('Aprender emocion')),
    send(D, size, size(440, 390)),

    format(atom(Titulo),
           'No conozco la emocion "~w".', [Nombre]),
    send(D, append, label(titulo_aprendizaje, Titulo)),
    send(D, append,
         label(instruccion_aprendizaje,
               'Indica que tipo de musica se relaciona con ella.')),

    send(D, append,
         label(seccion_acompanar,
               'Si quieres ACOMPANAR esta emocion:')),

    crear_menu_perfil(
        D, energia_acompanar,
        'Energia musical', energia, E1),
    crear_menu_perfil(
        D, animo_acompanar,
        'Animo musical', animo, A1),

    send(D, append,
         label(seccion_cambiar,
               'Si quieres CAMBIAR esta emocion:')),

    crear_menu_perfil(
        D, energia_cambiar,
        'Energia musical', energia, E2),
    crear_menu_perfil(
        D, animo_cambiar,
        'Animo musical', animo, A2),

    send(D, append,
         button('Guardar y continuar',
                message(@prolog, guardar_emocion_aprendida,
                        D, Nombre, E1, A1, E2, A2))),
    send(D, append,
         button('Cancelar',
                message(@prolog, cancelar_aprendizaje))),

    assertz(ventana_aprendizaje(D)),
    send(D, open_centered).

crear_menu_perfil(D, NombreMenu, Etiqueta, Variable, Menu) :-
    variable(Variable, Valores, _),
    new(Menu, menu(NombreMenu, choice)),
    send(Menu, append, 'Seleccione...'),
    forall(
        member(Valor, Valores),
        send(Menu, append, Valor)
    ),
    send(Menu, selection, 'Seleccione...'),
    send(D, append, label(NombreMenu, Etiqueta)),
    send(D, append, Menu).

guardar_emocion_aprendida(
    D, Nombre, MenuE1, MenuA1, MenuE2, MenuA2
) :-
    get(MenuE1, selection, E1),
    get(MenuA1, selection, A1),
    get(MenuE2, selection, E2),
    get(MenuA2, selection, A2),

    (   memberchk('Seleccione...', [E1, A1, E2, A2])
    ->  mostrar_mensaje(
            'Faltan respuestas',
            'Selecciona las cuatro opciones antes de guardar.')
    ;   (   catch(
                aprender_emocion(
                    Nombre,
                    perfil(E1, A1),
                    perfil(E2, A2)),
                Error,
                (print_message(error, Error), fail))
        ->  retractall(emocion_consulta(_)),
            assertz(emocion_consulta(Nombre)),
            cerrar_ventana_aprendizaje,
            mostrar_mensaje(
                'Emocion aprendida',
                'La emocion se guardo para futuras consultas.'),
            abrir_ventana_preferencias
        ;   mostrar_mensaje(
                'No se pudo aprender',
                'Comprueba que la emocion sea valida y no exista ya.')
        )
    ).

cancelar_aprendizaje :-
    cerrar_ventana_aprendizaje,
    limpiar_hechos,
    abrir_ventana_inicio.

% ============================================================
% PASO 3: ACTIVIDAD Y OBJETIVO MUSICAL
% ============================================================

abrir_ventana_preferencias :-
    limpiar_hechos,
    retractall(canciones_actuales_cache(_)),
    retractall(perfil_actual(_)),

    new(D, dialog('Preferencias musicales')),
    send(D, size, size(410, 240)),

    send(D, append,
         label(titulo_preferencias,
               'Personalicemos tu recomendacion.')),

    variable(contexto, _, PreguntaContexto),
    send(D, append, label(pregunta_contexto, PreguntaContexto)),
    crear_menu(D, contexto, MenuContexto),

    variable(objetivo, _, PreguntaObjetivo),
    send(D, append, label(pregunta_objetivo, PreguntaObjetivo)),
    crear_menu(D, objetivo, MenuObjetivo),

    send(D, append,
         button('Obtener recomendaciones',
                message(@prolog,
                        generar_recomendaciones,
                        D, MenuContexto, MenuObjetivo))),
    send(D, append,
         button('Volver al inicio',
                message(@prolog, accion_nueva_consulta))),

    assertz(ventana_preferencias(D)),
    send(D, open_centered).

crear_menu(D, Variable, Menu) :-
    variable(Variable, Valores, _),
    new(Menu, menu(Variable, choice)),
    send(Menu, append, 'Seleccione...'),
    forall(
        member(Valor, Valores),
        send(Menu, append, Valor)
    ),
    send(Menu, selection, 'Seleccione...'),
    send(D, append, Menu).

generar_recomendaciones(D, MenuContexto, MenuObjetivo) :-
    get(MenuContexto, selection, Contexto),
    get(MenuObjetivo, selection, Objetivo),

    (   memberchk('Seleccione...', [Contexto, Objetivo])
    ->  mostrar_mensaje(
            'Faltan respuestas',
            'Selecciona la actividad y el objetivo musical.')
    ;   capturar(contexto, Contexto),
        capturar(objetivo, Objetivo),
        (   emocion_consulta(Emocion)
        ->  declarar_emocion(Emocion),
            ejecutar_consulta_directa(Resultado),
            mostrar_resultado_gui(Resultado)
        ;   mostrar_mensaje(
                'Error',
                'No se encontro la emocion de esta consulta.')
        )
    ).

% ============================================================
% PASO 4: VENTANA DE RECOMENDACIONES
% ============================================================

mostrar_resultado_gui(
    ok(Emocion, perfil(Energia, Animo), Canciones)
) :-
    !,
    retractall(canciones_actuales_cache(_)),
    retractall(perfil_actual(_)),
    assertz(canciones_actuales_cache(Canciones)),
    assertz(perfil_actual(perfil(Energia, Animo))),

    cerrar_ventana_preferencias,
    cerrar_ventana_resultado,

    new(D, dialog('Tus recomendaciones')),
    send(D, size, size(420, 360)),

    format(atom(TextoPerfil),
           'Emocion: ~w | Energia: ~w | Animo: ~w',
           [Emocion, Energia, Animo]),
    send(D, append, label(perfil, TextoPerfil)),
    send(D, append,
         label(instruccion_canciones,
               'Selecciona una cancion para abrir YouTube.')),

    % Grupo separado para apilar verticalmente los botones.
    new(Columna, dialog_group(canciones, group)),
    send(Columna, gap, size(0, 4)),
    send(D, append, Columna),
    mostrar_canciones(Columna, Canciones, 1),

    send(D, append,
         button('Explicar recomendaciones',
                message(@prolog, accion_explicar))),
    send(D, append,
         button('Sugerir una cancion',
                message(@prolog, accion_sugerir_cancion))),
    send(D, append,
         button('Nueva consulta',
                message(@prolog, accion_nueva_consulta))),
    send(D, append,
         button('Cerrar',
                message(@prolog, accion_cerrar))),

    assertz(ventana_resultado(D)),
    send(D, open_centered).

% Los botones se agregan al grupo, no al dialogo principal.
% La etiqueta se limita a numero, titulo y artista para
% reducir el ancho que ocupa cada boton.
mostrar_canciones(_, [], _).

mostrar_canciones(Columna, [Cancion|Resto], N) :-
    Cancion = cancion(_, Titulo, Artista, _, _, _, _, _),
    format(atom(Etiqueta), '~w. ~w - ~w', [N, Titulo, Artista]),
    new(Boton, button(
        Etiqueta,
        message(@prolog, reproducir_por_indice, N)
    )),
    send(Boton, alignment, left),
    send(Columna, append, Boton),
    N1 is N + 1,
    mostrar_canciones(Columna, Resto, N1).

mostrar_resultado_gui(incompleto(Faltantes)) :-
    !,
    format(atom(Texto),
           'Faltan respuestas: ~w', [Faltantes]),
    mostrar_mensaje('Consulta incompleta', Texto).

mostrar_resultado_gui(sin_emocion) :-
    !,
    mostrar_mensaje(
        'Sin resultado',
        'No se pudo determinar una emocion para esta consulta.').

mostrar_resultado_gui(sin_perfil(Emocion)) :-
    !,
    format(atom(Texto),
           'No se encontro un perfil musical para ~w.',
           [Emocion]),
    mostrar_mensaje('Sin perfil musical', Texto).

mostrar_resultado_gui(sin_canciones(perfil(E, A))) :-
    !,
    format(atom(Texto),
           'No hay canciones para energia ~w y animo ~w.',
           [E, A]),
    mostrar_mensaje('Sin canciones', Texto).

mostrar_resultado_gui(error(Texto)) :-
    !,
    mostrar_mensaje('Error', Texto).

mostrar_resultado_gui(_) :-
    mostrar_mensaje(
        'Sin resultado',
        'No fue posible generar recomendaciones.').

% ============================================================
% REPRODUCCION DE CANCIONES
% ============================================================

reproducir_por_indice(N) :-
    (   canciones_actuales_cache(Canciones),
        nth1(N, Canciones, Cancion)
    ->  reproducir(Cancion)
    ;   mostrar_mensaje(
            'Cancion no encontrada',
            'No se encontro la cancion seleccionada.')
    ).

% ============================================================
% EXPLICACION DE LAS RECOMENDACIONES
% ============================================================

accion_explicar :-
    (   catch(explicar_lineas(Lineas), _, fail)
    ->  (   Lineas == []
        ->  mostrar_mensaje(
                'Explicacion',
                'No hay detalles disponibles para esta consulta.')
        ;   atomic_list_concat(Lineas, '\n', Texto),
            mostrar_texto('Por que estas recomendaciones', Texto)
        )
    ;   mostrar_mensaje(
            'Explicacion',
            'No se pudo generar la explicacion.')
    ).

mostrar_texto(Titulo, Texto) :-
    new(D, dialog(Titulo)),
    send(D, size, size(440, 300)),
    new(Editor, editor),
    send(Editor, editable, @off),
    send(Editor, insert, Texto),
    send(D, append, Editor),
    send(D, append,
         button('Cerrar', message(D, destroy))),
    send(D, open_centered).

% ============================================================
% SUGERIR Y GUARDAR UNA CANCION
% ============================================================

accion_sugerir_cancion :-
    (   perfil_actual(_)
    ->  abrir_formulario_cancion
    ;   mostrar_mensaje(
            'Sin perfil musical',
            'Primero realiza una consulta musical.')
    ).

abrir_formulario_cancion :-
    new(D, dialog('Agregar cancion')),
    send(D, size, size(380, 230)),

    new(Titulo, text_item('Titulo')),
    new(Artista, text_item('Artista')),
    new(Genero, text_item('Genero')),

    send(D, append, Titulo),
    send(D, append, Artista),
    send(D, append, Genero),

    send(D, append,
         button('Guardar cancion',
                message(@prolog,
                        guardar_sugerencia,
                        D, Titulo, Artista, Genero))),
    send(D, append,
         button('Cancelar', message(D, destroy))),
    send(D, open_centered).

guardar_sugerencia(D, CampoTitulo, CampoArtista, CampoGenero) :-
    get(CampoTitulo, selection, Titulo0),
    get(CampoArtista, selection, Artista0),
    get(CampoGenero, selection, Genero0),

    normalizar_texto(Titulo0, Titulo),
    normalizar_texto(Artista0, Artista),
    normalizar(Genero0, Genero),

    (   Titulo == ''
    ;   Artista == ''
    ;   Genero == ''
    ),
    !,
    mostrar_mensaje(
        'Datos incompletos',
        'Escribe el titulo, el artista y el genero.').

guardar_sugerencia(D, CampoTitulo, CampoArtista, CampoGenero) :-
    get(CampoTitulo, selection, Titulo0),
    get(CampoArtista, selection, Artista0),
    get(CampoGenero, selection, Genero0),

    normalizar_texto(Titulo0, Titulo),
    normalizar_texto(Artista0, Artista),
    normalizar(Genero0, Genero),

    (   cancion_duplicada(Titulo, Artista)
    ->  mostrar_mensaje(
            'Cancion duplicada',
            'Esa cancion ya existe en el catalogo.')
    ;   (   perfil_actual(Perfil),
            catch(
                aprender_cancion(Titulo, Artista, Genero, Perfil),
                Error,
                (print_message(error, Error), fail))
        ->  send(D, destroy),
            mostrar_mensaje(
                'Cancion guardada',
                'La cancion se agrego al catalogo aprendido.')
        ;   mostrar_mensaje(
                'No se pudo guardar',
                'Verifica los datos y el perfil musical.')
        )
    ).

normalizar_texto(Texto, Atomo) :-
    (   atom(Texto)
    ->  Atomo = Texto
    ;   string(Texto)
    ->  atom_string(Atomo, Texto)
    ;   term_to_atom(Texto, Atomo)
    ).

% ============================================================
% NUEVA CONSULTA Y CIERRE
% ============================================================

accion_nueva_consulta :-
    cerrar_todas_ventanas,
    retractall(emocion_consulta(_)),
    retractall(canciones_actuales_cache(_)),
    retractall(perfil_actual(_)),
    limpiar_hechos,
    abrir_ventana_inicio.

accion_cerrar :-
    cerrar_todas_ventanas,
    retractall(emocion_consulta(_)),
    retractall(canciones_actuales_cache(_)),
    retractall(perfil_actual(_)),
    limpiar_hechos.

% ============================================================
% GESTION DE VENTANAS
% ============================================================

cerrar_todas_ventanas :-
    cerrar_ventana_inicio,
    cerrar_ventana_aprendizaje,
    cerrar_ventana_preferencias,
    cerrar_ventana_resultado.

cerrar_ventana_inicio :-
    (   retract(ventana_inicio(D))
    ->  catch(send(D, destroy), _, true)
    ;   true
    ),
    retractall(campo_emocion(_)).

cerrar_ventana_aprendizaje :-
    (   retract(ventana_aprendizaje(D))
    ->  catch(send(D, destroy), _, true)
    ;   true
    ).

cerrar_ventana_preferencias :-
    (   retract(ventana_preferencias(D))
    ->  catch(send(D, destroy), _, true)
    ;   true
    ).

cerrar_ventana_resultado :-
    (   retract(ventana_resultado(D))
    ->  catch(send(D, destroy), _, true)
    ;   true
    ).

% ============================================================
% MENSAJES
% ============================================================

mostrar_mensaje(Titulo, Texto) :-
    new(D, dialog(Titulo)),
    send(D, append, label(mensaje, Texto)),
    send(D, append,
         button('Aceptar', message(D, destroy))),
    send(D, open_centered).
