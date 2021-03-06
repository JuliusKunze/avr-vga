.INCLUDE "tn2313def.inc"

Main:
  .equ B = 0
  .equ G = 1
  .equ R = 2
  .equ H = 3
  .equ V = 4
  .equ RAMSTART = 0x60
  .equ RAMSTOP = RAMSTART + 128
  .def porch = r0
  .def count = r17
  .def temp = r18
  .def dataline = r19
  .def linealt = r20
  .def hsync = r21
  .def vsync = r22
  .def xsync = r23
  .def line = r24
  .def linerepeat = r25
  clr porch
  ldi hsync, 1 << H
  ldi vsync, 1 << V
  ldi xsync, (1 << H) | (1 << V)
  ldi temp, 0xFF
  out DDRB, temp
  out PORTD, temp

  clr xh
  ldi xl, RAMSTART
  ldi zl, LOW(Data * 2)
  ldi zh, HIGH(Data * 2)
  ldi count, 128
DataLoaderLoop:
  lpm temp, z+
  st x+, temp
  dec count
  brne DataLoaderLoop

Frame:
  ldi xl, RAMSTART    ; 1
  ldi linerepeat, 36  ; 1
  ldi dataline, 16    ; 1

  ldi line, 13        ; 1
FrontPorchLine:       ;         0
  out PORTB, porch    ; 1
  nop                 ; 1
  nop                 ; 1

  ldi count, 69       ; 1
FPLoop:
  dec count           ; 1*
  brne FPLoop         ; 2* -1   +210=210

  out PORTB, hsync    ; 1
  ldi count, 10       ; 1
  nop                 ; 1
FPHSyncLoop:
  dec count           ; 1*
  brne FPHsyncLoop    ; 2* -1   +32=242

  out PORTB, porch    ; 1
  ldi count, 5        ; 1
  nop
  nop                 ; 2
FPBackLoop:
  dec count           ; 1*
  brne FPBackLoop     ; 2* -1

  ldi linealt, 4      ; 1 do here to already to avoid offset
  dec line            ; 1
  brne FrontPorchLine ; 2 (-1)  +22=264

VSyncLine:            ;         0
  out PORTB, vsync    ; 1
  nop                 ; 1
  nop                 ; 1

  ldi count, 69       ; 1
VsyncLoop:
  dec count           ; 1*
  brne VsyncLoop      ; 2* -1   +210=210

  out PORTB, xsync    ; 1
  ldi count, 10       ; 1
  nop                 ; 1
XsyncLoop:
  dec count           ; 1*
  brne XsyncLoop      ; 2* -1   +32=242

  out PORTB, vsync    ; 1
  ldi count, 5        ; 1
  nop
  nop
  nop                 ; 3
VSyncBackLoop:
  dec count           ; 1*
  brne VSyncBackLoop  ; 2* -1

  ldi line, 13        ; 1 do here already to avoid offset
  dec linealt         ; 1
  brne VsyncLine      ; 2 (-1)  +22=264


BackPorchLine:        ;         0
  out PORTB, porch    ; 1
  nop                 ; 1
  nop                 ; 1

  ldi count, 69       ; 1
BPLoop:
  dec count           ; 1*
  brne BPLoop         ; 2* -1   +210=210

  out PORTB, hsync    ; 1
  ldi count, 10       ; 1
  nop                 ; 1
BPHSyncLoop:
  dec count           ; 1*
  brne BPHSyncLoop    ; 2* -1   +32=242

  out PORTB, porch    ; 1
  ldi count, 6        ; 1
BPBackLoop:
  dec count           ; 1*
  brne BPBackLoop     ; 2* -1

  dec line            ; 1
  brne BackPorchLine  ; 2 (-1)  +22=264
  nop                 ; 1


Line:                 ;         0

  out PORTB, porch    ; 1
  ldi count, 7        ; 1
LeftBorderLoop:
  dec count           ; 1*
  brne LeftBorderLoop ; 2* -1
  nop                 ; 1

  ldi count, 8        ; 1
DataLoop:
  ld temp, x          ; 2*
  swap temp           ; 1*
  andi temp, 7        ; 1*      +28=28
  out PORTB, temp     ; 1*
  ld temp, x+         ; 2*
  andi temp, 7        ; 1*
  nop
  nop
  nop
  nop
  nop                 ; 5*
  out PORTB, temp     ; 1*
  dec count           ; 1*
  nop                 ; 1*
  brne DataLoop       ; 2* -1
  nop
  nop
  nop
  nop
  nop
  nop                 ; 6       +144=172

  out PORTB, porch    ; 1
  ldi count, 9        ; 1
RightBorderLoop:
  dec count           ; 1*
  brne RightBorderLoop; 2* -1   +28=200

  out PORTB, porch    ; 1
  ldi count, 3        ; 1
FrontPorchLoop:
  dec count           ; 1*
  brne FrontPorchLoop ; 2* -1   +10=210

  out PORTB, hsync    ; 1
  ldi count, 10       ; 1
  nop                 ; 1
HSyncLoop:
  dec count           ; 1*
  brne HsyncLoop      ; 2* -1   +32=242

  out PORTB, porch    ; 1
  ldi count, 3        ; 1
BackPorchLoop:
  dec count           ; 1*
  brne BackPorchLoop  ; 2* -1

  subi x, 8           ; 1
  dec linerepeat      ; 1
  brne RepeatedLine   ; 2 (-1)

  subi x, -8          ; 1 # add
  ldi linerepeat, 36  ; 1
  dec dataline        ; 1
  brne DataLine       ; 2 (-1)

  rjmp Frame          ; 2      (+22-4=264-4)

RepeatedLine:
  nop
  nop
  nop
  nop
  nop
  nop                 ; 6
  rjmp Line           ; 2      +22=264

DataLine:
  nop
  nop                 ; 2
  rjmp Line           ; 2      (+22=264)

Data:
  .DB 0x70, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07
  .DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
  .DB 0x00, 0x77, 0x77, 0x77, 0x77, 0x77, 0x77, 0x70
  .DB 0x00, 0x70, 0x00, 0x00, 0x00, 0x00, 0x00, 0x70
  .DB 0x00, 0x70, 0x00, 0x00, 0x00, 0x00, 0x00, 0x70
  .DB 0x00, 0x70, 0x00, 0x44, 0x04, 0x40, 0x00, 0x70
  .DB 0x00, 0x70, 0x04, 0x64, 0x44, 0x44, 0x00, 0x70
  .DB 0x00, 0x70, 0x04, 0x44, 0x44, 0x44, 0x00, 0x70
  .DB 0x00, 0x70, 0x04, 0x44, 0x44, 0x44, 0x00, 0x70
  .DB 0x00, 0x70, 0x00, 0x44, 0x44, 0x40, 0x00, 0x70
  .DB 0x00, 0x70, 0x00, 0x04, 0x44, 0x00, 0x00, 0x70
  .DB 0x00, 0x70, 0x00, 0x00, 0x40, 0x00, 0x00, 0x70
  .DB 0x00, 0x70, 0x00, 0x00, 0x00, 0x00, 0x00, 0x70
  .DB 0x00, 0x70, 0x00, 0x00, 0x00, 0x00, 0x00, 0x70
  .DB 0x00, 0x77, 0x77, 0x77, 0x77, 0x77, 0x77, 0x70
  .DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
