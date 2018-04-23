#ifndef __SYSTEM_HPP__
#define __SYSTEM_HPP__


#include "spmv_conf_info.hpp"
#include "spmv_debug_info.hpp"
#include "spmv.hpp"
#include "spmv_directives.hpp"

#include "esp_templates.hpp"

#include "core/systems/esp_system.hpp"

#include "spmv_wrap.h"

#define REPORT_THRESHOLD 10
#define MAX_REL_ERROR 0.001
#define MAX_ABS_ERROR 0.05
#define IN_FILE "../tb/inputs/in.data"
#define CHK_FILE "../tb/outputs/chk.data"

const size_t MEM_SIZE = 50000000;

class system_t : public esp_system<DMA_WIDTH, MEM_SIZE>
{
public:

    // ACC instance
    spmv_wrapper *acc;

    // Constructor
    SC_HAS_PROCESS(system_t);
    system_t(sc_module_name name)
	: esp_system<DMA_WIDTH, MEM_SIZE>(name)
        {
	    // ACC
	    acc = new spmv_wrapper("spmv_wrapper");

	    // Binding ACC
	    acc->clk(clk);
	    acc->rst(acc_rst);
	    acc->dma_read_ctrl(dma_read_ctrl);
	    acc->dma_write_ctrl(dma_write_ctrl);
	    acc->dma_read_chnl(dma_read_chnl);
	    acc->dma_write_chnl(dma_write_chnl);
	    acc->conf_info(conf_info);
	    acc->conf_done(conf_done);
	    acc->acc_done(acc_done);
	    acc->debug(debug);
        }

    // Processes

    // Configure accelerator
    void config_proc();

    // Load internal memory
    void load_memory();

    // Dump internal memory
    void dump_memory();

    // Validate accelerator results
    int validate();

    // Other Functions
    bool check_error_threshold(float out, float gold);

    // Global variables

    // Accelerator-specific data
    uint32_t nrows;
    uint32_t ncols;
    uint32_t max_nonzero;
    uint32_t mtx_len;

    // Memory position
    uint32_t rows_addr;
    uint32_t cols_addr;
    uint32_t vals_addr;
    uint32_t vect_addr;
    uint32_t out_addr;
};

#endif // __SYSTEM_HPP__