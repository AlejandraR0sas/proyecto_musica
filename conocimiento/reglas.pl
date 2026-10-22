:- encoding(utf8).
/* ============================================================================
   PROPUESTA de conocimiento/reglas.pl        >>> RESPONSABLE: OSIEL <<<
   BORRADOR PARA REVISION: no sustituye al archivo original todavia.
   ============================================================================
   BASE DE CONOCIMIENTOS (parte 1): variables, emociones y reglas de produccion.

   Este archivo es el CORAZON del sistema experto. Solo contiene HECHOS Prolog
   (datos), nada de logica. El motor (src/motor.pl) es generico y lee esto.

   QUE VA AQUI (4 tipos de hechos):
     1) variable/3          -> las preguntas de entrada y sus valores permitidos
     2) catalogo_emocion/2  -> las emociones que el sistema puede inferir
     3) regla/3             -> las reglas SI-ENTONCES, cada una con ID
     4) descripcion/2       -> texto en espanol de cada regla (lo usa la explicacion)

   ---------------------------------------------------------------------------
   REGLAS DE ORO
   ---------------------------------------------------------------------------
   * TODO en minusculas, SIN acentos ni enes en los atomos (acompanar, alegria).
     Los acentos solo en textos de descripcion/pregunta (entre comillas simples).
   * Una variable de entrada se escribe como termino: animo(bajo), energia(alta)
   * IDs de regla: r01, r02... (minuscula en codigo; en el reporte: R01, R02...)
       r01-r29  -> ETAPA 1: de las respuestas del usuario -> emocion(...)
       r30-r59  -> ETAPA 2: de emocion/contexto/objetivo   -> perfil(Energia,Animo)
   * El ORDEN en el archivo = PRIORIDAD. Si dos reglas pueden dar una emocion
     (o un perfil), gana la que esta MAS ARRIBA. Las mas especificas van primero
     y las mas generales al final.
   * Solo se permite UNA emocion y UN perfil por consulta (lo garantiza el motor).
   * Cada ID de aqui debe aparecer igual en: tabla de decisiones, arbol de
     decision, descripcion/2 y pruebas/pruebas.pl (columna "reglas esperadas").

   ---------------------------------------------------------------------------
   FORMATO DE regla/3
   ---------------------------------------------------------------------------
       regla(Id, [Condicion1, Condicion2, ...], Conclusion).

   * Condicion = un hecho: animo(bajo), energia(baja), emocion(tristeza), etc.
   * Tambien se acepta no(Hecho) solo sobre variables de ENTRADA.
   * Conclusion = emocion(E)  o  perfil(EnergiaMusical, AnimoMusical)

   ---------------------------------------------------------------------------
   COMO SE CONECTA CON LAS CANCIONES
   ---------------------------------------------------------------------------
   perfil(Energia, Animo) se compara con los campos Energia y Animo de
   cancion/8 (conocimiento/canciones.pl). Mismos valores: baja/media/alta y
   bajo/neutro/alto. Cada perfil usado aqui tiene canciones en el catalogo.

   ---------------------------------------------------------------------------
   TAREAS DE OSIEL (checklist)
   ---------------------------------------------------------------------------
   [x] Investigar fuentes (musicoterapia, psicologia de la musica) -> reporte
   [x] Confirmar variables y valores (sin cambios respecto al acuerdo del README)
   [x] Cubrir las 6 emociones con reglas de etapa 1 (r01-r07)
   [x] Cubrir cada emocion x objetivo (acompanar/cambiar) en etapa 2 (r30-r42)
   [x] Escribir una descripcion/2 por cada regla
   [x] Revisar coherencia: sin reglas contradictorias y todos los perfiles con
       canciones. Combinaciones NO cubiertas documentadas en propuestas/REVISION.md
   [ ] Dibujar arbol de decision + tabla de decisiones para el reporte
       (borrador listo en propuestas/REVISION.md; falta pasarlo al documento)
   [ ] Avisar a Ale de los cambios de IDs/resultados que afectan pruebas.pl
       (T06 cambia y faltan casos para enojo, calma y motivacion)
   ============================================================================ */

:- discontiguous variable/3, catalogo_emocion/2, regla/3, descripcion/2.

/* ---------------------------------------------------------------------------
   1) VARIABLES DE ENTRADA  (confirmadas, sin cambios)
      variable(Nombre, ValoresPermitidos, TextoDeLaPregunta).
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
   2) EMOCIONES QUE EL SISTEMA PUEDE INFERIR  (6 confirmadas)
    --------------------------------------------------------------------------- */
catalogo_emocion(alegria,    'Estado animico positivo y con energia.').
catalogo_emocion(tristeza,   'Animo bajo y poca energia.').
catalogo_emocion(estres,     'Tension alta con mucha activacion.').
catalogo_emocion(enojo,      'Tension alta, animo bajo y energia alta.').
catalogo_emocion(calma,      'Baja tension, animo estable.').
catalogo_emocion(motivacion, 'Animo y energia altos orientados a una actividad.').
/* ---------------------------------------------------------------------------
   2b) SINONIMOS: palabras que el usuario puede escribir y que significan una
       emocion del catalogo.  sinonimo(PalabraEscrita, EmocionDelCatalogo).
       (minusculas, sin acentos).
   --------------------------------------------------------------------------- */
