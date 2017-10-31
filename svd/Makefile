SVD2ADA_DIR?=~/svd2ada
TARGET_DIR?=../bb-runtimes/arm/stm32/stm32f446/
SVD_DIR=$(TARGET_DIR)/svd
ER_TMP_DIR=$(SVD_DIR)/tmp

STM_DIR=../Ada_Drivers_Library/arch/ARM/STM32/svd/stm32f446x

all: svd er

er:
	@rm -rf $(SVD_DIR) $(ER_TMP_DIR)
	mkdir $(SVD_DIR)
	$(SVD2ADA_DIR)/svd2ada STM32F446x.svd -o $(ER_TMP_DIR) -p Interfaces.STM32
	@cp $(ER_TMP_DIR)/i-stm32.ads $(SVD_DIR)/
	@cp $(ER_TMP_DIR)/i-stm32-flash.ads $(SVD_DIR)/
	@cp $(ER_TMP_DIR)/i-stm32-gpio.ads $(SVD_DIR)/
	@cp $(ER_TMP_DIR)/i-stm32-pwr.ads $(SVD_DIR)/
	@cp $(ER_TMP_DIR)/i-stm32-rcc.ads $(SVD_DIR)/
	@cp $(ER_TMP_DIR)/i-stm32-syscfg.ads $(SVD_DIR)/
	@cp $(ER_TMP_DIR)/i-stm32-usart.ads $(SVD_DIR)/
	@cp $(ER_TMP_DIR)/a-intnam.ads $(SVD_DIR)/
	@cp $(ER_TMP_DIR)/handler.S $(SVD_DIR)/
	@rm -rf $(ER_TMP_DIR)
	@echo "copied embedded runtime files to"
	@echo "  "$(SVD_DIR)

svd:
	@rm -rf $(STM_DIR)
	$(SVD2ADA_DIR)/svd2ada $(SVD2ADA_DIR)/CMSIS-SVD/ST/STM32F446x.svd --boolean -o $(STM_DIR) -p STM32_SVD --base-types-package HAL --gen-uint-always
	@echo "generated target spec files to"
	@echo "  "$(STM_DIR)
