# Revisión de `conocimiento/reglas.pl` y `conocimiento/canciones.pl`

> **Estado:** propuesta para revisar. **Los archivos originales NO se han modificado.**
> Todo lo nuevo está en `propuestas/`:
>
> - `propuestas/reglas.pl` — reemplazo propuesto de `conocimiento/reglas.pl`
> - `propuestas/canciones.pl` — reemplazo propuesto de `conocimiento/canciones.pl`
> - `propuestas/validar_propuesta.pl` — validación automática (no toca los originales)
>
> Para validar: `swipl propuestas/validar_propuesta.pl -g reportar -t halt`

---

## 1. Checklist y pendientes por archivo

### 1.1 `conocimiento/reglas.pl`

| Tarea del backlog | Estado | Dónde quedó |
|---|---|---|
| Confirmar variables, valores y emociones (sección 3) | ✅ Hecho | 5 variables y 6 emociones, sin cambios respecto al README |
| Reglas de las 6 emociones (etapa 1) | ✅ Propuesto | R01–R07 |
| Emoción × objetivo (etapa 2) | ✅ Propuesto | R30–R42: 12 combinaciones + contexto `dormir` |
| `descripcion/2` en cada regla | ✅ Propuesto | 20 reglas, 20 descripciones |
| Coherencia: sin contradicciones y perfiles con canciones | ✅ Validado | 7 perfiles usados, todos con canciones; sin condiciones duplicadas |
| Reporte: tabla de decisiones, árbol y lista R01..Rn | 🟡 Borrador | Secciones 3–5 de este documento; falta pasarlo al reporte |

**Pendientes de `reglas.pl`**

- [ ] Aprobar la propuesta y reemplazar el archivo original.
- [ ] Avisar a Ale: **T06 cambia** y faltan casos para enojo, calma y motivación (sección 8).
- [ ] Pasar la tabla de decisiones, el árbol y la lista de reglas al documento del reporte.
- [ ] Revisar y citar las fuentes APA en la sección “Adquisición del conocimiento”.
- [ ] Ejecutar `?- correr_pruebas.` con las pruebas actualizadas y sin FAIL.

### 1.2 `conocimiento/canciones.pl`

| Tarea del backlog | Estado | Dónde quedó |
|---|---|---|
| Catálogo de 30 canciones (5 por emoción) | ✅ Propuesto | c001–c030 |
| Enlaces de búsqueda de YouTube | ✅ Propuesto | Los 30 enlaces completos están en `propuestas/canciones.pl` |
| Variedad de géneros e idiomas | ✅ Propuesto | 11 géneros; inglés, español e instrumental |
| Sin IDs repetidos ni campos vacíos | ✅ Validado | 30 IDs únicos y campos completos |
| Cada perfil usado tiene canciones | ✅ Validado | Cobertura en la sección 6.2 |

**Pendientes de `canciones.pl`**

- [ ] Aprobar la propuesta y reemplazar el archivo original.
- [ ] Opcional: ampliar `media/bajo` (hoy tiene 2 canciones) si se quiere más variedad en las recomendaciones.
- [ ] Opcional: abrir algunos enlaces antes de la demo para confirmar que el navegador los abre.
- [ ] Reporte: explicar el criterio de etiquetado (energía y ánimo) y citar las fuentes.

---

## 2. Variables y emociones confirmadas (sección 3)

No se propone cambiar nada de lo acordado en el README.

| Variable | Valores permitidos | Pregunta |
|---|---|---|
| `animo` | `bajo`, `neutro`, `alto` | ¿Cómo describirías tu ánimo en este momento? |
| `energia` | `baja`, `media`, `alta` | ¿Qué nivel de energía física tienes? |
| `tension` | `baja`, `media`, `alta` | ¿Qué tanta tensión o estrés sientes? |
| `contexto` | `estudiar`, `ejercicio`, `relajarse`, `fiesta`, `dormir`, `manejar` | ¿Qué vas a hacer mientras escuchas música? |
| `objetivo` | `acompanar`, `cambiar` | ¿Quieres que la música acompañe tu emoción o que la cambie? |

