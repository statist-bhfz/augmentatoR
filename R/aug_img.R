#' Apply augmentations to single image.
#'
#' @param img Image (object of class \code{"magick-image"}).
#' @param out_width Output image width (in pixels).
#' @param out_height Output image height (in pixels).
#' @param params Named list of tranformation parameters (order matters - see Details).
#' Each name should match one of \code{image_*} function:
#' \code{"crop"} for \code{image_crop}, \code{"flip"} for \code{image_flip} and so on.
#' List element contains constant values (image region size - \code{width}, \code{height};
#' probability of particular transformation -  \code{prob}) and/or ranges
#' for random parameters of particular transformation (\code{angle}, \code{x_off}).
#'
#'
#' @return Transformed image (cropped or padded if necessary to
#' \code{(out_width, out_height)} size).
#' @examples
#' frink <- image_read("https://jeroen.github.io/images/frink.png")
#' aug_img(frink)
#' aug_img(frink,
#'         params = list("crop" = list(width = 180, height = 180,
#'                                     x_off = c(0, 30), y_off = c(0, 30))))
#' @details
#' Operations are applied to the image in order specified by \code{params} argument.
#' Please note that cropped and rotated image is not the same thing as
#' rotated and cropped one.
#' Currently implemented transformations:
#'
#' * flip (parameterized by \code{prob} - probability of vertical reflection)
#'
#' * flop (parameterized by \code{prob} - probability of horizontal reflection)
#'
#' * crop (parameterized by
#' \code{width} - width of cropped region,
#' \code{higth} - higth of cropped region, \code{x_off} - x offset (min, max),
#' \code{y_off} - y offset (min, max))
#'
#' * rotate (parameterized by \code{angle} - rotation angle (min, max))
#'
#' * modulate (parameterized by
#' \code{brightness} - brightness shift in  percentage of current value (min, max);
#' \code{saturation} - saturation shift in  percentage of current value (min, max);
#' \code{hue} - hue shift in  percentage of current value (min, max))
#'
#' @import magick
#' @export
aug_img <- function(img,
                    out_width = 224L,
                    out_height = 224L,
                    params = list("flip" = list(prob = 0.5),
                                  "flop" = list(prob = 0.5),
                                  "crop" = list(width = 180, height = 180,
                                                x_off = c(0, 30), y_off = c(0, 30)),
                                  "rotate" = list(angle = c(-25, 25)),
                                  "modulate" = list(brightness = c(90, 110),
                                                    saturation = c(95, 105),
                                                    hue = c(80, 120))
                                  )
                    ) {

    out_dim <- c(dim(img[[1]])[1], out_width, out_height)

    funs_params <- generate_random_params(params)
    funs <- funs_params$funs
    params <- funs_params$params

    for (name in funs) {
        fun <- get(paste0("image_", name),
                   envir = asNamespace("magick"))
        img <- do.call(fun, c(list(image = img), params[[name]]))
    }

    # Change canvas to actual size
    img <- image_repage(img)

    if (all(out_dim == dim(img[[1]]))) {
        return(img)
    }

    # White background if image is cropped compared to original size
    if (any(out_dim > dim(img[[1]]))) {
        img <- image_composite(
            image_read(array(255, dim = c(out_height, out_width, 3))),
            img,
            offset = geometry_point(
                floor((out_width - dim(img[[1]])[2]) / 2),
                floor((out_height - dim(img[[1]])[3]) / 2)
                )
            )
    }

    # Crop if image is bigger compared to original size
    if (any(out_dim < dim(img[[1]]))) {
        # crop if image became larger then original size
        img <- image_crop(img,
                          geometry = geometry_area(
                              width = out_width,
                              height = out_height,
                              x_off = floor((dim(img[[1]])[2] - out_width) / 2),
                              y_off = floor((dim(img[[1]])[3] - out_height) / 2)
                              )
                          )
    }
    img
}

# test_image <- image_read("test_images/20180622_205856.jpg")
# test_image <- image_scale(test_image, "224x224!")
# img <- test_image
# aug_img(test_image)

