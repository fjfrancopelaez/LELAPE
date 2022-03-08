# LELAPE

__LELAPE__ is the Spanish acronym for _Listas de Eventos Localizando Anomalías al Preparar Estadísticas_, which is equivalent in English to __LAELAPS__ (_Lists of All Events Locating Anomalies at Preparing Statistics_). In Greek mythology, LELAPE, or LAELAPS, is Zeus’ hound, with a magical skill to track and hunt any prey however hidden it may be. In a similar way, LELAPE is a software tool able to inspect sets of apparently random logical addresses of bitflips and discover those that are members of the same multiple event.

Semiconductor memories and FPGAs in space are exposed to natural radiation, which induces errors in the stored information. Although some catastrophic events can occur, the errors are often just bitflips. Sometimes, these bitflips occur in isolated cells, and several strategies have been adopted to mitigate their pernicious consequences. However, it is likely that errors occur in physically adjacent cells (multiple events). In modern devices, adjacency in physical location does not meen adjacency in logical addresses. Unfortunately, the information to relate both addresses is confidential, so researchers have serious problems to understand results from radiation tests.

However, recent researchs have discovered a link among some statistical paramaeters and presence of multiple events. LELAPE loads raw data from experiments and looks for evidence of mulitple events. Using this information, it classifies bitflips in sets of isolated bitflips, 2-bit events, 3-bit, etc. 

For deeper details, see DOC folder.

LELAPE is written in [Julia](https://julialang.org), a lenguage for scientific computation. With a grammar similar to Matlab-Octave, Python or R, it is one or two orders of magnitude more efficient, so even long calculations can be done on a modern laptop. 

This tool was supported by the ... 