**Emociones:** `alegria`, `tristeza`, `estres`, `enojo`, `calma`, `motivacion`.

**Decisión de diseño:** se conservan los IDs originales `r01` (tristeza), `r02` (estrés) y `r03` (alegría), y los IDs `r30`–`r34` de etapa 2, para no romper T01–T05. Las reglas nuevas se agregan como `r04`–`r07` y `r35`–`r42`. El **orden físico del archivo** sigue siendo la prioridad.

---

## 3. Lista de reglas propuestas (R01–R42)

### 3.1 Etapa 1: respuestas → emoción (R01–R07)

Se listan en **orden de prioridad** (así están en el archivo). La primera que coincide gana.

| Prioridad | ID | Condiciones | Emoción | `descripcion/2` |
|---:|---|---|---|---|
| 1 | **R04** | `tension(alta)`, `animo(bajo)`, `energia(alta)` | enojo | Tensión alta con ánimo bajo y energía alta indica enojo. |
| 2 | **R06** | `animo(alto)`, `energia(alta)`, `contexto(ejercicio)` | motivación | Ánimo alto con energía alta en una actividad física indica motivación. |
| 3 | **R05** | `tension(baja)`, `animo(neutro)`, `energia(baja)` | calma | Baja tensión con ánimo neutro y energía baja indica calma. |
| 4 | **R07** | `tension(baja)`, `animo(neutro)`, `energia(media)` | calma | Baja tensión con ánimo neutro y energía media indica calma. |
| 5 | **R01** | `animo(bajo)`, `energia(baja)` | tristeza | Ánimo bajo con poca energía indica tristeza. |
| 6 | **R02** | `tension(alta)`, `energia(alta)` | estrés | Alta tensión con alta energía indica estrés. |
| 7 | **R03** | `animo(alto)`, `energia(alta)` | alegría | Ánimo alto con alta energía indica alegría. |

> Las reglas generales R02 y R03 quedan al final: si el caso ya cayó en R04 (enojo) o R06 (motivación), no se vuelven a evaluar.

### 3.2 Etapa 2: emoción + objetivo → perfil (R30–R42)

| ID | Emoción | Objetivo | Perfil | `descripcion/2` |
|---|---|---|---|---|
| **R30** | cualquiera | cualquiera, si `contexto(dormir)` | `perfil(baja, neutro)` | Para dormir conviene música suave y estable. |
| **R31** | tristeza | acompañar | `perfil(baja, bajo)` | Si quieres acompañar la tristeza: música lenta y melancólica. |
| **R32** | tristeza | cambiar | `perfil(media, alto)` | Si quieres salir de la tristeza: música luminosa de energía media. |
| **R33** | estrés | cambiar | `perfil(baja, neutro)` | Para reducir el estrés: música lenta y neutra. |
| **R34** | alegría | acompañar | `perfil(alta, alto)` | Para acompañar la alegría: música energética y positiva. |
| **R35** | estrés | acompañar | `perfil(media, bajo)` | Para acompañar el estrés: música intensa de energía media. |
| **R36** | enojo | acompañar | `perfil(alta, bajo)` | Para descargar el enojo: música intensa de energía alta. |
| **R37** | enojo | cambiar | `perfil(media, alto)` | Para cambiar el enojo: música positiva de energía media. |
| **R38** | calma | acompañar | `perfil(baja, neutro)` | Para acompañar la calma: música suave y estable. |
| **R39** | calma | cambiar | `perfil(media, alto)` | Para cambiar la calma: música positiva de energía media. |
| **R40** | motivación | acompañar | `perfil(alta, alto)` | Para acompañar la motivación: música energética y positiva. |
| **R41** | motivación | cambiar | `perfil(media, neutro)` | Para cambiar la motivación: música de energía media y tono neutro. |
| **R42** | alegría | cambiar | `perfil(media, neutro)` | Para cambiar la alegría: música de energía media y tono neutro. |

**Total:** 7 reglas de etapa 1 + 13 de etapa 2 = **20 reglas**, todas con `descripcion/2`.

