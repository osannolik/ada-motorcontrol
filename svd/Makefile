SVD2ADA_DIR?=~/svd2ada
ER_TMP_DIR?=$(PWD)/tmp_runtimes
ER_CRT0=$(PWD)/../embedded-runtimes/BSPs/cortex-m/stm32/motorcontrol/src/crt0
ER_GNARL=$(PWD)/../embedded-runtimes/BSPs/cortex-m/stm32/motorcontrol/src/gnarl
STM_DIR=$(PWD)/../Ada_Drivers_Library/arch/ARM/STM32/svd/stm32f446x

all: svd er

er:
	$(SVD2ADA_DIR)/svd2ada $(SVD2ADA_DIR)/CMSIS-SVD/ST/STM32F446x.svd -o $(ER_TMP_DIR) -p Interfaces.STM32
	@cp $(ER_TMP_DIR)/i-stm32.ads $(ER_CRT0)/
	@cp $(ER_TMP_DIR)/i-stm32-flash.ads $(ER_CRT0)/
	@cp $(ER_TMP_DIR)/i-stm32-gpio.ads $(ER_CRT0)/
	@cp $(ER_TMP_DIR)/i-stm32-pwr.ads $(ER_CRT0)/
	@cp $(ER_TMP_DIR)/i-stm32-rcc.ads $(ER_CRT0)/
	@cp $(ER_TMP_DIR)/i-stm32-syscfg.ads $(ER_CRT0)/
	@cp $(ER_TMP_DIR)/i-stm32-usart.ads $(ER_CRT0)/
	@cp $(ER_TMP_DIR)/a-intnam.ads $(ER_GNARL)/
	@cp $(ER_TMP_DIR)/handler.S $(ER_GNARL)/
	@rm -rf $(ER_TMP_DIR)
	@echo "copied embedded runtime files to"
	@echo "  "$(ER_CRT0)
	@echo "  "$(ER_GNARL)

svd:
	@rm -rf $(STM_DIR)
	$(SVD2ADA_DIR)/svd2ada $(SVD2ADA_DIR)/CMSIS-SVD/ST/STM32F446x.svd --boolean -o $(STM_DIR) -p STM32_SVD --base-types-package HAL --gen-uint-always
	@echo "generated target spec files to"
	@echo "  "$(STM_DIR)
