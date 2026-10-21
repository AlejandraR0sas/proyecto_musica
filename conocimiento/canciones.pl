:- encoding(utf8).
/* ============================================================================
   PROPUESTA de conocimiento/canciones.pl      >>> RESPONSABLE: OSIEL <<<
   BORRADOR PARA REVISION: 
   ============================================================================
   BASE DE CONOCIMIENTOS (parte 2): catalogo de 30 canciones etiquetadas.
   5 canciones por emocion (grupos comentados) y cobertura de los 7 perfiles
   que usan las reglas de etapa 2.

   FORMATO (8 campos, SIEMPRE en este orden):
     cancion(Id, Titulo, Artista, Genero, Energia, Animo, Idioma, Enlace).
       Id       : atomo unico c001..c030
       Energia  : baja | media | alta
       Animo    : bajo | neutro | alto
       Idioma   : espanol | ingles | instrumental | otro
       Enlace   : busqueda de YouTube (no caduca)

   NOTA: se conservan los IDs originales c001-c004 (Fix You, Here Comes the
   Sun, Weightless, Happy). El resto se agrega alrededor de esos IDs.

   TAREAS DE OSIEL (checklist)
   [x] 30 canciones, 5 por emocion
   [x] Variedad de generos e idiomas (rock, pop, clasica, ambient, electronica,
       hiphop, metal, folk, country, funk, salsa; ingles, espanol, instrumental)
   [x] Ids unicos, sin campos vacios, enlaces de busqueda de YouTube
   [x] Todos los perfiles usados en reglas.pl tienen al menos una cancion
   ============================================================================ */

:- discontiguous cancion/8.

% ---- TRISTEZA (5) -----------------------------------------------------------
% Perfil acompanar: baja/bajo (c001, c005, c006). Cambiar: media/alto (c002, c007).
cancion(c001, 'Fix You', 'Coldplay', rock, baja, bajo, ingles,
        'https://www.youtube.com/results?search_query=Coldplay+Fix+You').
cancion(c002, 'Here Comes the Sun', 'The Beatles', rock, media, alto, ingles,
        'https://www.youtube.com/results?search_query=The+Beatles+Here+Comes+the+Sun').
cancion(c005, 'Tears in Heaven', 'Eric Clapton', rock, baja, bajo, ingles,
        'https://www.youtube.com/results?search_query=Eric+Clapton+Tears+in+Heaven').
cancion(c006, 'Hurt', 'Johnny Cash', country, baja, bajo, ingles,
        'https://www.youtube.com/results?search_query=Johnny+Cash+Hurt').
cancion(c007, 'Viva la Vida', 'Coldplay', rock, media, alto, ingles,
        'https://www.youtube.com/results?search_query=Coldplay+Viva+la+Vida').

% ---- ESTRES (5) -------------------------------------------------------------
% Perfil acompanar: media/bajo (c010, c011). Cambiar: baja/neutro (c003, c008, c009).
cancion(c003, 'Weightless', 'Marconi Union', ambient, baja, neutro, instrumental,
        'https://www.youtube.com/results?search_query=Marconi+Union+Weightless').
cancion(c008, 'Clair de Lune', 'Claude Debussy', clasica, baja, neutro, instrumental,
        'https://www.youtube.com/results?search_query=Claude+Debussy+Clair+de+Lune').
cancion(c009, 'Gymnopedie No. 1', 'Erik Satie', clasica, baja, neutro, instrumental,
        'https://www.youtube.com/results?search_query=Erik+Satie+Gymnopedie+No+1').
cancion(c010, 'Creep', 'Radiohead', rock, media, bajo, ingles,
        'https://www.youtube.com/results?search_query=Radiohead+Creep').
cancion(c011, 'Numb', 'Linkin Park', rock, media, bajo, ingles,
        'https://www.youtube.com/results?search_query=Linkin+Park+Numb').

% ---- ENOJO (5) --------------------------------------------------------------
% Perfil acompanar: alta/bajo (c012-c014). Cambiar: media/alto (c015, c016).
cancion(c012, 'Killing in the Name', 'Rage Against the Machine', rock, alta, bajo, ingles,
        'https://www.youtube.com/results?search_query=Rage+Against+the+Machine+Killing+in+the+Name').