---

## 4. Tabla de decisiones

### 4.1 Etapa 1 (evaluar de arriba a abajo)

| Prioridad | Regla | Ánimo | Energía | Tensión | Contexto | Emoción |
|---:|---|---|---|---|---|---|
| 1 | R04 | bajo | alta | alta | cualquiera | enojo |
| 2 | R06 | alto | alta | cualquiera | ejercicio | motivación |
| 3 | R05 | neutro | baja | baja | cualquiera | calma |
| 4 | R07 | neutro | media | baja | cualquiera | calma |
| 5 | R01 | bajo | baja | cualquiera | cualquiera | tristeza |
| 6 | R02 | cualquiera | alta | alta | cualquiera | estrés |
| 7 | R03 | alto | alta | cualquiera | cualquiera | alegría |
| — | — | resto de combinaciones | — | — | — | sin emoción |

### 4.2 Etapa 2 (emoción × objetivo)

| Emoción | Objetivo `acompanar` | Objetivo `cambiar` |
|---|---|---|
| tristeza | R31 → `baja/bajo` | R32 → `media/alto` |
| estrés | R35 → `media/bajo` | R33 → `baja/neutro` |
| enojo | R36 → `alta/bajo` | R37 → `media/alto` |
| calma | R38 → `baja/neutro` | R39 → `media/alto` |
| motivación | R40 → `alta/alto` | R41 → `media/neutro` |
| alegría | R34 → `alta/alto` | R42 → `media/neutro` |

**Excepción de contexto:** si `contexto(dormir)`, R30 gana siempre y devuelve `baja/neutro`, sin importar la emoción ni el objetivo.

---

## 5. Árbol de decisión

### 5.1 Etapa 1 (respuestas → emoción)

```
INICIO
├─ ¿tensión = alta?
│  ├─ ¿ánimo = bajo y energía = alta? ........................ ENOJO (R04)
│  └─ no
│     ├─ ¿ánimo = alto, energía = alta y contexto = ejercicio?  MOTIVACIÓN (R06)
│     └─ no
│        ├─ ¿energía = alta? .................................. ESTRÉS (R02)
│        └─ no
│           ├─ ¿ánimo = bajo y energía = baja? ................ TRISTEZA (R01)
│           └─ no ............................................. SIN EMOCIÓN
└─ no (tensión = media o baja)
   ├─ ¿ánimo = alto, energía = alta y contexto = ejercicio? .... MOTIVACIÓN (R06)
   └─ no
      ├─ ¿tensión = baja y ánimo = neutro?
      │  ├─ energía = baja ................................... CALMA (R05)
      │  ├─ energía = media .................................. CALMA (R07)
      │  └─ energía = alta
      │     ├─ ¿ánimo = alto y energía = alta? ............... ALEGRÍA (R03)
      │     └─ no ............................................ SIN EMOCIÓN
      └─ no
         ├─ ¿ánimo = bajo y energía = baja? .................. TRISTEZA (R01)
         ├─ ¿ánimo = alto y energía = alta? .................. ALEGRÍA (R03)
         └─ no ............................................... SIN EMOCIÓN
```

### 5.2 Etapa 2 (emoción + objetivo → perfil)

```
¿contexto = dormir? ── sí ──► perfil(baja, neutro) [R30]
└─ no
   ├─ tristeza ──► acompañar: perfil(baja, bajo)   [R31]
   │              cambiar:   perfil(media, alto)  [R32]
   ├─ estrés ────► acompañar: perfil(media, bajo)  [R35]
   │              cambiar:   perfil(baja, neutro) [R33]
   ├─ enojo ─────► acompañar: perfil(alta, bajo)   [R36]
   │              cambiar:   perfil(media, alto)  [R37]
   ├─ calma ─────► acompañar: perfil(baja, neutro) [R38]
   │              cambiar:   perfil(media, alto)  [R39]
   ├─ motivación ► acompañar: perfil(alta, alto)   [R40]
   │              cambiar:   perfil(media, neutro) [R41]
   └─ alegría ───► acompañar: perfil(alta, alto)   [R34]
                  cambiar:   perfil(media, neutro) [R42]
```

