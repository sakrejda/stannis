# Stannis

There is an official R interface to Stan (mc-stan.org) and this 
is *NOT* it.  Stannis uses `git` do download a CmdStan branch, 
stashes a build of it, and provides some wrappers on `system2` 
calls to let you use it directly from R.

## Where does CmdStan go?

Usually on Linux it goes under `~/.local/share/stannis/cmdstan`
and some config files go to `~/.config/stannis`.  If you can't
find it you can always run:

```
rappdirs::user_config_dir()
```

and 

```
rappdirs::user_data_dir()
```

## What's good about this package.

### Running pre-specified models

To run models you write a `.yaml` file like the one below.  Then
in R you can do `stannis::run_cmdstan(file = 'fits.yaml')` and 
all the models listed under `runs` will run, with output going 
to `target_dir`.  The `defaults` item is merged with each `runs`
item prior to running the model.  

```
defaults:
  project_id : "testy-test"
  method : 'sample'
  sample :
    num_chains : 3
    num_samples : 150
    num_warmup : 200
    save_warmup : 1
    thin : 1
    algorithm : "hmc"
    hmc :
      engine : "nuts"
      nuts :
        max_depth : 15
      static :
        int_time : 6.28
      metric : "diag_e"
      stepsize : 1
      stepsize_jitter : 0
  output :
    refresh : 1
  target_dir: "output"
  data_dir: "data"
  init_dir: "inits"
  model_dir: "models"
  binary_dir : "model-binaries"

runs:
  - model_name : "normal"
    method : 'sample'
    sample :
      num_warmup : 500
      num_samples : 300
  - model_name : "binomial"
    method : 'sample'
    sample :
      num_chains : 8
      num_warmup : 500
      num_samples : 300
    data :
      file : "coins.rdump"
```

The output goes into `target_dir` under a directory called `fit-...`
where `...` is a hash of the model file contents, the data, and the
initial values item along with the `project_id` field.  The field
`num_chains` is not a CmdStan parameter but each time the model 
runs it creates that many new chains and each one gets its own
subdirectory.  This particular behavior might change in the future
but for how I work this seems the best (run everything and pick up
the pieces afterwards).  

### Analyzing output

Stan output can be big.  CmdStan output can be even bigger as it's 
written out as text.  Stannis doesn't really solve that right now but
does let you read a set of data files (specified by a path and
pattern):

```
samples <- stannis::read_file_set(root='.', pattern = '.*-output.csv')
```

This gets you all the samples, all the metadata including the 
diagonal of the mass matrix if it's available.  You can do a few
basic manipulations.  Most importantly: 1) merge chains; 
2) trim warmup; and 3) turn the wide-format that comes from CmdStan
into a list of named parameters:

```
post_warmup <- stannis::trim_warmup(samples)
merged_samples <- stannis::merge_chains(post_warmup)
samples_in_arrays <- stannnis::array_set(merged_samples)
```

## Why write this package

Sometimes rstan is hard to install on a cluster, sometimes you don't
want a complicated output object, sometimes rstan is broken and you just
want to process your output.  Sometimes rstan barfs on the size of
your input and you can't use it.  This package will often work
mostly because CmdStan streams stuff in a reliable if clunky format
and has robust makefiles.  Yey basics.  






