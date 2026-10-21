:- encoding(utf8).
/* ============================================================================
   conocimiento/reglas.pl        >>> RESPONSABLE: OSIEL <<<
   BASE DE CONOCIMIENTOS (parte 1): variables, emociones y reglas de produccion.
   ============================================================================
   Este archivo es el CORAZON del sistema experto. Solo contiene HECHOS Prolog
   (datos), nada de logica. El motor (src/motor.pl) es generico y lee esto.

   QUE VA AQUI (4 tipos de hechos):
     1) variable/3          -> las preguntas de entrada y sus valores permitidos
     2) catalogo_emocion/2  -> las emociones que el sistema puede inferir
     3) regla/3             -> las reglas SI-ENTONCES, cada una con ID
     4) descripcion/2       -> texto en espanol de cada regla (lo usa la explicacion)

   ---------------------------------------------------------------------------
   REGLAS DE ORO (para que todos estemos en sintonia)
   ---------------------------------------------------------------------------
   * TODO en minusculas, SIN acentos ni enes en los atomos (acompanar, alegria).
     Los acentos solo en textos de descripcion/pregunta (entre comillas simples).
   * Una variable de entrada se escribe como termino: animo(bajo), energia(alta)
   * IDs de regla: r01, r02... (minuscula en codigo; en el reporte: R01, R02...)
       r01-r29  -> ETAPA 1: de las respuestas del usuario -> emocion(...)
       r30-r59  -> ETAPA 2: de emocion/contexto/objetivo   -> perfil(Energia,Animo)
   * El ORDEN en el archivo = PRIORIDAD. Si dos reglas pueden dar una emocion
     (o un perfil), gana la que esta MAS ARRIBA. Pongan las mas especificas
     primero y las mas generales al final.
   * Solo se permite UNA emocion y UN perfil por consulta (lo garantiza el motor).
   * Cada ID de aqui debe aparecer igual en: tabla de decisiones, arbol de
     decision, descripcion/2 y pruebas/pruebas.pl (columna "reglas esperadas").
   * Si cambian nombres de variables o valores, AVISEN EN EL GRUPO y actualicen
     el README, porque se rompen interfaz, motor y pruebas.

   ---------------------------------------------------------------------------
   FORMATO DE regla/3
   ---------------------------------------------------------------------------
       regla(Id, [Condicion1, Condicion2, ...], Conclusion).

   * Condicion = un hecho: animo(bajo), energia(baja), emocion(tristeza), etc.
   * Tambien se acepta no(Hecho) solo sobre variables de ENTRADA
     (ej. no(contexto(dormir))). Usenlo poco.
   * Conclusion = emocion(E)  o  perfil(EnergiaMusical, AnimoMusical)

   ---------------------------------------------------------------------------
   COMO SE CONECTA CON LAS CANCIONES
   ---------------------------------------------------------------------------
   perfil(Energia, Animo) se compara con los campos Energia y Animo de
   cancion/8 (conocimiento/canciones.pl). Mismos valores: baja/media/alta y
   bajo/neutro/alto. Por eso cada perfil que usen en una regla DEBE tener
   al menos una cancion en el catalogo (si no, el resultado es sin_canciones).

   ---------------------------------------------------------------------------
   TAREAS DE OSIEL (checklist)
   ---------------------------------------------------------------------------
   [ ] Investigar fuentes (musicoterapia, psicologia de la musica) -> reporte
   [ ] Confirmar/ajustar variables y valores de abajo (cerrar HOY, miercoles 21)
   [ ] Cubrir las 6 emociones con reglas de etapa 1 (r01-r29)
   [ ] Cubrir cada emocion x objetivo (acompanar/cambiar) en etapa 2 (r30-r59)
   [ ] Escribir una descripcion/2 por cada regla
   [ ] Revisar coherencia: que no haya reglas contradictorias ni emociones sin
       perfil. Documentar combinaciones NO cubiertas (sirven para pruebas).
   [ ] Dibujar arbol de decision + tabla de decisiones para el reporte
   ============================================================================ */

:- discontiguous variable/3, catalogo_emocion/2, regla/3, descripcion/2.

/* ---------------------------------------------------------------------------
   1) VARIABLES DE ENTRADA
      variable(Nombre, ValoresPermitidos, TextoDeLaPregunta).
      La interfaz y la validacion se generan A PARTIR DE ESTO: si agregan una
      variable aqui, aparece sola en consola/GUI (y hay que usarla en reglas).
   --------------------------------------------------------------------------- */
