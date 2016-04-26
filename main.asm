; vim: set et ts=8 sw=8 sts=8 syntax=64tass :

; D.Y.S.P. using pre-calculated cycle table
;
; 2016-04-01

        music_sid = "Blitter.sid"
        music_init = $1000
        music_play = $1003

        DYSP_HEIGHT = 128

        zp = $10

        * = $0801
        .word (+), 2016
        .null $9e, ^start
+       .word 0

start
        jsr $fda3
        jsr $fd15
        jsr $ff5b
        sei
        clc
        ldx #0
-       txa
        adc #1
        sta $d027,x
        inx
        cpx #8
        bne -
        ldx #$3f
        lda #$ff
-       sta $0340,x
        dex
        bpl -
        lda #($340 / 64)
        ldx #7
-       sta $07f8,x
        dex
        bpl -
        ldx #0
-       lda iface_text,x
        sta $0400,x
        lda #$0b
        sta $d800,x
        inx
        bne -
-       lda iface_text + 256,x
        sta $0500,x
        lda #$0b
        sta $d900,x
        inx
        cpx #$40
        bne -
        lda #0
        jsr music_init
        lda #$35
        sta $01
        lda #$7f
        sta $dc0d
        sta $dd0d
        ldx #0
        stx $dc0e
        stx $dd0e
        stx $3fff
        lda #$01
        sta $d01a
        lda #$1b
        sta $d011
        lda #$29
        ldx #<irq1
        ldy #>irq1
        sta $d012
        stx $fffe
        sty $ffff
        ldx #<break
        ldy #>break
        stx $fffa
        sty $fffb
        stx $fffc
        sty $fffd
        bit $dc0d
        bit $dd0d
        inc $d019
        cli
        jmp *


        ; avoid timing critical loops to cross page boundaries
        .align 256
irq1
        pha
        txa
        pha
        tya
        pha
        lda #$2a
        ldx #<irq2
        ldy #>irq2
        sta $d012
        stx $fffe
        sty $ffff
        lda #1
        inc $d019
        tsx
        cli
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
irq2
        txs
        ldx #8
-       dex
        bne -
        bit $ea
        lda $d012
        cmp $d012
        beq +
+
        ldx #$10
-       lda sprite_positions,x
        sta $d000,x
        dex
        bpl -
        lda #$ff
        sta $d015
        ldx #$14
-       dex
        bne -
        nop
        jsr dysp
        lda #0
        sta $d021
        sta $d015
        dec $d020
        jsr joystick2
        jsr update_iface
        dec $d020
        jsr param_highlight
        dec $d020
        jsr music_play
        lda #0
        sta $d020
        lda #$f9
        ldx #<irq3
        ldy #>irq3
        sta $d012
        stx $fffe
        sty $ffff
        lda #1
        sta $d019
        pla
        tay
        pla
        tax
        pla
break   rti

irq3
        pha
        txa
        pha
        tya
        pha
        ldx #7
-       dex
        bne -
        stx $d011
        ldx #30
-       dex
        bne -
        lda #$1b
        sta $d011
        dec $d020
        jsr dysp_x_sinus
        jsr dysp_y_sinus
        dec $d020
        jsr dysp_clear_timing_fast
        dec $d020
        jsr dysp_calc_timing_fast
        lda #0
        sta $d020
        lda #$29
        ldx #<irq1
        ldy #>irq1
        sta $d012
        stx $fffe
        sty $ffff
        lda #1
        sta $d019
        pla
        tay
        pla
        tax
        pla
        rti

dysp_x_idx1     .byte 0
dysp_x_idx2     .byte 0

dysp_y_idx1     .byte 0
dysp_y_idx2     .byte 0


params

dysp_x_adc1     .byte 12
dysp_x_adc2     .byte 9
dysp_x_spd1     .byte 2
dysp_x_spd2     .byte 3