---

## 6. Catálogo de canciones

### 6.1 Las 30 canciones (5 por emoción)

Los enlaces completos de búsqueda de YouTube están en `propuestas/canciones.pl`.
En el código los átomos van sin acentos (`clasica`, `electronica`, `ingles`, `espanol`); en esta tabla se muestra la ortografía habitual.

#### Tristeza (5)

| ID | Título | Artista | Género | Energía | Ánimo | Idioma | Perfil |
|---|---|---|---|---|---|---|---|
| c001 | Fix You | Coldplay | rock | baja | bajo | inglés | baja/bajo |
| c002 | Here Comes the Sun | The Beatles | rock | media | alto | inglés | media/alto |
| c005 | Tears in Heaven | Eric Clapton | rock | baja | bajo | inglés | baja/bajo |
| c006 | Hurt | Johnny Cash | country | baja | bajo | inglés | baja/bajo |
| c007 | Viva la Vida | Coldplay | rock | media | alto | inglés | media/alto |

#### Estrés (5)

| ID | Título | Artista | Género | Energía | Ánimo | Idioma | Perfil |
|---|---|---|---|---|---|---|---|
| c003 | Weightless | Marconi Union | ambient | baja | neutro | instrumental | baja/neutro |
| c008 | Clair de Lune | Claude Debussy | clásica | baja | neutro | instrumental | baja/neutro |
| c009 | Gymnopédie No. 1 | Erik Satie | clásica | baja | neutro | instrumental | baja/neutro |
| c010 | Creep | Radiohead | rock | media | bajo | inglés | media/bajo |
| c011 | Numb | Linkin Park | rock | media | bajo | inglés | media/bajo |

#### Enojo (5)

| ID | Título | Artista | Género | Energía | Ánimo | Idioma | Perfil |
|---|---|---|---|---|---|---|---|
| c012 | Killing in the Name | Rage Against the Machine | rock | alta | bajo | inglés | alta/bajo |
| c013 | Break Stuff | Limp Bizkit | metal | alta | bajo | inglés | alta/bajo |
| c014 | Given Up | Linkin Park | rock | alta | bajo | inglés | alta/bajo |
| c015 | Riptide | Vance Joy | pop | media | alto | inglés | media/alto |
| c016 | Ho Hey | The Lumineers | folk | media | alto | inglés | media/alto |

#### Calma (5)

| ID | Título | Artista | Género | Energía | Ánimo | Idioma | Perfil |
|---|---|---|---|---|---|---|---|
| c017 | River Flows in You | Yiruma | clásica | baja | neutro | instrumental | baja/neutro |
| c018 | Ocean Eyes | Billie Eilish | pop | baja | neutro | inglés | baja/neutro |
| c019 | Intro | The xx | electrónica | media | neutro | instrumental | media/neutro |
| c020 | Budapest | George Ezra | folk | media | alto | inglés | media/alto |
| c021 | Count on Me | Bruno Mars | pop | media | alto | inglés | media/alto |

#### Motivación (5)

| ID | Título | Artista | Género | Energía | Ánimo | Idioma | Perfil |
|---|---|---|---|---|---|---|---|
| c022 | Eye of the Tiger | Survivor | rock | alta | alto | inglés | alta/alto |
| c023 | Stronger | Kanye West | hiphop | alta | alto | inglés | alta/alto |
| c024 | Titanium | David Guetta feat. Sia | electrónica | alta | alto | inglés | alta/alto |
| c025 | Awake | Tycho | electrónica | media | neutro | instrumental | media/neutro |
| c026 | Feather | Nujabes | hiphop | media | neutro | instrumental | media/neutro |

#### Alegría (5)