variable(animo,    [bajo, neutro, alto],
         'Como describirias tu animo en este momento?').
variable(energia,  [baja, media, alta],
         'Que nivel de energia fisica tienes?').
variable(tension,  [baja, media, alta],
         'Que tanta tension o estres sientes?').
variable(contexto, [estudiar, ejercicio, relajarse, fiesta, dormir, manejar],
         'Que vas a hacer mientras escuchas musica?').
variable(objetivo, [acompanar, cambiar],
         'Quieres que la musica acompane tu emocion o que la cambie?').

/* ---------------------------------------------------------------------------
   2) EMOCIONES QUE EL SISTEMA PUEDE INFERIR
      catalogo_emocion(Id, DescripcionCorta).
   --------------------------------------------------------------------------- */
catalogo_emocion(alegria,    'Estado animico positivo y con energia.').
catalogo_emocion(tristeza,   'Animo bajo y poca energia.').
catalogo_emocion(estres,     'Tension alta con mucha activacion.').
catalogo_emocion(enojo,      'Tension alta, animo bajo y energia alta.').
catalogo_emocion(calma,      'Baja tension, animo estable.').
catalogo_emocion(motivacion, 'Animo y energia altos orientados a una actividad.').

/* ---------------------------------------------------------------------------
   3) REGLAS - ETAPA 1: respuestas del usuario -> emocion(E)
      (EJEMPLOS DE ARRANQUE: Osiel los puede cambiar/completar. Si cambian
       condiciones o IDs, actualicen pruebas/pruebas.pl)
      Recordatorio: orden = prioridad (especificas arriba, generales abajo).
      Sugerencia de partida para las demas emociones:
        enojo      : tension(alta) + animo(bajo) + energia(alta)   (antes de estres)
        calma      : tension(baja) + animo(neutro) + energia(baja)
        motivacion : animo(alto) + energia(alta) + contexto(ejercicio)  (antes de alegria)
   --------------------------------------------------------------------------- */
regla(r01, [animo(bajo), energia(baja)],            emocion(tristeza)).
regla(r02, [tension(alta), energia(alta)],          emocion(estres)).
regla(r03, [animo(alto), energia(alta)],            emocion(alegria)).
% TODO Osiel: r04 enojo, r05 calma, r06 motivacion, ... (hasta r29 si hace falta)

/* ---------------------------------------------------------------------------
   4) REGLAS - ETAPA 2: emocion + contexto + objetivo -> perfil(Energia, Animo)
      perfil(EnergiaMusical, AnimoMusical) con valores baja/media/alta y
      bajo/neutro/alto (los mismos que usan las canciones).
      OJO con la prioridad: r30 (dormir) va ANTES que las de emocion, asi que
      si el usuario va a dormir, esa regla gana sin importar la emocion.
   --------------------------------------------------------------------------- */
regla(r30, [contexto(dormir)],                          perfil(baja, neutro)).
regla(r31, [emocion(tristeza), objetivo(acompanar)],    perfil(baja, bajo)).
regla(r32, [emocion(tristeza), objetivo(cambiar)],      perfil(media, alto)).
regla(r33, [emocion(estres),   objetivo(cambiar)],      perfil(baja, neutro)).
regla(r34, [emocion(alegria),  objetivo(acompanar)],    perfil(alta, alto)).
% TODO Osiel: cubrir TODAS las combinaciones emocion x objetivo (6 x 2 = 12
%             reglas, menos las que ya esten) y los contextos que importen.

/* ---------------------------------------------------------------------------
   5) DESCRIPCIONES (las muestra el modulo de explicacion)
      descripcion(Id, 'Texto breve que justifique la regla').
      Idealmente cita la fuente en el reporte (APA), no aqui.
   --------------------------------------------------------------------------- */
descripcion(r01, 'Un animo bajo con poca energia indica tristeza.').
descripcion(r02, 'Mucha tension con mucha energia indica estres.').
descripcion(r03, 'Animo alto con mucha energia indica alegria.').
descripcion(r30, 'Para dormir conviene musica suave y estable.').
descripcion(r31, 'Si quieres acompanar la tristeza: musica lenta y melancolica.').
descripcion(r32, 'Si quieres salir de la tristeza: musica luminosa de energia media.').
descripcion(r33, 'Para reducir el estres: musica lenta y neutra.').
descripcion(r34, 'Para acompanar la alegria: musica energica y positiva.').