dysp_y_adc1     .byte $0f
dysp_y_adc2     .byte $f6
dysp_y_spd1     .byte $fe
dysp_y_spd2     .byte $3

param_colram
        .word $d807, $d811, $d81c, $d826
        .word $d82f, $d839, $d844, $d84e

param_index     .byte 0

param_highlight
        ; clear param highlighting
        ldx #0
-       lda param_colram,x
        sta zp
        lda param_colram + 1,x
        sta zp + 1
        ldy #0
        lda #$0f
        sta (zp),y
        iny
        sta (zp),y
        inx
        inx
        cpx #16
        bne -
        ; highlight current param
        lda param_index
        asl
        tax
        lda param_colram,x
        sta zp
        lda param_colram + 1,x
        sta zp + 1
        ldy #0
        lda #$01
        sta (zp),y
        iny
        sta (zp),y

        rts

JOY_UP = $01
JOY_DOWN = $02
JOY_LEFT = $04
JOY_RIGHT = $08
JOY_FIRE = $10

joystick2
        lda #8
        beq +
        dec joystick2 + 1
        rts
+       lda $dc00
        sta zp
        and #%00011111
        eor #%00011111
        bne +
        rts
+       lda #8
        sta joystick2 + 1
        lda zp
        and #JOY_UP
        beq joy2_up
        lda zp
        and #JOY_DOWN
        beq joy2_down
        lda zp
        and #JOY_LEFT
        beq joy2_left
        lda zp
        and #JOY_RIGHT
        beq joy2_right
        lda zp
        and #JOY_FIRE
        beq joy2_fire
        rts
joy2_up
        ldx param_index
        inc params,x
        rts
joy2_down
        ldx param_index
        dec params,x
        rts
joy2_left
        lda param_index
        sec
        sbc #1
        and #7
        sta param_index
        rts
joy2_right
        lda param_index
        clc
        adc #1
        and #7
        sta param_index
        rts
joy2_fire
        ldx param_index
        lda #0
        sta params,x
        rts




dysp_y_sinus
        ldx dysp_y_idx1
        ldy dysp_y_idx2
.for index = 0, index < 8, index = index + 1
        lda ysinus,x
        clc
        adc ysinus,y
        adc #$32
        sta sprite_positions + 1 + (index * 2)
        txa
        clc
        adc dysp_y_adc1
        tax
        tya
        clc
        adc dysp_y_adc2
        tay
.next
        lda dysp_y_idx1
        clc
        adc dysp_y_spd1
        sta dysp_y_idx1
        lda dysp_y_idx2
        clc
        adc dysp_y_spd2
        sta dysp_y_idx2
        rts



xmsb_tmp .byte 0

dysp_x_sinus
        lda #0
        sta xmsb_tmp

        ldx dysp_x_idx1
        ldy dysp_x_idx2


.for index = 0, index < 8, index = index + 1
        lda xsinus_256,x
        clc
        adc xsinus_96,y
        sta sprite_positions + (index * 2)
        bcc +
        lda xmsb_tmp
        ora #(1 << index)
        sta xmsb_tmp
+
        txa
        clc
        adc dysp_x_adc1
        tax
        tya
        clc
        adc dysp_x_adc2
        tay
.next
        lda xmsb_tmp
        sta sprite_positions + 16
        
        lda dysp_x_idx1
        clc
        adc dysp_x_spd1
        sta dysp_x_idx1
        lda dysp_x_idx2
        clc
        adc dysp_x_spd2
        sta dysp_x_idx2
        rts

iface_text
        .enc screen
        ;      0123456789abcdef0123456789abcdef01234567
        .text "xadc1: 00 xadc2: 00  xspd1: 00 xspd2: 00"
        .text "yadc1: 00 yadc2: 00  yspd1: 00 yspd2: 00"
        .text "                                        "
        .text "joystick in port 2:                     "
        .text "                                        "
        .text "  left/right  - select parameter        "
        .text "  up/down     - adjust parameter        "
        .text "  fire button - set parameter to 0      "
