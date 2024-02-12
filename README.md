# LELAPE

__LELAPE__ is the Spanish acronym for _Listas de Eventos para Localizar Anomalías Preparando Estadísticas_, which is equivalent in English to __LAELAPS__ (_Lists of All Events for Locating Anomalies by Preparing Statistics_). In Greek mythology, LELAPE, or LAELAPS, is Zeus’ hound, with a magical skill to track and hunt any prey however hidden it may be. In a similar way, LELAPE is a software tool able to inspect sets of apparently random logical addresses of bitflips and discover those that are members of the same multiple event.

Semiconductor memories and FPGAs in space are exposed to natural radiation, which induces errors in the stored information. Although some catastrophic events can occur, the errors are often just bitflips. Sometimes, these bitflips appear in isolated cells, so several strategies have been adopted to mitigate their pernicious consequences. However, it is likely that errors occur in physically adjacent cells (multiple events). In modern devices, adjacency in physical location does not meen adjacency in logical addresses. Unfortunately, the information to relate both addresses is confidential, so researchers have serious problems to understand results from radiation tests.

However, recent researchs have discovered a link among some statistical parameters and presence of multiple events. LELAPE loads raw data from experiments and looks for evidence of multiple events. Using this information, it classifies bitflips in sets of isolated bitflips, 2-bit events, 3-bit, etc. 

For deeper details, see [doc](https://github.com/fjfrancopelaez/LELAPE/tree/main/LELAPE/doc) folder.

LELAPE is written in [Julia](https://julialang.org), a lenguage for scientific computation. With a grammar similar to Matlab-Octave, Python or R, it is one or two orders of magnitude more efficient, so even long calculations can be done on a modern laptop.  Some examples of analysis for Jupyter can be found on the [devoted folder](https://github.com/fjfrancopelaez/LELAPE/tree/main/LELAPE/Jupyter). There you can also find some scripts to be run in terminal or in Julia REPL, and that can be easily adapted to your needs just modifying the _Analysis.conf_ file.

## Acknowledgments
This tool was supported by the Spanish MINECO by means of the PID2020-112916GB-I00 project.
## How to reference
If you have successfully used this tool and the results are worth for academic publications, we ask you for including the following references:

* This site, or the ZENODO repository with DOI: [10.5281/zenodo.10156119](https://dx.doi.org/10.5281/zenodo.10156119)
* The Julia Language: _J. Bezanson, A. Edelman, S. Karpinski, and V. B. Shah, “Julia: A fresh
approach to numerical computing,” SIAM review, vol. 59, no. 1, pp. 65–98, 2017 (DOI: [10.1137/141000671](https://dx.doi.org/10.1137/141000671))._
* If you use the _SEFI_Detection_Poisson()_ function, include inside your reference list the paper by Perez-Celis _et al._ DOI: [10.1109/TNS.2021.3108572](https://dx.doi.org/10.1109/TNS.2021.3108572)

![LELAPE](LELAPE/doc/fig/LELAPE_LOGO_low.png)