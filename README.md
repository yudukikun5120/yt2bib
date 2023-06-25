# yt2bib

Cite YouTube videos in BibTeX format.

> **Note**
> You may need Biber/BibLaTeX for the `@movie` entry.
> See the [BibLaTeX documentation](https://mirror.kumi.systems/ctan/macros/latex/contrib/biblatex/doc/biblatex.pdf) for more information.

## Usage

```bash
$ ./yt2bib yt 'https://www.youtube.com/watch?v=9bZkp7q19f0'
@video{9bZkp7q19f0,
  author = {PSY},
  title = {PSY - GANGNAM STYLE(강남스타일) M/V},
  url = {https://www.youtube.com/watch?v=9bZkp7q19f0},
  date = {2019-01-01}
}
```

You can redirect the output to a file:

```bash
./yt2bib yt 'https://www.youtube.com/watch?v=9bZkp7q19f0' >> psy.bib
```

## Installation

```bash
chmod a+x ./yt2bib
```