sinonimo(triste,      tristeza).
sinonimo(feliz,       alegria).
sinonimo(contento,    alegria).
sinonimo(estresado,   estres).
sinonimo(ansioso,     estres).
sinonimo(enojado,     enojo).
sinonimo(molesto,     enojo).
sinonimo(tranquilo,   calma).
sinonimo(motivado,    motivacion).

/* ---------------------------------------------------------------------------
   3) REGLAS - ETAPA 1: respuestas del usuario -> emocion(E)
      ORDEN = PRIORIDAD. Las especificas van antes que las generales.
      Nota: los IDs se conservan de la version anterior (r01 tristeza,
      r02 estres, r03 alegria) para no romper T01-T05; el orden fisico manda.
    --------------------------------------------------------------------------- */
% 1. Enojo: alta activacion + tension + animo bajo (lo mas especifico).
regla(r04, [tension(alta), animo(bajo), energia(alta)], emocion(enojo)).

% 2. Motivacion: alegria con energia puesta en una actividad.
regla(r06, [animo(alto), energia(alta), contexto(ejercicio)], emocion(motivacion)).

% 3-4. Calma: baja tension con animo estable (dos niveles de energia).
regla(r05, [tension(baja), animo(neutro), energia(baja)], emocion(calma)).
regla(r07, [tension(baja), animo(neutro), energia(media)], emocion(calma)).

% 5. Tristeza: animo bajo con poca energia.
regla(r01, [animo(bajo), energia(baja)], emocion(tristeza)).

% 6. Estres: alta tension con alta activacion (ya filtrados enojo y motivacion).
regla(r02, [tension(alta), energia(alta)], emocion(estres)).

% 7. Alegria: animo alto con alta energia (ya filtrada la motivacion).
regla(r03, [animo(alto), energia(alta)], emocion(alegria)).

/* ---------------------------------------------------------------------------
   4) REGLAS - ETAPA 2: emocion + contexto + objetivo -> perfil(Energia, Animo)
      perfil(EnergiaMusical, AnimoMusical) con valores baja/media/alta y
      bajo/neutro/alto (los mismos que usan las canciones).
      r30 (dormir) va ANTES que las de emocion: si el usuario va a dormir,
      esa regla gana sin importar la emocion.
    --------------------------------------------------------------------------- */
% Contexto especial (prioridad maxima).
regla(r30, [contexto(dormir)],                          perfil(baja, neutro)).

% Una regla por emocion x objetivo (IDs en orden; no compiten entre si).
regla(r31, [emocion(tristeza),  objetivo(acompanar)],   perfil(baja, bajo)).
regla(r32, [emocion(tristeza),  objetivo(cambiar)],     perfil(media, alto)).
regla(r33, [emocion(estres),    objetivo(cambiar)],     perfil(baja, neutro)).
regla(r34, [emocion(alegria),   objetivo(acompanar)],   perfil(alta, alto)).
regla(r35, [emocion(estres),    objetivo(acompanar)],   perfil(media, bajo)).
regla(r36, [emocion(enojo),     objetivo(acompanar)],   perfil(alta, bajo)).
regla(r37, [emocion(enojo),     objetivo(cambiar)],     perfil(media, alto)).
regla(r38, [emocion(calma),     objetivo(acompanar)],   perfil(baja, neutro)).
regla(r39, [emocion(calma),     objetivo(cambiar)],     perfil(media, alto)).
regla(r40, [emocion(motivacion), objetivo(acompanar)],  perfil(alta, alto)).
regla(r41, [emocion(motivacion), objetivo(cambiar)],    perfil(media, neutro)).
regla(r42, [emocion(alegria),   objetivo(cambiar)],     perfil(media, neutro)).

/* ---------------------------------------------------------------------------
   5) DESCRIPCIONES (las muestra el modulo de explicacion)
      descripcion(Id, 'Texto breve que justifique la regla').
      Idealmente cita la fuente en el reporte (APA), no aqui.
    --------------------------------------------------------------------------- */
descripcion(r01, 'Animo bajo con poca energia indica tristeza.').
descripcion(r02, 'Alta tension con alta energia indica estres.').
descripcion(r03, 'Animo alto con alta energia indica alegria.').
descripcion(r04, 'Tension alta con animo bajo y energia alta indica enojo.').
descripcion(r05, 'Baja tension con animo neutro y energia baja indica calma.').
descripcion(r06, 'Animo alto con energia alta en una actividad fisica indica motivacion.').
descripcion(r07, 'Baja tension con animo neutro y energia media indica calma.').

descripcion(r30, 'Para dormir conviene musica suave y estable.').
descripcion(r31, 'Si quieres acompanar la tristeza: musica lenta y melancolica.').
descripcion(r32, 'Si quieres salir de la tristeza: musica luminosa de energia media.').
descripcion(r33, 'Para reducir el estres: musica lenta y neutra.').
descripcion(r34, 'Para acompanar la alegria: musica energetica y positiva.').
descripcion(r35, 'Para acompanar el estres: musica intensa de energia media.').
descripcion(r36, 'Para descargar el enojo: musica intensa de energia alta.').
descripcion(r37, 'Para cambiar el enojo: musica positiva de energia media.').
descripcion(r38, 'Para acompanar la calma: musica suave y estable.').
descripcion(r39, 'Para cambiar la calma: musica positiva de energia media.').
descripcion(r40, 'Para acompanar la motivacion: musica energetica y positiva.').
descripcion(r41, 'Para cambiar la motivacion: musica de energia media y tono neutro.').
descripcion(r42, 'Para cambiar la alegria: musica de energia media y tono neutro.').
