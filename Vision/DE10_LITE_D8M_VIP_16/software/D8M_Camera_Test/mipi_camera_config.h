

#ifndef MIPI_CAMERA_CONFIG_H_
#define MIPI_CAMERA_CONFIG_H_

#define MIPI_I2C_ADDR   0x6C
#define MIPI_AF_I2C_ADDR 0x18

#define BYD_MODE_SELECT   0x0100
#define BYD_SOFTWARE_SET  0x0103
#define BYD_STREAMING     0x301A


#define BIN_LEVEL_MAX    3
#define BIN_LEVEL_MIN    1



void OV8865_FOCUS_Move_to(alt_u16 a_u2MovePosition);
void OV8865SetExposure(alt_u32 exposure);
alt_u32 OV8865ReadExposure();
void OV8865SetGain(alt_u16 gain);
void MIPI_BIN_LEVEL(alt_u8 level);
void BLC_LEVEL(alt_u8 blc0,alt_u8 blc1);

void MipiCameraInit(void);



#endif /* MIPI_CAMERA_CONFIG_H_ */
