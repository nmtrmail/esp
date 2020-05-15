#include <assert.h>
#include <stdio.h>

#include "pv_obfuscator.h"

int obfuscate(image_t *input, image_t *output,
        unsigned num_rows, unsigned num_cols,
        unsigned i_row_blur, unsigned i_col_blur,
        unsigned e_row_blur, unsigned e_col_blur,
        unsigned kernel_size)
{
    unsigned int x, y, iy, ix;

    assert(i_row_blur <= num_rows);
    assert(e_row_blur <= num_rows);
    assert(i_col_blur <= num_cols);
    assert(e_col_blur <= num_cols);
    assert(i_row_blur <= e_row_blur);
    assert(i_col_blur <= e_col_blur);

    // -- Sharpening

    for (x = 0; x < num_rows; ++x)
    {
        for (y = 0; y < num_cols; ++y)
        {
            unsigned int index1 = (x + 0) * num_cols + (y + 0);

            if (x >= 1 && x < num_rows - 1 && y >= 1 && y < num_cols - 1)
            {
               unsigned int index2 = (x - 1) * num_cols + (y + 0);
               unsigned int index3 = (x + 1) * num_cols + (y + 0);
               unsigned int index4 = (x + 0) * num_cols + (y - 1);
               unsigned int index5 = (x + 0) * num_cols + (y + 1);

                output[index1].val = 5 * input[index1].val -
                                     1 * input[index2].val -
                                     1 * input[index3].val -
                                     1 * input[index4].val -
                                     1 * input[index5].val;
            } else {

                output[index1].val = input[index1].val;
            }
        }
    }

    // -- Blurring

    for (x = i_row_blur; x < e_row_blur; x += kernel_size)
    {
        for (y = i_col_blur; y < e_col_blur; y += kernel_size)
        {
            // -- Find max

            float val = 0.0;

            for (ix = x; ix < x + kernel_size && ix < e_row_blur; ++ix)
            {
                for (iy = y; iy < y + kernel_size && iy < e_col_blur; ++iy)
                {
                    unsigned int index = ix * num_cols + iy;

                    if (output[index].val > val)
                        val = output[index].val;
                }
            }

            // -- Apply max

            for (ix = x; ix < x + kernel_size && ix < e_row_blur; ++ix)
            {
                for (iy = y; iy < y + kernel_size && iy < e_col_blur; ++iy)
                {
                    unsigned int index = ix * num_cols + iy;

                    output[index].val = val;
                }
            }
        }
    }

    return 0;
}
