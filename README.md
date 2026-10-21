# 🎵 Recomendador de música por emoción (Prolog)

Sistema experto en **SWI-Prolog** que infiere la emoción del usuario a partir de unas
preguntas cortas y le recomienda canciones, explicando **por qué**. Base de conocimientos,
motor de inferencia e interfaz, todo en Prolog.

---

## 1. Cómo correrlo

Requisitos: [SWI-Prolog](https://www.swi-prolog.org/Download.html) (la versión de escritorio trae XPCE para la interfaz gráfica).

```bash
git clone <URL-DEL-REPO>
cd proyecto-musica
swipl src/main.pl
```

Dentro de Prolog:

```prolog
?- iniciar.          % abre la GUI; si no existe o falla, usa la consola
?- consola.          % fuerza el modo consola
?- correr_pruebas.   % corre todos los casos de pruebas/pruebas.pl
```

> Si `swipl` no se reconoce en la terminal, abran `src/main.pl` con la aplicación SWI-Prolog.
> **Todos** verifiquen hoy que el esqueleto carga sin errores y que `?- iniciar.` abre la consola.

---

## 2. Cómo funciona

```
Preguntas al usuario ──► ETAPA 1 (reglas r01-r29) ──► emocion(E)
animo, energia, tension,
contexto, objetivo      ──► ETAPA 2 (reglas r30-r59) ──► perfil(Energia, Animo)
                        ──► ETAPA 3: catálogo ──► hasta 3 canciones (al azar entre las que cumplen)
                        ──► Explicación: qué reglas se dispararon y por qué
                        ──► Abrir la canción en el navegador (sin API)
```

- **Encadenamiento hacia adelante:** se parte de las respuestas (datos) y se deduce hasta que ninguna regla aplica.
- **Prioridad = orden en `reglas.pl`.** La primera regla aplicable gana.
- **Una sola emoción y un solo perfil por consulta** (lo garantiza el motor).
- Reproducir música = **abrir un enlace** en el navegador. Decidimos **no usar la API de Spotify** (requiere claves/OAuth/Premium y es riesgosa para la demo).

---

## 3. Acuerdos compartidos (NO cambiar sin avisar al grupo)

### Variables de entrada
| Variable | Valores permitidos |
|---|---|
| `animo` | `bajo`, `neutro`, `alto` |
| `energia` | `baja`, `media`, `alta` |
| `tension` | `baja`, `media`, `alta` |
| `contexto` | `estudiar`, `ejercicio`, `relajarse`, `fiesta`, `dormir`, `manejar` |
| `objetivo` | `acompanar`, `cambiar` |

### Emociones
`alegria`, `tristeza`, `estres`, `enojo`, `calma`, `motivacion`

### Formatos
```prolog
regla(r01, [animo(bajo), energia(baja)], emocion(tristeza)).        % r01-r29 etapa 1
regla(r31, [emocion(tristeza), objetivo(acompanar)], perfil(baja, bajo)).  % r30-r59 etapa 2
descripcion(r01, 'Un ánimo bajo con poca energía indica tristeza.').
cancion(c001, 'Fix You', 'Coldplay', rock, baja, bajo, ingles, 'https://www.youtube.com/results?search_query=Coldplay+Fix+You').
```
- La **energía y el ánimo del `perfil`** usan los mismos valores que los campos 5 y 6 de `cancion/8`.
- Átomos en **minúsculas y sin acentos ni ñ** (`acompanar`, `alegria`). Los textos entre comillas sí pueden llevar acentos.
- IDs: reglas `r01…` (en el reporte `R01…`), pruebas `t01…` (`T01…`), canciones `c001…`.
  **Deben coincidir idénticos** en código, tabla de decisiones, árbol y pruebas.

### Predicados que usamos entre módulos (el "contrato")
| Predicado | Dónde | Qué hace |
|---|---|---|
| `capturar(Var, Valor)` | `hechos.pl` | Valida y guarda una respuesta; **falla** si es inválida |
| `mensaje_invalido(Var, Valor, Msg)` | `hechos.pl` | Texto de error para mostrar |
| `limpiar_hechos` | `hechos.pl` | Borra todo (nueva consulta) |
| `ejecutar_consulta(Res)` | `motor.pl` | Flujo completo (ver resultados abajo) |
| `explicar(Texto)` / `explicar_lineas(L)` | `explicacion.pl` | Explica qué reglas se aplicaron |
| `texto_cancion(C, Texto)` | `musica.pl` | Texto bonito de una canción |
| `reproducir(Cancion)` | `musica.pl` | Abre el enlace en el navegador |
| `iniciar_gui` | `interfaz.pl` | Abre la ventana (si falla, `main.pl` usa la consola) |

`Res` de `ejecutar_consulta/1` es uno de:
`ok(Emocion, perfil(E,A), Canciones)` · `incompleto(Faltantes)` · `sin_emocion` · `sin_perfil(Emocion)` · `sin_canciones(perfil(E,A))`

---

## 4. Reparto de trabajo

> Cada quien edita **solo sus archivos**. Si necesitas un cambio en un archivo ajeno, pídelo por el grupo o con un *Issue*. Cada archivo `.pl` trae al inicio su guía detallada y su checklist.

### Ale — Motor, explicación, pruebas e integración
**Archivos:** `src/motor.pl`, `src/hechos.pl`, `src/explicacion.pl`, `src/main.pl`, `pruebas/pruebas.pl`
- [ ] Revisar y corregir el esqueleto (no se pudo ejecutar al generarlo): que cargue y que `correr_pruebas.` dé PASS
- [ ] Mantener el repo: revisar Pull Requests, resolver conflictos
- [ ] Casos de prueba T01..Tn: normales, inválidos, incompletos, sin regla aplicable, nueva consulta
- [ ] Registrar y documentar las correcciones que salgan de las pruebas
- [ ] **Reporte:** Diseño del sistema experto (motor, encadenamiento, explicación), Pruebas y validación, Conclusión

### Osiel — Base de conocimientos
**Archivos:** `conocimiento/reglas.pl`, `conocimiento/canciones.pl`
- [ ] Hoy: confirmar variables, valores y emociones (sección 3)
- [ ] Reglas de las 6 emociones (etapa 1) y emoción × objetivo (etapa 2), con `descripcion/2` en cada una
- [ ] Catálogo de **30 canciones** (5 por emoción) con enlaces de búsqueda de YouTube
- [ ] Revisar coherencia: sin contradicciones, y cada perfil usado tiene canciones
- [ ] **Reporte:** Adquisición del conocimiento (fuentes), Representación: variables, **tabla de decisiones**, **árbol de decisión** y lista de reglas R01..Rn

### Antulio — Interfaz y música
**Archivos:** `src/interfaz.pl`, `src/musica.pl`
- [ ] Hoy: confirmar que **XPCE abre** en tu PC (`?- new(D, dialog('Prueba')), send(D, open).`)
- [ ] Ventana con un menú por variable (generado desde `variable/3`), botones Recomendar / Por qué / Abrir canción / Nueva consulta
- [ ] Manejo visual de los 5 tipos de resultado y de errores
- [ ] Capturas de pantalla para el reporte
- [ ] **Reporte:** Introducción, Objetivos (general y específicos), Programación e interfaces, Referencias APA 7, portada, índice y **ensamblado final**

---

## 5. Calendario

| Día | Meta |
|---|---|
| **Mié 21 (hoy)** | Reunión de 1 h: cerrar variables/contrato, repo en GitHub, XPCE probado, esqueleto corriendo. Osiel inicia reglas; Antulio ventana vacía + botón que abre enlace; Ale revisa el esqueleto |
| **Jue 22** | Sistema completo **por consola** (6 emociones, 15 canciones). GUI conectada al motor. Al final del día: **hito de integración** en `main` |
| **Vie 23** | 30 canciones, árbol y tabla de decisiones, casos de prueba, GUI pulida. **Se congela el código al final del día** (después solo se corrigen errores) |
| **Sáb 24** | Correcciones de lo que fallen las pruebas (documentarlas), secciones del reporte, ensamblado y ensayo de la demo |
| **Dom 25** | Revisión final y **entrega temprano**. Sin tocar código |

---

## 6. Flujo de Git

```bash
git pull                              # SIEMPRE antes de empezar
git checkout -b feat/mi-tarea         # ramas: feat/motor, feat/reglas, feat/interfaz
git add .
git commit -m "reglas: agrega r04-r06 (enojo, calma, motivacion)"
git push -u origin feat/mi-tarea      # y abrir Pull Request hacia main
```
- Nada de commits directos a `main`; los PR los revisa otra persona.
- Commits chicos y frecuentes, con mensaje claro.
- **Nunca** subir claves ni contraseñas (ya están en `.gitignore`: `secretos.pl`, `.env`).

---

## 7. Checklist de entrega

- [ ] `?- correr_pruebas.` sin FAIL (o fallos documentados y explicados)
- [ ] Base de conocimientos en archivos externos (`conocimiento/`)
- [ ] Explicación del resultado funcionando
- [ ] Manejo de datos inválidos, incompletos y "sin regla aplicable"
- [ ] Botón/opción de nueva consulta que limpia los hechos
- [ ] IDs `R01..`/`T01..` coinciden entre código, tabla, árbol y reporte
- [ ] Reporte en `reporte/` (ver `reporte/GUIA_REPORTE.md`)
- [ ] Demo ensayada: 3 emociones distintas + 1 caso de error