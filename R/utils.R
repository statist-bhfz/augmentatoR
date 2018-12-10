#' Generate random parameters for transformation.
#'
#' @param params A number.
#' @return Named list of tranformation parameters.
#' @import magick
generate_random_params <- function(params) {

    funs <- names(params)

    if ("flip" %in% funs &&
        rnorm(1) > qnorm(params$flip$prob)) {
        funs <- funs[! funs %in% "flip"]
    } else {
        params$flip <- NULL
    }

    if ("flop" %in% funs &&
        rnorm(1) > qnorm(params$flop$prob)) {
        funs <- funs[! funs %in% "flop"]
    } else {
        params$flop <- NULL
    }

    if ("crop" %in% funs) {
        x_off <- round(runif(1, params$crop$x_off[1], params$crop$x_off[2]))
        y_off <- round(runif(1, params$crop$y_off[1], params$crop$y_off[2]))
        params$crop <- geometry_area(
            params$crop$width, params$crop$height, x_off, y_off
        )
    }

    if ("rotate" %in% funs) {
        params$rotate <- round(runif(1, params$rotate$angle[1],
                                     params$rotate$angle[2]))
    }

    if ("modulate" %in% funs) {
        params$modulate <- list(
            "brightness" = runif(1, params$modulate$brightness[1],
                                 params$modulate$brightness[2]),
            "saturation" = runif(1, params$modulate$saturation[1],
                                 params$modulate$saturation[2]),
            "hue" = runif(1, params$modulate$hue[1],
                          params$modulate$hue[2])
        )
    }

    return(list(funs = funs, params = params))
}
