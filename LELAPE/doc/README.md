# How to build the TeX file
To build the TeX file, the following packages must be installed:

 * inputenc 
 * amstext 
 * amsfonts 
 * amsmath
 * fancyhdr 
 * fontspec 
 * geometry 
 * graphicx 
 * hyperref

This file non-standard fonts, so it is necessary a previous install ``Verdana`` and ``Courier New``. If you have not done so, fix it or just comment or modify the following lines in ``LELAPE_Handbook.tex``:

        \setmainfont[Mapping=tex-text]{Verdana}
        \setmonofont{Courier New}
If you use these or any other non-default fonts, you must run *XeLaTeX* instead of *PdfLaTeX*. This file does not seem to work with other LaTeX engines. *BibTeX* is also necessary to manage citations, but I guess that, if you dare to build the source file, you will have this additional tool on your computer.