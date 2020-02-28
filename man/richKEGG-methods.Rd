% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AllGenerics.R
\name{richKEGG}
\alias{richKEGG}
\title{richKEGG method}
\usage{
richKEGG(
  x,
  kodata,
  pvalue = 0.05,
  padj = NULL,
  organism = NULL,
  ontology = "KEGG",
  keytype = NULL,
  minSize = 2,
  maxSize = 500,
  keepRich = TRUE,
  filename = NULL,
  padj.method = "BH",
  builtin = TRUE,
  ...
)
}
\arguments{
\item{x}{vector contains gene names}

\item{kodata}{Annotation object or dataframe}

\item{...}{additional parameters}
}
\value{
richResult
}
\description{
richKEGG
}
\author{
Kai Guo
}