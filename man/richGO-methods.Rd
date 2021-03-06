% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AllGenerics.R
\name{richGO}
\alias{richGO}
\title{richGO method}
\usage{
richGO(
  x,
  godata,
  ontology = "BP",
  pvalue = 0.05,
  padj = NULL,
  minSize = 2,
  maxSize = 500,
  keepRich = TRUE,
  filename = NULL,
  padj.method = "BH",
  sep = ",",
  ...
)
}
\arguments{
\item{x}{vector contains gene names}

\item{godata}{Annotation object or dataframe}

\item{...}{additional parameters}
}
\value{
richResult
}
\description{
richGO
}
\examples{
\dontrun{
  hsago<-buildAnnot(species="human",keytype="SYMBOL",anntype = "GO")
  hsago<-as.data.frame(hsago)
  gene=sample(unique(hsago$GeneID),1000)
  res<-richGO(gene,godata = hsago,ontology ="BP")
}
}
\author{
Kai Guo
}
