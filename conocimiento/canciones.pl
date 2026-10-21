:- encoding(utf8).
/* ============================================================================
   conocimiento/canciones.pl      >>> RESPONSABLE: OSIEL <<<
   BASE DE CONOCIMIENTOS (parte 2): catalogo de canciones etiquetadas.
   ============================================================================
   FORMATO (8 campos, SIEMPRE en este orden):

     cancion(Id, Titulo, Artista, Genero, Energia, Animo, Idioma, Enlace).

     Id       : atomo unico: c001, c002, ...
     Titulo   : 'Entre comillas simples'
     Artista  : 'Entre comillas simples'
     Genero   : rock, pop, ambient, clasica, electronica, hiphop, regional...
                (minusculas, sin acentos)
     Energia  : baja | media | alta        <- ENERGIA DE LA CANCION
     Animo    : bajo | neutro | alto       <- tono emocional (triste -> alegre)
     Idioma   : espanol | ingles | instrumental | otro
     Enlace   : URL que se abre en el navegador (ver abajo)

   Energia y Animo se comparan con perfil(Energia, Animo) de las reglas, por
   eso usan exactamente los mismos valores.

   META MINIMA: 30 canciones, 5 por emocion. Asegurense de tener canciones
   para CADA perfil(Energia, Animo) que aparezca en reglas.pl.

   SOBRE LOS ENLACES (importante para que la demo no falle):
   Usen enlaces de BUSQUEDA de YouTube, que no caducan y no hay que verificar
   ids de video. Formato (espacios -> signo +):
     'https://www.youtube.com/results?search_query=Coldplay+Fix+You'
   Si prefieren un enlace directo a un video o a Spotify, prueben que abra.

   TAREAS DE OSIEL (checklist)
   [ ] 15 canciones el jueves 22, 30 el viernes 23
   [ ] Variedad de generos e idiomas
   [ ] Revisar que no haya Ids repetidos y que ninguna tenga campos vacios
   ============================================================================ */

:- discontiguous cancion/8.

% ---- EJEMPLOS (se pueden conservar o reemplazar) ----------------------------
cancion(c001, 'Fix You', 'Coldplay', rock, baja, bajo, ingles,
        'https://www.youtube.com/results?search_query=Coldplay+Fix+You').
cancion(c002, 'Here Comes the Sun', 'The Beatles', rock, media, alto, ingles,
        'https://www.youtube.com/results?search_query=The+Beatles+Here+Comes+the+Sun').
cancion(c003, 'Weightless', 'Marconi Union', ambient, baja, neutro, instrumental,
        'https://www.youtube.com/results?search_query=Marconi+Union+Weightless').
cancion(c004, 'Happy', 'Pharrell Williams', pop, alta, alto, ingles,
        'https://www.youtube.com/results?search_query=Pharrell+Williams+Happy').

% TODO Osiel: c005 en adelante...