cancion(c013, 'Break Stuff', 'Limp Bizkit', metal, alta, bajo, ingles,
        'https://www.youtube.com/results?search_query=Limp+Bizkit+Break+Stuff').
cancion(c014, 'Given Up', 'Linkin Park', rock, alta, bajo, ingles,
        'https://www.youtube.com/results?search_query=Linkin+Park+Given+Up').
cancion(c015, 'Riptide', 'Vance Joy', pop, media, alto, ingles,
        'https://www.youtube.com/results?search_query=Vance+Joy+Riptide').
cancion(c016, 'Ho Hey', 'The Lumineers', folk, media, alto, ingles,
        'https://www.youtube.com/results?search_query=The+Lumineers+Ho+Hey').

% ---- CALMA (5) --------------------------------------------------------------
% Perfil acompanar: baja/neutro (c017, c018). Cambiar: media/neutro (c019), media/alto (c020, c021).
cancion(c017, 'River Flows in You', 'Yiruma', clasica, baja, neutro, instrumental,
        'https://www.youtube.com/results?search_query=Yiruma+River+Flows+in+You').
cancion(c018, 'Ocean Eyes', 'Billie Eilish', pop, baja, neutro, ingles,
        'https://www.youtube.com/results?search_query=Billie+Eilish+Ocean+Eyes').
cancion(c019, 'Intro', 'The xx', electronica, media, neutro, instrumental,
        'https://www.youtube.com/results?search_query=The+xx+Intro').
cancion(c020, 'Budapest', 'George Ezra', folk, media, alto, ingles,
        'https://www.youtube.com/results?search_query=George+Ezra+Budapest').
cancion(c021, 'Count on Me', 'Bruno Mars', pop, media, alto, ingles,
        'https://www.youtube.com/results?search_query=Bruno+Mars+Count+on+Me').

% ---- MOTIVACION (5) ---------------------------------------------------------
% Perfil acompanar: alta/alto (c022-c024). Cambiar: media/neutro (c025, c026).
cancion(c022, 'Eye of the Tiger', 'Survivor', rock, alta, alto, ingles,
        'https://www.youtube.com/results?search_query=Survivor+Eye+of+the+Tiger').
cancion(c023, 'Stronger', 'Kanye West', hiphop, alta, alto, ingles,
        'https://www.youtube.com/results?search_query=Kanye+West+Stronger').
cancion(c024, 'Titanium', 'David Guetta feat. Sia', electronica, alta, alto, ingles,
        'https://www.youtube.com/results?search_query=David+Guetta+Titanium').
cancion(c025, 'Awake', 'Tycho', electronica, media, neutro, instrumental,
        'https://www.youtube.com/results?search_query=Tycho+Awake').
cancion(c026, 'Feather', 'Nujabes', hiphop, media, neutro, instrumental,
        'https://www.youtube.com/results?search_query=Nujabes+Feather').

% ---- ALEGRIA (5) ------------------------------------------------------------
% Perfil acompanar: alta/alto (c004, c027, c028, c030). Cambiar: media/neutro (c029).
cancion(c004, 'Happy', 'Pharrell Williams', pop, alta, alto, ingles,
        'https://www.youtube.com/results?search_query=Pharrell+Williams+Happy').
cancion(c027, 'Uptown Funk', 'Mark Ronson feat. Bruno Mars', funk, alta, alto, ingles,
        'https://www.youtube.com/results?search_query=Mark+Ronson+Uptown+Funk').
cancion(c028, 'Shake It Off', 'Taylor Swift', pop, alta, alto, ingles,
        'https://www.youtube.com/results?search_query=Taylor+Swift+Shake+It+Off').
cancion(c029, 'Kerala', 'Bonobo', electronica, media, neutro, instrumental,
        'https://www.youtube.com/results?search_query=Bonobo+Kerala').
cancion(c030, 'Vivir Mi Vida', 'Marc Anthony', salsa, alta, alto, espanol,
        'https://www.youtube.com/results?search_query=Marc+Anthony+Vivir+Mi+Vida').
