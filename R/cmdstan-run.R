
#' Run a CmdStan model based on a single arg-tree.
#' 
#' @param configuration stas:::sample() or simlar
#' @param stdout file to pipe standard output to
#' @param stderr file to pipe standard error output to
#' @param wait whether to wait for the CmdStan process to exit
#' @return NULL, run as a system command.
#' @export
run_model_cmd <- function(
  configuration = stas:::sample(), 
  stdout = NULL,
  stderr = NULL,
  wait = TRUE
) {
  cmd_binary = normalizePath(stringify_binary(configuration))
  cmd_args = stringify_arguments(configuration)
  if (is.null(stdout))
    stdout = ""
  if (is.null(stderr))
    stderr = ""
  system2(command=cmd_binary, args=cmd_args, stdout=stdout, stderr=stderr, wait=wait)
  return(args)
}