| ID | Título | Artista | Género | Energía | Ánimo | Idioma | Perfil |
|---|---|---|---|---|---|---|---|
| c004 | Happy | Pharrell Williams | pop | alta | alto | inglés | alta/alto |
| c027 | Uptown Funk | Mark Ronson feat. Bruno Mars | funk | alta | alto | inglés | alta/alto |
| c028 | Shake It Off | Taylor Swift | pop | alta | alto | inglés | alta/alto |
| c029 | Kerala | Bonobo | electrónica | media | neutro | instrumental | media/neutro |
| c030 | Vivir Mi Vida | Marc Anthony | salsa | alta | alto | español | alta/alto |

### 6.2 Cobertura de perfiles

| Perfil | Canciones | Reglas que lo usan |
|---|---|---|
| `perfil(baja, bajo)` | c001, c005, c006 | R31 |
| `perfil(media, alto)` | c002, c007, c015, c016, c020, c021 | R32, R37, R39 |
| `perfil(baja, neutro)` | c003, c008, c009, c017, c018 | R30, R33, R38 |
| `perfil(media, bajo)` | c010, c011 | R35 |
| `perfil(alta, bajo)` | c012, c013, c014 | R36 |
| `perfil(alta, alto)` | c004, c022, c023, c024, c027, c028, c030 | R34, R40 |
| `perfil(media, neutro)` | c019, c025, c026, c029 | R41, R42 |

**Ningún perfil usado por una regla queda sin canciones.**

---

## 7. Coherencia y validación

### 7.1 Comprobaciones realizadas

- 30 canciones y 30 IDs únicos.
- Todos los campos de canción completos y valores válidos (`baja/media/alta`, `bajo/neutro/alto`, idiomas permitidos).
- Los 30 enlaces empiezan con `https://www.youtube.com/results?search_query=`.
- 20 reglas y 20 IDs únicos.
- Las 20 reglas tienen `descripcion/2`; no hay descripciones huérfanas.
- Todas las condiciones usan variables y valores declarados en `variable/3` (o `emocion/1` en etapa 2).
- Todas las conclusiones son emociones del catálogo o perfiles con al menos una canción.
- No hay dos reglas con exactamente las mismas condiciones y conclusiones distintas.
- Las 12 combinaciones emoción × objetivo, una variante extra de calma con energía media (R07) y el caso `dormir` se probaron con el motor real: 14 consultas, todas con perfil y canciones.
- Las 20 reglas se dispararon al menos una vez en la simulación (cobertura completa de reglas).

### 7.2 Salida de la validación

```
Canciones: 30
Cobertura de perfiles (canciones):
  perfil(baja,bajo) -> 3
  perfil(media,alto) -> 6
  perfil(media,bajo) -> 2
  perfil(baja,neutro) -> 5
  perfil(alta,bajo) -> 3
  perfil(alta,alto) -> 7
  perfil(media,neutro) -> 4

Reglas: 20

Cobertura de emociones:
  alegria: etapa 1 + acompanar + cambiar
  tristeza: etapa 1 + acompanar + cambiar
  estres: etapa 1 + acompanar + cambiar
  enojo: etapa 1 + acompanar + cambiar
  calma: etapa 1 + acompanar + cambiar
  motivacion: etapa 1 + acompanar + cambiar

Simulacion de consultas (motor real): 14 OK
Reglas disparadas: [r01,r02,r03,r04,r05,r06,r07,r30,...,r42] (las 20)
RESULTADO: TODO OK
```

### 7.3 Pruebas existentes contra la propuesta

Se ejecutaron T01–T10 con el motor real:

- **T01–T05: PASS.**
- **T07–T10: PASS.**
- **T06: FAIL esperado.** Antes se esperaba `sin_perfil(alegria)` porque no existía regla para alegría + cambiar. Ahora R42 cubre esa combinación y devuelve `ok(alegria, perfil(media, neutro))` con reglas `[r03, r42]`.

**Acción necesaria:** actualizar T06 en `pruebas/pruebas.pl` (archivo de Ale) y agregar los casos nuevos de la sección 8.

### 7.4 Combinaciones no cubiertas (útiles para pruebas)

No toda combinación debe forzar una emoción. Quedan sin regla, por ejemplo:

