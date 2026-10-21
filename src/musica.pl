:- encoding(utf8).
/* ============================================================================
   src/musica.pl                    >>> RESPONSABLE: ANTULIO <<<
   REPRODUCCION / ENLACES DE MUSICA
   ============================================================================
   Decision de alcance: NO usamos API de Spotify. Solo abrimos el enlace de la
   cancion en el navegador (YouTube/Spotify), que funciona en cualquier PC y no
   requiere claves, cuenta Premium ni internet para programar.

   PREDICADOS PUBLICOS (ya funcionan; Antulio puede mejorarlos):
     texto_cancion(+Cancion, -Texto) : 'Titulo - Artista (genero, idioma)'
     reproducir(+Cancion)            : abre el Enlace en el navegador.
                                       Si falla, imprime el enlace para copiarlo.

   Una Cancion es el termino completo:
     cancion(Id, Titulo, Artista, Genero, Energia, Animo, Idioma, Enlace)

   EJEMPLO:
     ?- cancion(c001,T,A,G,E,N,I,L), reproducir(cancion(c001,T,A,G,E,N,I,L)).

   IDEAS OPCIONALES (solo si sobra tiempo, NO antes del viernes):
   - Boton "Abrir todas" que abra las 3 canciones.
   - Generar la URL de busqueda desde Titulo+Artista si Enlace esta vacio.
   NO subir claves de ninguna API al repositorio.
   ============================================================================ */

:- use_module(library(www_browser)).

texto_cancion(cancion(_Id, Titulo, Artista, Genero, _E, _A, Idioma, _Enlace), Texto) :-
    format(atom(Texto), '~w - ~w (~w, ~w)', [Titulo, Artista, Genero, Idioma]).

reproducir(cancion(_Id, _T, _Ar, _G, _E, _A, _I, Enlace)) :-
    (   catch(www_open_url(Enlace), _Error, fail)
    ->  true
    ;   format('No pude abrir el navegador. Copia este enlace:~n  ~w~n', [Enlace])
    ).
