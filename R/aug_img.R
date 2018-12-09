#' Apply augmentations to single image.
#'
#' @param img Image (object of class \code{"magick-image"}).
#' @param params Named list of tranformation parameters (order matters - see Details).
#' Each name should match one of \code{image_*} function:
#' \code{"crop"} for \code{image_crop}, \code{"flip"} for \code{image_flip} and so on.
#' List element contains constant values (image region size - \code{width}, \code{height};
#' probability of particular transformation -  \code{prob}) and/or ranges
#' for random parameters of particular transformation (\code{angle}, \code{x_off}).
#'
#'
#' @return Transformed image (cropped or padded if necessary to keep original size).
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
#' * crop (parameterized by \code{width} - width of cropped region,
#' \code{higth} - higth of cropped region, \code{x_off} - x offset,
#' \code{y_off} - y offset)
#'
#' * rotate (parameterized by \code{angle} - rotation angle)
#'
#' @import magick
#' @export
aug_img <- function(img,
                    params = list("flip" = list(prob = 0.5),
                                  "flop" = list(prob = 0.5),
                                  "crop" = list(width = 180, height = 180,
                                                x_off = c(0, 30), y_off = c(0, 30)),
                                  "rotate" = list(angle = c(-25, 25))
                                  )
                    ) {

    img_dim <- dim(img[[1]])
    img_width <- dim(img[[1]])[2]
    img_height <- dim(img[[1]])[3]

    funs_params <- generate_random_params(params)
    funs <- funs_params$funs
    params <- funs_params$params

    for (name in funs) {
        fun <- get(paste0("image_", name),
                   envir = asNamespace("magick"))
        img <- do.call(fun, c(list(image = img), params[[name]]))
    }

    #
    img <- image_repage(img)

    if (all(img_dim == dim(img[[1]]))) {
        return(img)
    }

    # White background if image is cropped compared to original size
    if (any(img_dim > dim(img[[1]]))) {
        img <- image_composite(
            image_read(array(255, dim = c(img_height, img_width, 3))),
            img,
            offset = geometry_point(
                floor((img_width - dim(img[[1]])[2]) / 2),
                floor((img_height - dim(img[[1]])[3]) / 2)
                )
            )
    }

    # Crop if image is bigger compared to original size
    if (any(img_dim < dim(img[[1]]))) {
        # crop if image became larger then original size
        img <- image_crop(img,
                          geometry = geometry_area(
                              width = img_width,
                              height = img_height,
                              x_off = floor((dim(img[[1]])[2] - img_width) / 2),
                              y_off = floor((dim(img[[1]])[3] - img_height) / 2)
                              )
                          )
    }
    img
}

# test_image <- image_read("test_images/20180622_205856.jpg")
# test_image <- image_scale(test_image, "224x224!")
# img <- test_image
# aug_img(test_image)
#     "noise" = list("gaussian")
