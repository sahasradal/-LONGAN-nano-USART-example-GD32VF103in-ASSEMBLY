# LONGAN-nano-USART-example-GD32VF103 in ASSEMBLY
ASSEMBLER example (hobbyist)implementation of USART transmit and receive . used simple lightweight BRONZEBEARD assembler installed in python virtual environment on windows10.
light weight assembler BRONZEBEARD is used to assemble the code which is available on GITHUB -- https://github.com/theandrew168/bronzebeard
how to use the assembler is briefly discribed in 
The assembler outputs a .HEX file which can be burned with dedicated programming tool available on GIGA DEVICES website https://gd32mcu.com/en/download/0?kw=GD32VF1
The code can be used on GCC  with slight modification of header files
the output was tested on realterm terminal in windows10
PA3 is RX and PA2 is TX on the longan nano board. A cheap USB to UART dongle is used to connect the longan to the PC , baud 115200 is hard coded. The baud calculation is available in the comments inside the code files. Other values may be programmed by changing the entries in the calculation. The USART_ver1 attached repeatedly transmits"My first assembly code!"message to the terminal with 1 second delay
USART_ver2 code transmits a message "Type something and hit enter button"message to the terminal then waits for the user to key in 10 bytes. Once 10 bytes are typed in they are transmitted back to the terminal to be displayed to show that reception was success.

115200 baud calculation to get values that is to be entered in baud register , my chip runs at 8Mhz = 8000000hz and peripheral clock = sys clock
# 8000000/(16 x 115200)=   8000000/1843200 = 4.340  (pclk/16xbaud)
# mantissa = 4
# fraction = 0.340
# 0.340 x 16 = 5.44 rounded to 6
#fraction entered in positions 0 to 3 bits
# mantissa entered from 4 upwards in baud register
