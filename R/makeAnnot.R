##' build annotation database
##' @name buildAnnot
##' @rdname buildAnnot-methods
##' @title make annotation database
##' @param species species for the annotation
##' @param keytype key type export
##' @param anntype annotation type
##' @param bulitin use default database(TRUE or FALSE)
##' @param OP BP,CC,MF default use all
##' @examples
##' \dontrun{
##' annot<-buildAnnot(species="human",keytype="ENTREZID",anntype="GO",bulitin=TRUE)
##' }
##' @export
##' @author Kai Guo
buildAnnot<-function(species="human",keytype="SYMBOL",anntype="GO",builtin=TRUE,OP=NULL){
  if(anntype=="GO"){
     annot <- .makeGOdata(species=species,keytype=keytype,OP=OP)
  }
  if(anntype=="KEGG"){
    annot <- .makeKOdata(species=species,keytype=keytype,builtin=builtin)
  }
  if(anntype=="Reactome"){
    annot <- .makeROdata(species=species,keytype=keytype)
  }
  result<-new("Annot",
              species = species,
              anntype = anntype,
              keytype = keytype,
              annot = annot

  )
}
#' make GO annotation data function
#' @importFrom AnnotationDbi keys
#' @importFrom AnnotationDbi select
#' @param species you can check the support species by using showData()
#' @param keytype the gene ID type
#' @param OP BP,CC,MF default use all
#' @importFrom dplyr distinct_
#' @author Kai Guo
.makeGOdata<-function(species="human",keytype="ENTREZID",OP=NULL){
  dbname<-.getdbname(species);
  if (!require(dbname,character.only=TRUE)){
    if(!require("BiocManager",character.only=TRUE)){
      install.packages("BiocManager")
    }else{
      BiocManager::install(dbname)
    }
  }else{
    suppressMessages(require(dbname,character.only = T,quietly = T))
  }
  dbname<-eval(parse(text=dbname))
  GO_FILE<-select(dbname,keys=keys(dbname,keytype=keytype),keytype=keytype,columns=c("GOALL","ONTOLOGYALL"))
  colnames(GO_FILE)[1]<-"GeneID"
  GO_FILE<-distinct_(GO_FILE,~GeneID, ~GOALL, ~ONTOLOGYALL)
  annot <- getann("GO")
  GO_FILE$Annot <- annot[GO_FILE[,2],"annotation"]
  if(!is.null(OP)){
    GO_FILE<-GO_FILE[GO_FILE$ONTOLOGYALL==OP,]
  }
  return(GO_FILE)
}
#' make KEGG annotation data function
#' @importFrom AnnotationDbi keys
#' @importFrom AnnotationDbi select
#' @importFrom KEGGREST keggLink
#' @param species you can check the support species by using showData()
#' @param keytype the gene ID type
#' @author Kai Guo
.makeKOdata<-function(species="human",keytype="ENTREZID",builtin=TRUE){
  dbname<-.getdbname(species=species);
  if(builtin==TRUE){
    # suppressMessages(require(AnnotationDbi))
    #  sel<-AnnotationDbi::select
    if (!require(dbname,character.only=TRUE)){
      if(!require("BiocManager",character.only=TRUE)){
        install.packages("BiocManager")
      }else{
        BiocManager::install(dbname)
      }
    }else{
      suppressMessages(require(dbname,character.only = T,quietly = T))
    }
    dbname<-eval(parse(text=dbname))
    KO_FILE=select(dbname,keys=keys(dbname,keytype=keytype),keytype=keytype,columns="PATH")
    KO_FILE<-na.omit(KO_FILE)
  }else{
    spe=.getspeices(species)
    tmp<-keggLink("pathway",spe)
    tmp<-substr(tmp,9,13)
    names(tmp)<-sub('.*:','',names(tmp))
    tmp<-vec_to_df(tmp,name=c(keytype,"PATH"))
    if(keytype!="ENTREZID"){
      tmp[,1]<-idconvert(species,keys=tmp[,1],fkeytype = "ENTREZID",tkeytype = keytype)
      tmp<-na.omit(tmp)
    }
    KO_FILE=tmp
  }
  annot<-getann("KEGG")
  KO_FILE[,1]<-as.vector(KO_FILE[,1])
  KO_FILE[,2]<-as.vector(KO_FILE[,2])
  KO_FILE$Annot<-annot[KO_FILE[,2],"annotation"]
  colnames(KO_FILE)[1]<-"GeneID"
  return(KO_FILE)
}

