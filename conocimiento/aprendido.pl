:- encoding(utf8).
/* ============================================================================
   conocimiento/aprendido.pl        >>> LO ESCRIBE EL SISTEMA, NO A MANO <<<
   ============================================================================
   Aqui se guardan las emociones que el sistema APRENDE de los usuarios
   (modulo src/aprendizaje.pl). Cada vez que alguien escribe una emocion que
   no conoce, el sistema pregunta que musica le va y agrega lineas al final
   de este archivo. Al volver a abrir el programa las carga de nuevo.

   - Reglas aprendidas usan IDs r60 en adelante (r60-r99).
   - Para "olvidar" lo aprendido (por ejemplo antes de la demo), borren las
     lineas que estan debajo de la marca de abajo, dejando las declaraciones.
   - Hagan commit de este archivo si quieren compartir lo aprendido.
   ============================================================================ */

:- multifile catalogo_emocion/2, regla/3, descripcion/2, cancion/8.
:- dynamic   catalogo_emocion/2, regla/3, descripcion/2, cancion/8.

% ===== LO APRENDIDO EMPIEZA AQUI (no escribir arriba de esta linea) =====
catalogo_emocion(nostalgia,'Emocion aprendida del usuario.').
regla(r60,[emocion(nostalgia),objetivo(acompanar)],perfil(baja,bajo)).
descripcion(r60,'Regla aprendida: para nostalgia con objetivo acompanar conviene musica de energia baja y animo bajo.').
regla(r61,[emocion(nostalgia),objetivo(cambiar)],perfil(alta,alto)).
descripcion(r61,'Regla aprendida: para nostalgia con objetivo cambiar conviene musica de energia alta y animo alto.').
cancion(c031,'pedro y pablo','los tigres del norte',norteno,alta,alto,otro,'https://www.youtube.com/results?search_query=los+tigres+del+norte+pedro+y+pablo').
cancion(c032,'Black in black','ACD/C',rock,alta,bajo,otro,'https://www.youtube.com/results?search_query=ACD/C+Black+in+black').
catalogo_emocion(miedo,'Emocion aprendida del usuario.').
regla(r62,[emocion(miedo),objetivo(acompanar)],perfil(baja,neutro)).
descripcion(r62,'Regla aprendida: para miedo con objetivo acompanar conviene musica de energia baja y animo neutro.').
regla(r63,[emocion(miedo),objetivo(cambiar)],perfil(alta,alto)).
descripcion(r63,'Regla aprendida: para miedo con objetivo cambiar conviene musica de energia alta y animo alto.').
catalogo_emocion(triston,'Emocion aprendida del usuario.').
regla(r64,[emocion(triston),objetivo(acompanar)],perfil(baja,bajo)).
descripcion(r64,'Regla aprendida: para triston con objetivo acompanar conviene musica de energia baja y animo bajo.').
regla(r65,[emocion(triston),objetivo(cambiar)],perfil(baja,bajo)).
descripcion(r65,'Regla aprendida: para triston con objetivo cambiar conviene musica de energia baja y animo bajo.').