- `animo=neutro, energia=media, tension=media` (el actual T07) → `sin_emocion`.
- `animo=neutro, energia=media, tension=alta` → `sin_emocion`.
- `animo=neutro, energia=alta, tension=baja` → `sin_emocion`.
- `animo=bajo, energia=media, tension=baja` → `sin_emocion`.
- `animo=alto, energia=media, tension=alta` → `sin_emocion`.

Esto es intencional: el sistema pide señales más claras antes de inferir una emoción. Si el equipo quiere cubrir más combinaciones, se pueden agregar reglas nuevas (por ejemplo, calma con energía alta y tensión baja), pero habría que actualizar la tabla, el árbol y las pruebas.

---

## 8. Impacto en `pruebas/pruebas.pl` y casos sugeridos

### 8.1 Cambio obligatorio

**T06** debe cambiar de:

```prolog
caso(t06, [animo-alto, energia-alta, tension-baja, contexto-fiesta, objetivo-cambiar],
     [r03], sin_perfil(alegria)).
```

a:

```prolog
caso(t06, [animo-alto, energia-alta, tension-baja, contexto-fiesta, objetivo-cambiar],
     [r03, r42], ok(alegria, perfil(media, neutro))).
```

### 8.2 Casos nuevos sugeridos (verificados con el motor)

| Caso | Entrada | Reglas esperadas | Resultado esperado |
|---|---|---|---|
| T11 | `[animo-bajo, energia-alta, tension-alta, contexto-estudiar, objetivo-acompanar]` | `[r04, r36]` | `ok(enojo, perfil(alta, bajo))` |
| T12 | `[animo-bajo, energia-alta, tension-alta, contexto-estudiar, objetivo-cambiar]` | `[r04, r37]` | `ok(enojo, perfil(media, alto))` |
| T13 | `[animo-neutro, energia-baja, tension-baja, contexto-relajarse, objetivo-acompanar]` | `[r05, r38]` | `ok(calma, perfil(baja, neutro))` |
| T14 | `[animo-neutro, energia-baja, tension-baja, contexto-relajarse, objetivo-cambiar]` | `[r05, r39]` | `ok(calma, perfil(media, alto))` |
| T15 | `[animo-alto, energia-alta, tension-media, contexto-ejercicio, objetivo-acompanar]` | `[r06, r40]` | `ok(motivacion, perfil(alta, alto))` |
| T16 | `[animo-alto, energia-alta, tension-media, contexto-ejercicio, objetivo-cambiar]` | `[r06, r41]` | `ok(motivacion, perfil(media, neutro))` |
| T17 | `[animo-neutro, energia-alta, tension-alta, contexto-estudiar, objetivo-acompanar]` | `[r02, r35]` | `ok(estres, perfil(media, bajo))` |
| T18 | `[animo-neutro, energia-media, tension-baja, contexto-relajarse, objetivo-acompanar]` | `[r07, r38]` | `ok(calma, perfil(baja, neutro))` |
| T19 | `[animo-neutro, energia-media, tension-alta, contexto-estudiar, objetivo-acompanar]` | `[]` | `sin_emocion` |

Con la actualización de T06 y los casos T11–T18, **las 20 reglas (R01–R07 y R30–R42) quedan cubiertas al menos una vez** por las pruebas; T19 es un caso extra de `sin_emocion`.

También conviene conservar/agregar:

- Un caso de **nueva consulta**: ejecutar T01 y luego T11 en la misma sesión (cada `correr_pruebas` limpia los hechos, pero la GUI debe permitir “Nueva consulta”).
- Un caso de **datos incompletos** y uno de **dato inválido** (T08–T10 ya los cubren).

---

## 9. Fuentes para “Adquisición del conocimiento” (APA 7)

Estas fuentes sostienen las decisiones de diseño; **verifiquen las citas antes de entregar** y citen solo las que realmente usen.