iface_text_end

hex_digits
        pha
        and #$0f
        cmp #$0a
        bcs +
        adc #$3a
+       sbc #$09
        tax
        pla
        lsr
        lsr
        lsr
        lsr
        cmp #$0a
        bcs +
        adc #$3a
+       sbc #$09
        rts

update_iface
        lda dysp_x_adc1
        jsr hex_digits
        sta $0407
        stx $0408
        lda dysp_x_adc2
        jsr hex_digits
        sta $0411
        stx $0412
        lda dysp_x_spd1
        jsr hex_digits
        sta $041c
        stx $041d
        lda dysp_x_spd2
        jsr hex_digits
        sta $0426
        stx $0427

        lda dysp_y_adc1
        jsr hex_digits
        sta $042f
        stx $0430
        lda dysp_y_adc2
        jsr hex_digits
        sta $0439
        stx $043a
        lda dysp_y_spd1
        jsr hex_digits
        sta $0444
        stx $0445
        lda dysp_y_spd2
        jsr hex_digits
        sta $044e
        stx $044f
        rts




dysp_sprite_enable
        .fill DYSP_HEIGHT, 0


        .align 256      ; avoid page boundary crossing in raster bars
dysp
        ldy #8
        ldx #0
-       lda d021_table,x
        dec $d016
        sta $d021
        sty $d016
        lda d011_table,x
        sta $d011

        lda timing,x
        sta _delay + 1
_delay  bpl * + 2
        cpx #$e0
        cpx #$e0
        cpx #$e0
        cpx #$e0
        cpx #$e0
        cpx #$e0
        cpx #$e0
        cpx #$e0
        bit $ea
        inx
        cpx #DYSP_HEIGHT
        bne -
        rts

sprite_positions
        .byte $00, $a0
        .byte $18, $a0

        .byte $30, $a0
        .byte $48, $a0

        .byte $60, $a0
        .byte $78, $a0

        .byte $90, $a0
        .byte $a8, $a0
        .byte $00

.cerror * > $0fff, "code section too large!"

        * = $2000
ysinus
        .byte ((DYSP_HEIGHT - 24) / 4)  + 0.5 + ((DYSP_HEIGHT - 24) / 4) * sin(range(256) * rad(360.0/256))

xsinus_256
        .byte 127.5 + 128 * sin(range(256) * rad(360.0/256))
xsinus_96
        .byte 47.5 + 48 * sin(range(256) * rad(360.0/256))



        .align 256
d011_table
.for row = 0, row < DYSP_HEIGHT, row = row + 1
        .byte $18 + ((row + 3) & 7)
.next

        .align 256
d021_table
        .byte $06, $00, $06, $04, $00, $06, $04, $0e
        .byte $00, $06, $04, $0e, $0f, $00, $06, $04
        .byte $0e, $0f, $07, $00 ,$06, $04, $0e, $0f
        .byte $07, $01, $07, $0f, $0e, $04, $06, $00
        .byte $07, $0f, $0e, $04, $06, $00, $0f, $0e
        .byte $04, $06, $00, $0e, $04, $06, $00, $04
        .byte $06, $00, $06, $00, $09, $08, $0a, $0f
        .byte $07, $01, $07, $0f, $0a, $08, $09, $00
        .byte $06, $00, $06, $04, $00, $06, $04, $0e
        .byte $00, $06, $04, $0e, $0f, $00, $06, $04
        .byte $0e, $0f, $07, $00 ,$06, $04, $0e, $0f
        .byte $07, $01, $07, $0f, $0e, $04, $06, $00
        .byte $07, $0f, $0e, $04, $06, $00, $0f, $0e
        .byte $04, $06, $00, $0e, $04, $06, $00, $04
        .byte $06, $00, $06, $00, $09, $08, $0a, $0f
        .byte $07, $01, $07, $0f, $0a, $08, $09, $00



        .align 256