##' Download database from Msigdb and prepare for enrichment analysis
##' @name msigdbr
##' @importFrom msigdbr msigdbr
##' @importFrom dplyr filter_
##' @importFrom dplyr select_
##' @importFrom magrittr %>%
##' @param species the species for query
##' @param keytype the gene ID type
##' @param category Gene set category
##' @param anntype Gene Set anntype
##' @param save save the dataset or not
##' @param path path to save the dataset
##' @export
##' @author Kai Guo
buildMSIGDB<-function(species="human",keytype="SYMBOL",anntype="GO",
                     category=NULL){
  flag=0
  if(!is.null(anntype)){
    if(anntype=="CGP"){
      category<-"C2"
    }
    if(anntype=="CP"){
      category<-"C2"
    }
    if(anntype=="KEGG"){
      anntype<-"CP:KEGG"
      category<-"C2"
    }
    if(anntype=="REACTOME"){
      anntype<-"CP:REACTOME"
      category<-"C2"
    }
    if(anntype=="BIOCARTA"){
      anntype<-"CP:BIOCARTA"
      category<-"C2"
    }
    if(anntype=="MIR"){
      category<-"C3"
    }
    if(anntype=="TFT"){
      category<-"C3"
    }
    if(anntype=="CGN"){
      category=="C4"
    }
    if(anntype=="CM"){
      category<-"C4"
    }
    if(anntype=="BP"){
      category<-"C5"
    }
    if(anntype=="CC"){
      category<-"C5"
    }
    if(anntype=="MF"){
      category<-"C5"
    }
  }
  mspe<-.getmsig(species)
  if(is.null(mspe)){
    stop(cat("can't find support species!\n"))
  }
  if(keytype=="SYMBOL"){
    key="gene_symbol"
  }else if(keytype=="ENTREZID"){
    key="entrez_gene"
  }else{
    key="entrez_gene"
    flag=1
  }
  cat("Downloading msigdb datasets ...\n")
  res <- msigdbr(species=mspe)
  res <- res%>%filter_(~gs_cat==category)
  if(!is.null(anntype)){
    res <- res%>%filter_(~gs_subcat==anntype)
  }
  res<-res%>%select_(~key,~gs_name)
  if(flag==1){
    res[,1]<-idconvert(species,keys=res[,1],fkeytype="ENTREZID", tkeytype=keytype)
    res<-na.omit(res)
  }
  res<-as.data.frame(res)
  colnames(res)<-c("GeneID","Term")
  res$Term<-sub('.*@','',sub('_','@',res$Term))
  res$Annot<-res[,2]
  result<-new("Annot",
              species = species,
              anntype = anntype,
              keytype = keytype,
              annot = res)
  return(result)
}

#' make Reactome annotation data function
#' @importFrom AnnotationDbi as.list
#' @importFrom dplyr left_join
#' @param species you can check the supported species by using showAvailableRO
#' @param keytype key type export
#' @author Kai Guo
.makeROdata<-function(species="human",keytype="SYMBOL"){
  dbname<-.getrodbname(species=species);
  if (!require("reactome.db",character.only=TRUE)){
    if(!require("BiocManager",character.only=TRUE)){
      install.packages("BiocManager")
    }else{
      BiocManager::install("reactome.db")
    }
  }else{
    suppressMessages(require("reactome.db",character.only = T,quietly = T))
  }
  dbname=sapply(strsplit(dbname,"_"),'[[',1)
  lhs<-as.list(reactomePATHNAME2ID)
  lhs<-lhs[grep(dbname,names(lhs))]
  roid<-as.list(reactomePATHID2EXTID)[unique(as.vector(unlist(lhs)))]
  roid<-lapply(roid, function(x)unique(x))
  roid<-data.frame("GeneID"=unlist(roid),"Term"=rep(names(roid),times=lapply(roid, length)),row.names=NULL)
  ll<-lapply(lhs,function(x)unique(x))
  roan<-data.frame("Term"=unlist(ll),"Annot"=rep(names(ll),times=lapply(ll,length)),row.names=NULL)
  res<-left_join(roid,roan,by=c("Term"="Term"))
  if(keytype!="ENTREZID"){
    keys = idconvert(species = species,keys = res$GeneID,fkeytype = "ENTREZID",tkeytype = keytype)
    res$GeneID = keys
    res <- na.omit(res)
  }
  return(res)
}




