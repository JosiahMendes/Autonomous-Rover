/*
 * mipi_bridge_config.h
 *
 *  Created on: 2015Äê4ÔÂ22ÈÕ
 *      Author: Administrator
 */

#ifndef MIPI_BRIDGE_CONFIG_H_
#define MIPI_BRIDGE_CONFIG_H_

#define MIPI_BRIDGE_I2C_ADDR   0x1C  // 8'b0001_1100 - 7'b0E + 1'b0 (write bit)


void MipiBridgeInit(void);

void MipiBridgeRegWrite(alt_u16 Addr, alt_u16 Value);
alt_u16 MipiBridgeRegRead(alt_u16 Addr);
#endif /* MIPI_BRIDGE_CONFIG_H_ */