; cycle delay table
timing
        .fill 2, 0      ; don't touch this, raster code starts early
        .fill DYSP_HEIGHT - 2, 0




        .align 256
; number of cycles to skip in the branch
cycles
;       skip cycles     $d015                   sprite(s) active

        ; $00-$07
        .byte 0         ; $00 - %00000000       no sprites
        .byte 3         ; $01 - %00000001                     0
        .byte 5         ; $02 - %00000010                   1
        .byte 5         ; $03 - %00000011                   1 0

        ; $04-$07
        .byte 5         ; $04 - %00000100                 2
        .byte 7         ; $05 - %00000101                 2   0
        .byte 7         ; $06 - %00000110                 2 1
        .byte 7         ; $07 - %00000111                 2 1 0

        ; $08-$0b
        .byte 5         ; $08 - %00001000               3
        .byte 8         ; $09 - %00001001               3     0
        .byte 9         ; $0a - %00001010               3   1
        .byte 9         ; $0b - %00001011               3   1 0

        ; $0c-$0f
        .byte 7         ; $0c - %00001100               3 2
        .byte 9         ; $0d - %00001101               3 2   0
        .byte 9         ; $0e - %00001110               3 2 1 
        .byte 9         ; $0f - %00001111               3 2 1 0

        ; $10-$13
        .byte 5         ; $10 - %00010000             4
        .byte 7         ; $11 - %00010001             4       0
        .byte 10        ; $12 - %00010010             4     1
        .byte 10        ; $13 - %00010011             4     1 0

        ; $14-$17
        .byte 9         ; $14 - %00010100             4   2
        .byte 11        ; $15 - %00010101             4   2   0
        .byte 11        ; $16 - %00010110             4   2 1
        .byte 11        ; $17 - %00010111             4   2 1 0

        ; $18-$1b
        .byte 7         ; $18 - %00011000             4 3
        .byte 10        ; $19 - %00011001             4 3     0
        .byte 11        ; $1a - %00011010             4 3   1
        .byte 11        ; $1b - %00011011             4 3   1 0

        ; $1c-$1f
        .byte 9         ; $1c - %00011100             4 3 2
        .byte 11        ; $1d - %00011101             4 3 2   0
        .byte 11        ; $1e - %00011110             4 3 2 1
        .byte 11        ; $1f - %00011111             4 3 2 1 0

        ; $20-$2f
        .byte $05, $08, $09, $09
        .byte $09, $0c, $0c, $0c
        .byte $09, $0c, $0d, $0d
        .byte $0b, $0d, $0d, $0d

        ; $30-$3f
        .byte $07, $09, $0c, $0c
        .byte $0b, $0d, $0d, $0d
        .byte $09, $0c, $0d, $0d
        .byte $0b, $0d, $0d, $0d

        ; $40-$4f
        .byte $05, $07, $0a, $0a
        .byte $0a, $0b, $0b, $0b
        .byte $0a, $0d, $0e, $0e
        .byte $0b, $0e, $0e, $0e

        ; $50-$5f
        .byte $09, $0b, $0e, $0e
        .byte $0d, $0f, $0f, $0f
        .byte $0b, $0e, $0f, $0f
        .byte $0d, $0f, $0f, $0f

        ; $60-$6f
        .byte $07, $0a, $0b, $0b
        .byte $0b, $0e, $0e, $0e
        .byte $0b, $0e, $0f, $0f
        .byte $0d, $0f, $0f, $0f

        ; $70-$7f
        .byte $09, $0b, $0e, $0e
        .byte $0d, $0f, $0f, $0f
        .byte $0b, $0e, $0f, $0f
        .byte $0d, $0f, $0f, $0f

        ; $80-$8f
        .byte $05, $08, $09, $09
        .byte $09, $0c, $0c, $0c
        .byte $09, $0d, $0d, $0d
        .byte $0c, $0d, $0d, $0d

        ; $90-$9f
        .byte $09, $0c, $0f, $0f
        .byte $0d, $10, $10, $10
        .byte $0c, $0f, $10, $10
        .byte $0d, $10, $10, $10

        ; $a0-$af
        .byte $09, $0c, $0d, $0d
        .byte $0d, $10, $10, $10
        .byte $0d, $10, $11, $11
        .byte $0f, $11, $11, $11

        ; $b0-$bf
        .byte $0b, $0d, $10, $10
        .byte $0f, $11, $11, $11
        .byte $0d, $10, $11, $11
        .byte $0f, $11, $11, $11
        
        ; $c0-$cf
        .byte $07, $09, $0c, $0c
        .byte $0c, $0d, $0d, $0d
        .byte $0c, $0f, $10, $10
        .byte $0d, $10, $10, $10

        ; $d0-$df
        .byte $0b, $0d, $10, $10
        .byte $0f, $11, $11, $11
        .byte $0d, $10, $11, $11
        .byte $0f, $11, $11, $11

        ; $e0-$ef
        .byte $09, $0c, $0d, $0d
        .byte $0d, $10, $10, $10
        .byte $0d ,$10, $11, $11
        .byte $0f, $11, $11, $11

        ; $f0-$ff
        .byte $0b, $0d, $10, $10
        .byte $0f, $11, $11, $11
        .byte $0d, $10, $11, $11
        .byte $0f, $11, $11, $11


