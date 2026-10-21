# Guía del reporte (quién escribe qué)

Escriban cada quien su sección **conforme avanzan**, no el domingo.
Antulio ensambla, revisa formato, referencias APA 7, portada e índice.
Revisen en el documento original del proyecto (`Proyecto_U3`) el formato y la rúbrica exactos.

| Sección | Responsable | Qué debe incluir | Archivo relacionado |
|---|---|---|---|
| Portada e índice | Antulio | Datos del equipo, materia, fecha | — |
| Introducción | Antulio | Problema, justificación, alcance | — |
| Objetivos | Antulio (revisan todos) | General y específicos | — |
| Adquisición del conocimiento | Osiel | Fuentes, expertos o literatura sobre música y emoción | `conocimiento/` |
| Representación del conocimiento | Osiel | Variables y valores, **tabla de decisiones**, **árbol de decisión**, lista de reglas R01..Rn | `conocimiento/reglas.pl` |
| Diseño del sistema experto | Ale | Arquitectura, motor, por qué encadenamiento hacia adelante, explicación, resolución de conflictos | `src/motor.pl`, `src/explicacion.pl` |
| Programación e interfaces | Antulio | Cómo se programó, capturas de la GUI y la consola, cómo reproducir música | `src/interfaz.pl`, `src/musica.pl` |
| Pruebas y validación | Ale | Tabla T01..Tn (entrada, reglas, esperado, obtenido, PASS/FAIL) y **correcciones realizadas** | `pruebas/pruebas.pl` |
| Conclusión | Ale (aportan todos) | Logros, limitaciones, mejoras futuras (por ejemplo, API de Spotify) | — |
| Referencias | Antulio | APA 7, solo fuentes realmente citadas | — |

## Truco: la tabla de pruebas casi sale sola
`?- correr_pruebas.` imprime para cada caso: entrada, reglas esperadas/obtenidas y resultado. Copien esa salida a la tabla.

## Coherencia (lo que más se revisa)
Un mismo caso debe poder seguirse: **variables → tabla de decisiones → árbol → regla R## → código → prueba T##**, con los mismos nombres e IDs en todos lados.
