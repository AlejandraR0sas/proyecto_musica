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

:- multifile catalogo_emocion/2, regla/3, descripcion/2.
:- dynamic   catalogo_emocion/2, regla/3, descripcion/2.

% ===== LO APRENDIDO EMPIEZA AQUI (no escribir arriba de esta linea) =====