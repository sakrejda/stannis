% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cmdstan-arg-tree-helpers.R
\name{find_model}
\alias{find_model}
\title{Based on an argument tree ('args' object) find a model
and return the path. If the model file (.stan file) is not
found, check for the presence of a partial model file (.model file)
and splice it with components from args[['model_dir']]}
\usage{
find_model(args)
}
\arguments{
\item{args}{arg-tree object (list).}
}
\value{
path to object's model file.
}
\description{
Based on an argument tree ('args' object) find a model
and return the path. If the model file (.stan file) is not
found, check for the presence of a partial model file (.model file)
and splice it with components from args[['model_dir']]
}