- Juslin, P. N., & Sloboda, J. A. (Eds.). (2010). *Handbook of music and emotion: Theory, research, applications*. Oxford University Press.
- Juslin, P. N., & Västfjäll, D. (2008). Emotional responses to music: The need to consider underlying mechanisms. *Behavioral and Brain Sciences, 31*(5), 559–575. https://doi.org/10.1017/S0140525X08005293
- Koelsch, S. (2014). Brain correlates of music-evoked emotions. *Nature Reviews Neuroscience, 15*(3), 170–180. https://doi.org/10.1038/nrn3666
- Russell, J. A. (1980). A circumplex model of affect. *Journal of Personality and Social Psychology, 39*(6), 1161–1178. https://doi.org/10.1037/h0077714
- Saarikallio, S., & Erkkilä, J. (2007). The role of music in adolescents' mood regulation. *Psychology of Music, 35*(1), 88–109. https://doi.org/10.1177/0305735607068889
- Thayer, R. E., Newman, J. R., & McClain, T. M. (1994). Self-regulation of mood: Strategies for changing a bad mood, raising energy, and reducing tension. *Journal of Personality and Social Psychology, 67*(5), 910–925. https://doi.org/10.1037/0022-3514.67.5.910
- Van den Tol, A. J. M., & Edwards, J. (2013). Exploring a rationale for choosing to listen to sad music when feeling sad. *Psychology of Music, 41*(4), 440–465. https://doi.org/10.1177/0305735611430433

### 9.1 Cómo se relacionan con el diseño

| Fuente | Uso en el proyecto |
|---|---|
| Russell (1980) | Modelo bidimensional del afecto: energía/activación y valencia/ánimo → ejes del `perfil`. |
| Thayer et al. (1994) | Relación entre tensión, energía y regulación del ánimo → variables `tension` y `energia`; contextos de ejercicio/relajación. |
| Juslin & Västfjäll (2008) | La emoción musical es multicausal → no basta una sola variable; se usan ánimo, energía, tensión y contexto. |
| Juslin & Sloboda (2010) | Marco general de música y emoción → catálogo de emociones y justificación del sistema. |
| Koelsch (2014) | La música modula sistemas cerebrales de emoción y recompensa → justifica recomendar música para acompañar o cambiar el estado. |
| Saarikallio & Erkkilä (2007) | Estrategias de regulación del ánimo con música → objetivo `acompanar` vs. `cambiar`. |
| Van den Tol & Edwards (2013) | Escuchar música triste cuando se está triste puede validar/acompañar la emoción → R31 (tristeza + acompañar). |

> **Nota honesta para el reporte:** las etiquetas de energía/ánimo de cada canción son una clasificación heurística del equipo, inspirada en el modelo bidimensional; no son una medición acústica ni una verdad objetiva. Conviene decirlo en “Adquisición del conocimiento” y en “Limitaciones”.

---

## 10. Cómo aplicar la propuesta (después de aprobarla)

1. Revisar `propuestas/reglas.pl` y `propuestas/canciones.pl`.
2. Reemplazar los originales:

   ```powershell
   Copy-Item propuestas\reglas.pl conocimiento\reglas.pl
   Copy-Item propuestas\canciones.pl conocimiento\canciones.pl
   ```

3. Actualizar `pruebas/pruebas.pl` (T06 + casos nuevos) en coordinación con Ale.
4. Ejecutar:

   ```powershell
   swipl src/main.pl
   ?- correr_pruebas.
   ```

5. Pasar la tabla de decisiones, el árbol y la lista R01..R42 al reporte.
6. Revisar las referencias APA y agregar las que realmente se citen.

---

## 11. Resumen de pendientes

- [ ] Aprobar la propuesta.
- [ ] Reemplazar `conocimiento/reglas.pl` y `conocimiento/canciones.pl`.
- [ ] Coordinar con Ale: T06 cambia y faltan T11–T19.
- [ ] Pasar tabla de decisiones, árbol y lista de reglas al reporte.
- [ ] Verificar fuentes APA y redactar “Adquisición del conocimiento”.
- [ ] Opcional: ampliar `media/bajo` (2 canciones) y probar enlaces en el navegador.
- [ ] Ejecutar `correr_pruebas` final sin FAIL (o con fallos documentados).