dysp_clear_timing_fast
        lda #0
.for row = 0, row < DYSP_HEIGHT, row = row + 1
        sta dysp_sprite_enable + row
.next
        rts


dysp_calc_timing_fast
        lda sprite_positions + 1
        sec
        sbc #$32
        tax
.for row = 0, row < 21, row = row + 1
        lda dysp_sprite_enable + row,x
        ora #1
        sta dysp_sprite_enable + row,x
.next
        lda sprite_positions + 3
        sec
        sbc #$32
        tax
.for row = 0, row < 21, row = row + 1
        lda dysp_sprite_enable + row,x
        ora #2
        sta dysp_sprite_enable + row,x
.next
        lda sprite_positions + 5
        sec
        sbc #$32
        tax
.for row = 0, row < 21, row = row + 1
        lda dysp_sprite_enable + row,x
        ora #4
        sta dysp_sprite_enable + row,x
.next
        lda sprite_positions + 7
        sec
        sbc #$32
        tax
.for row = 0, row < 21, row = row + 1
        lda dysp_sprite_enable + row,x
        ora #8
        sta dysp_sprite_enable + row,x
.next
        lda sprite_positions + 9
        sec
        sbc #$32
        tax
.for row = 0, row < 21, row = row + 1
        lda dysp_sprite_enable + row,x
        ora #16
        sta dysp_sprite_enable + row,x
.next
        lda sprite_positions + 11
        sec
        sbc #$32
        tax
.for row = 0, row < 21, row = row + 1
        lda dysp_sprite_enable + row,x
        ora #32
        sta dysp_sprite_enable + row,x
.next
        lda sprite_positions + 13
        sec
        sbc #$32
        tax
.for row = 0, row < 21, row = row + 1
        lda dysp_sprite_enable + row,x
        ora #64
        sta dysp_sprite_enable + row,x
.next
        lda sprite_positions + 15
        sec
        sbc #$32
        tax
.for row = 0, row < 21, row = row + 1
        lda dysp_sprite_enable + row,x
        ora #128
        sta dysp_sprite_enable + row,x
.next

        ; update actual cycle skip table
.for row = 0, row < DYSP_HEIGHT, row = row + 1
        ldy dysp_sprite_enable + row
        lda cycles,y
        sta timing + 2 + row
.next

        rts





; Link music
        * = $1000
.binary music_sid, $7e

