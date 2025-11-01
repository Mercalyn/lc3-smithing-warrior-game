.ORIG x3000
; ------------------------
; High level overview:
; "Smithing Warrior"
; a text-based game allowing the player to mine, 
; smith, and craft their way to freedom
; ----
; global variables:
; R1 command input
; R2 money
; R3 print value (ascii)
; R4, R5, generic inner subroutine temp values
; R6 JSRR address
; ----
; all inner subroutines track their own R7 RET addresses if req.d
; ----
; Purpose:
; It's a video game!
; ----
; Author: 
; Em Thomas 11057617@uvu.edu
; ----
; Subroutines and their purpose:
; MAIN: primary flow, resource amount and unlock bool storage
; CHECK_INPUT: trap input, send to correct JSR or increment ore, input validation for actions
; DISPLAY: display inventory, available actions
; PRINT_ASCII_R3: print to console value in R3, max val 9999
; SELL: sell everything in inventory for market value
; SMELT_BRONZE: smelt bronze bar
; SMITH_SWORD: smith bronze sword
; UPGRADE: upgrade/unlock screen
; WELCOME_MSG: welcome msg
; WIN_MSG: win condition
; see the corresponding .doc for more details
; ------------------------


; --------
; MAIN: overall flow
; --------
MAIN
    LD R6, WELCOME_MSG_ADDRESS_MAIN ; welcome msg
    JSRR R6
    
    LD R4, MONEY_DEBUG_START ; debug money
    ADD R2, R2, R4
    
    MAIN_LOOP ; overall starting loop
        JSR DISPLAY ; display stats and controls
        JSR CHECK_INPUT ; actions
    BR MAIN_LOOP
HALT

; MATERIALS
MONEY_DEBUG_START .FILL #0
COPPER_ORE .FILL #0
TIN_ORE .FILL #0
BRONZE_BAR .FILL #0
BRONZE_SWORD .FILL #0

; UNLOCK BOOLS
U_BRONZE_BAR .FILL #0 ; debug set to 1 to unlock
U_BRONZE_SWORD .FILL #0

; things too far away
WELCOME_MSG_ADDRESS_MAIN .FILL WELCOME_MSG
;------------ END MAIN -------------



; --------
; DISPLAY: 
; display money, avl. actions/controls
; --------
DISPLAY
    ST R7, DISPLAY_RET ; save RET
    LD R6, PRINT_ASCII_R3_ADDRESS ; load print ascii address

    LD R0, SEPARATOR_ADDRESS
    PUTS
    LD R0, MONEY_SYM ; print $ symbol
    OUT
    AND R3, R3, #0 ; money: reset, load, print ascii
    ADD R3, R2, #0
    JSRR R6
    
    LEA R0, ACTIONS_AVL ; avl. actions
    PUTS
    LEA R0, M_TIN_ORE ; tin ore
    PUTS
    LEA R0, M_COPPER_ORE ; copper ore
    PUTS
    LEA R0, M_SELL ; sell button
    PUTS
    LEA R0, M_UPGRADE ; upgrade button
    PUTS
    
    LD R4, U_BRONZE_BAR ; check bronze bar action
    BRnz INV_LABEL
    LEA R0, M_BRONZE_BAR ; continue if -> p
    PUTS
    
    LD R4, U_BRONZE_SWORD ; check bronze sword action
    BRnz INV_LABEL
    LEA R0, M_BRONZE_SWORD ; continue if -> p
    PUTS
    
    
    INV_LABEL
        ; print inventory
        LEA R0, M_INVENTORY
        PUTS
        
        LD R3, TIN_ORE ; load tin
        JSRR R6 ; display tin
        LEA R0, H_TIN_ORE
        PUTS
        
        LD R3, COPPER_ORE ; load copper
        JSRR R6 ; display copper
        LEA R0, H_COPPER_ORE
        PUTS
        
        INV_BBAR ; check bronze bar inventory
            LD R4, U_BRONZE_BAR
            BRnz INV_BSWORD ; nz -> not unlocked, do not display
            LD R3, BRONZE_BAR ; continue if -> p
            JSRR R6 ; display bbar
            LEA R0, H_BRONZE_BAR 
            PUTS
        
        INV_BSWORD ; check bronze sword inventory
            LD R4, U_BRONZE_SWORD
            BRnz DISPLAY_DONE ; nz -> not unlocked, do not display
            LD R3, BRONZE_SWORD ; continue if -> p
            JSRR R6 ; display bsword
            LEA R0, H_BRONZE_SWORD 
            PUTS
    
    DISPLAY_DONE
    
    
    LD R7, DISPLAY_RET
RET
PRINT_ASCII_R3_ADDRESS .FILL PRINT_ASCII_R3
MONEY_SYM .FILL x24
DISPLAY_RET .FILL x0
SEPARATOR_ADDRESS .FILL SEPARATOR
ACTIONS_AVL .STRINGZ "\n\nAvailable Actions:\n"

M_TIN_ORE .STRINGZ "t - mine tin ore\n"
M_COPPER_ORE .STRINGZ "c - mine copper ore\n"
M_BRONZE_BAR .STRINGZ "b - smelt bronze bar\n"
M_BRONZE_SWORD .STRINGZ "q - smith bronze sword\n"
M_SELL .STRINGZ "s - sell everything in inventory\n"
M_UPGRADE .STRINGZ "u - go to upgrades page\n"
M_INVENTORY .STRINGZ "\nInventory:\n"

H_COPPER_ORE .STRINGZ " - Copper Ore\n"
H_TIN_ORE .STRINGZ " - Tin Ore\n"
H_BRONZE_BAR .STRINGZ " - Bronze Bar\n"
H_BRONZE_SWORD .STRINGZ " - Bronze Sword\n"
SEPARATOR .STRINGZ "\n\n\n\n\n------------------------------------\n"
;------------ END DISPLAY -------------



; --------
; CHECK_INPUT
; see CHECK_INPUT.doc for key inputs
; --------
CHECK_INPUT
    ST R7, INPUT_RET ; save RET
    LEA R0, ACTIONATE
    PUTS
    GETC ; input char
    
    ; check tin ore
    LD R4, KEY_TIN
    ADD R4, R4, R0
    BRnp PROC_TIN_DONE ; np -> not key: continue to next key
    PROC_TIN_ORE ; else z -> process action
        LDI R4, TIN_ORE_ADDRESS_CI ; load tin, add 1, save
        ADD R4, R4, #1
        STI R4, TIN_ORE_ADDRESS_CI
        
        BR CHECK_I_DONE ; goto end
    PROC_TIN_DONE
    
    
    ; check copper ore
    LD R4, KEY_COPPER
    ADD R4, R4, R0
    BRnp PROC_COPPER_DONE ; np -> not key: continue to next key
    PROC_COPPER_ORE ; else z -> process action
        LDI R4, COPPER_ORE_ADDRESS_CI ; load copper, add 1, save
        ADD R4, R4, #1
        STI R4, COPPER_ORE_ADDRESS_CI
        
        BR CHECK_I_DONE ; goto end
    PROC_COPPER_DONE
    
    
    ; check bronze bar
    LD R4, KEY_BBAR
    ADD R4, R4, R0
    BRnp PROC_BRONZE_DONE ; np -> not key: continue to next key
    PROC_BRONZE ; else z -> process action
        JSR SMELT_BRONZE ; jmp to smelt bronze 
        
        BR CHECK_I_DONE ; goto end
    PROC_BRONZE_DONE
    
    
    ; check bronze sword
    LD R4, KEY_SWORD
    ADD R4, R4, R0
    BRnp PROC_SWORD_DONE ; np -> not key: continue to next key
    PROC_SWORD ; else z -> process action
        JSR SMITH_SWORD
        
        BR CHECK_I_DONE ; goto end
    PROC_SWORD_DONE
    
    
    ; check sell
    LD R4, KEY_SELL
    ADD R4, R4, R0
    BRnp PROC_SELL_DONE ; np -> not key: continue to next key
    PROC_SELL ; else z -> process action
        JSR SELL ; go to sell logic
        
        BR CHECK_I_DONE ; goto end
    PROC_SELL_DONE
    
    
    ; check upgrades
    LD R4, KEY_UPGRADE
    ADD R4, R4, R0
    BRnp PROC_UPGRADE_DONE ; np -> not key: continue to next key
    PROC_UPGRADE ; else z -> process action
        LD R6, UPGRADE_ADDRESS_CI ; go to upgrade screen
        JMP R6
        
        BR CHECK_I_DONE ; goto end
    PROC_UPGRADE_DONE
    
    
    CHECK_I_DONE ; done done
    LD R7, INPUT_RET ; load RET
RET
UPGRADE_ADDRESS_CI .FILL UPGRADE
TIN_ORE_ADDRESS_CI .FILL TIN_ORE
COPPER_ORE_ADDRESS_CI .FILL COPPER_ORE
INPUT_RET .FILL x0
KEY_COPPER .FILL x-63 ; t
KEY_BBAR .FILL x-62 ; b
KEY_TIN .FILL x-74 ; c
KEY_SWORD .FILL x-71 ; q
KEY_SELL .FILL x-73 ; s
KEY_UPGRADE .FILL x-75 ; u
ACTIONATE .STRINGZ "Enter your action: "
;------------ END CHECK_INPUT -------------



; --------
; SMELT_BRONZE
; check has 2 tin and 2 copper to make 1 bronze bar
; --------
SMELT_BRONZE
    LDI R4, TIN_ORE_ADDRESS_SMELT ; load tin resource, check - 2
    ADD R4, R4, #-2
    BRn SMELT_NO_TIN ; negative means not enough tin
    
    LDI R4, COPPER_ORE_ADDRESS_SMELT ; load copper resource, check - 2
    ADD R4, R4, #-2
    BRn SMELT_NO_COPPER ; negative means not enough copper
    
    SMELT_DO ; made it here? enough to smelt bronze
        LDI R4, BRONZE_BAR_ADDRESS_SMELT ; load bronze bar and + 1
        ADD R4, R4, #1
        STI R4, BRONZE_BAR_ADDRESS_SMELT
        LEA R0, SMELT_SUCCESS_STR ; success msg
        PUTS
        
        LDI R4, TIN_ORE_ADDRESS_SMELT ; load tin ore and actually save its - 2
        ADD R4, R4, #-2
        STI R4, TIN_ORE_ADDRESS_SMELT
        
        LDI R4, COPPER_ORE_ADDRESS_SMELT ; load copper ore and actually save its - 2
        ADD R4, R4, #-2
        STI R4, COPPER_ORE_ADDRESS_SMELT
        
        BR SMELT_DONE ; done
    
    SMELT_NO_TIN ; no tin msg
        LEA R0, SMELT_NO_TIN_STR
        PUTS
        BR SMELT_DONE
    
    SMELT_NO_COPPER ; no copper msg
        LEA R0, SMELT_NO_COPPER_STR
        PUTS
        BR SMELT_DONE
    
    SMELT_DONE
    
    LD R0, SMELT_ACK ; ack
    PUTS
    GETC
RET
TIN_ORE_ADDRESS_SMELT .FILL TIN_ORE
COPPER_ORE_ADDRESS_SMELT .FILL COPPER_ORE
BRONZE_BAR_ADDRESS_SMELT .FILL BRONZE_BAR
SMELT_ACK .FILL UP_ACK
SMELT_NO_TIN_STR .STRINGZ "You need 2 tin ore to do this!\n"
SMELT_NO_COPPER_STR .STRINGZ "You need 2 copper ore to do this!\n"
SMELT_SUCCESS_STR .STRINGZ "You made a bronze bar!\n"
;------------ END SMELT_BRONZE -------------


; --------
; SMITH_SWORD
; check has 2 bronze bars to make 1 bronze sword
; --------
SMITH_SWORD
    LDI R4, BRONZE_BAR_ADDRESS_SMITH
    ADD R4, R4, #-2
    BRn SMITH_NO_BARS ; negative means not enough bars
    
    AND R4, R4, #0
    LD R5, SMITH_COIN_COST
    ADD R4, R2, R5
    BRn SMITH_NO_COIN ; negative means not enough $
    
    SMITH_DO ; made it here? enough to smith a sword
        LDI R4, BRONZE_BAR_ADDRESS_SMITH ; load bronze bar and actually save its - 2
        ADD R4, R4, #-2
        STI R4, BRONZE_BAR_ADDRESS_SMITH
        
        ADD R2, R2, R5 ; $ - 20
        
        LDI R4, BRONZE_SWORD_ADDRESS_SMITH ; load bronze sword and + 1
        ADD R4, R4, #1
        STI R4, BRONZE_SWORD_ADDRESS_SMITH
        
        LEA R0, SMITH_SUCCESS_STR ; success msg
        PUTS
        BR SMITH_DONE
    
    SMITH_NO_BARS ; no bars msg
        LEA R0, SMITH_NO_BARS_STR
        PUTS
        BR SMITH_DONE
    
    SMITH_NO_COIN ; no coin msg
        LEA R0, SMITH_NO_COINS_STR
        PUTS
        BR SMITH_DONE
    
    SMITH_DONE
    
    LD R0, SMITH_ACK ; ack
    PUTS
    GETC
RET
SMITH_COIN_COST .FILL #-20
SMITH_ACK .FILL UP_ACK
BRONZE_BAR_ADDRESS_SMITH .FILL BRONZE_BAR
BRONZE_SWORD_ADDRESS_SMITH .FILL BRONZE_SWORD
SMITH_SUCCESS_STR .STRINGZ "You made a bronze sword!\n"
SMITH_NO_COINS_STR .STRINGZ "You need 20 coins to do this!\n"
SMITH_NO_BARS_STR .STRINGZ "You need 2 bronze bars to do this!\n"
;------------ END SMITH_SWORD -------------


; --------
; SELL
; sell all items in inventory
; performed by checking individual resources above 1 and adding money
; if resource - 1 is -> zp
; --------
SELL
    SELL_TIN_ORE ; tin ore
        LDI R4, TIN_ORE_ADDRESS_SELL
        ADD R4, R4, #-1
        BRn TIN_O_NEG
        ADD R2, R2, #1 ; value 1
        STI R4, TIN_ORE_ADDRESS_SELL
        BR SELL_TIN_ORE
    TIN_O_NEG ; sold too many, reverse
        ADD R4, R4, #1
    
    
    SELL_COPPER_ORE ; copper ore
        LDI R4, COPPER_ORE_ADDRESS_SELL
        ADD R4, R4, #-1
        BRn COPPER_O_NEG
        ADD R2, R2, #1 ; value 1
        STI R4, COPPER_ORE_ADDRESS_SELL
        BR SELL_COPPER_ORE
    COPPER_O_NEG ; sold too many, reverse
        ADD R4, R4, #1    
        
        
    SELL_BRONZE_BAR ; bronze bar
        LDI R4, BRONZE_BAR_ADDRESS_SELL
        ADD R4, R4, #-1
        BRn BRONZE_B_NEG
        ADD R2, R2, #12 ; value 12
        STI R4, BRONZE_BAR_ADDRESS_SELL
        BR SELL_BRONZE_BAR
    BRONZE_B_NEG ; sold too many, reverse
        ADD R4, R4, #1
        
        
    SELL_BRONZE_SWORD ; bronze sword
        LDI R4, BRONZE_SWORD_ADDRESS_SELL
        ADD R4, R4, #-1
        BRn BRONZE_S_NEG
        LD R3, BSWORD_VALUE_SELL
        ADD R2, R2, R3 ; value 120
        STI R4, BRONZE_SWORD_ADDRESS_SELL
        BR SELL_BRONZE_SWORD
    BRONZE_S_NEG ; sold too many, reverse
        ADD R4, R4, #1
    
RET
; because materials addresses are far:
COPPER_ORE_ADDRESS_SELL .FILL COPPER_ORE
TIN_ORE_ADDRESS_SELL .FILL TIN_ORE
BRONZE_BAR_ADDRESS_SELL .FILL BRONZE_BAR
BRONZE_SWORD_ADDRESS_SELL .FILL BRONZE_SWORD
BSWORD_VALUE_SELL .FILL #120
;------------ END SELL -------------


; --------
; UPGRADE: upgrades page
; --------
UPGRADE
    ; print out upgrade page
    LD R0, UP_PAGE_ADDRESS
    PUTS
    
    UP_BBAR_DISPLAY
        LDI R4, U_BRONZE_BAR_ADDRESS_UP ; check that bronze upgrade is 0 to display
        BRnp UP_BSWORD_DISPLAY ; -> np not 0 continue to check keys
        LD R0, UP_1_ADDRESS ; -> z else display
        PUTS
    
    UP_BSWORD_DISPLAY
        LDI R4, U_BRONZE_SWORD_ADDRESS_UP ; check that sword upgrade is 0 to display
        BRnp UP_GCOIN_DISPLAY ; -> np not 0 continue to check keys
        LD R0, UP_2_ADDRESS ; -> z else display
        PUTS
        
    UP_GCOIN_DISPLAY
    LD R0, UP_WIN_ADDRESS ; display gold coin upgrade
    PUTS
    
    UP_KEYS
        IN
        
        ; check key 1
        LD R4, KEY_1
        ADD R4, R4, R0
        BRz PROC_1
        BR PROC_1_DONE
        PROC_1 ; key 1 pressed
            LD R4, BRONZE_COST ; check has cash
            ADD R2, R2, R4
            BRn PROC_1_NEG
            LDI R4, U_BRONZE_BAR_ADDRESS ; update unlock
            ADD R4, R4, #1
            STI R4, U_BRONZE_BAR_ADDRESS
            BR UPGRADE_CASH
        PROC_1_NEG ; did not have cash, reverse transaction
            LD R4, BRONZE_REV
            ADD R2, R2, R4
            BR UPGRADE_NOCASH
        PROC_1_DONE
        
        
        ; check key 2
        LD R4, KEY_2
        ADD R4, R4, R0
        BRz PROC_2
        BR PROC_2_DONE
        PROC_2 ; key 2 pressed
            LD R4, SWORD_COST ; check has cash
            ADD R2, R2, R4
            BRn PROC_2_NEG
            LDI R4, U_BRONZE_SWORD_ADDRESS ; update unlock
            ADD R4, R4, #1
            STI R4, U_BRONZE_SWORD_ADDRESS
            BR UPGRADE_CASH
        PROC_2_NEG ; did not have cash, reverse transaction
            LD R4, SWORD_REV
            ADD R2, R2, R4
            BR UPGRADE_NOCASH
        PROC_2_DONE
        
        
        ; check key 3
        LD R4, KEY_3
        ADD R4, R4, R0
        BRz PROC_3
        BR PROC_3_DONE
        PROC_3 ; key 3 pressed
            LD R4, GOLD_COIN_COST ; check has cash
            ADD R2, R2, R4
            BRn PROC_3_NEG
            LD R6, UP_WIN_MSG_ADDRESS ; goto end
            JSRR R6
        PROC_3_NEG ; did not have cash, reverse transaction
            LD R4, GOLD_COIN_REV
            ADD R2, R2, R4
            BR UPGRADE_NOCASH
        PROC_3_DONE
    
    
    ; no valid key pressed: just say exiting
    LEA R0, UP_EXIT
    PUTS
    BR UPGRADE_DONE
    
    UPGRADE_NOCASH ; print did not have enough money
        LEA R0, UP_NOCASH
        PUTS
    BR UPGRADE_DONE
    
    UPGRADE_CASH ; print thanks for purchase
        LEA R0, UP_CASH
        PUTS
    BR UPGRADE_DONE
    
    
    UPGRADE_DONE
        LEA R0, UP_ACK
        PUTS
        GETC
RET
UP_PAGE_ADDRESS .FILL UP_PAGE
UP_WIN_ADDRESS .FILL UP_WIN
U_BRONZE_BAR_ADDRESS .FILL U_BRONZE_BAR
UP_1_ADDRESS .FILL UP_1
UP_2_ADDRESS .FILL UP_2
UP_WIN_MSG_ADDRESS .FILL WIN_MSG
U_BRONZE_SWORD_ADDRESS .FILL U_BRONZE_SWORD
U_BRONZE_BAR_ADDRESS_UP .FILL U_BRONZE_BAR
U_BRONZE_SWORD_ADDRESS_UP .FILL U_BRONZE_SWORD

BRONZE_COST .FILL #-20
BRONZE_REV .FILL #20
SWORD_COST .FILL #-120
SWORD_REV .FILL #120
GOLD_COIN_COST .FILL #-1000
GOLD_COIN_REV .FILL #1000
KEY_1 .FILL x-31 ; 1 bronze bar
KEY_2 .FILL x-32 ; 1 bronze sword
KEY_3 .FILL x-33 ; gold coin
UP_EXIT .STRINGZ "Exiting store.\n"
UP_CASH .STRINGZ "Thank you for your purchase!\n"
UP_ACK .STRINGZ "Press any key to continue..."
UP_NOCASH .STRINGZ "You did not have enough cash for this upgrade!\n"
UP_1 .STRINGZ "1 - $20 - Ability make bronze bars from 2 tin and 2 copper ores.\n"
UP_2 .STRINGZ "2 - $120 - Ability make bronze swords from 2 bronze bars and $20.\n"
UP_WIN .STRINGZ "3 - $1000 - Gold coin to purchase freedom.\n"
UP_PAGE .STRINGZ "~~\nWelcome to the unlock store! \nPlease press corresponding number to buy or press ESC to exit.\n"
;------------ END UPGRADES -------------


; --------
; WELCOME_MSG: what the game is and how to play
; this is near the end since this has very long strings
; --------
WELCOME_MSG
    LEA R0, MSG_1 ; welcome msg: player situation, how to win
    PUTS
    LEA R0, MSG_2 ; msg: how to play
    PUTS
    LD R0, MSG_ACK ; ack
    PUTS
    GETC
RET
MSG_ACK .FILL UP_ACK
MSG_1 .STRINGZ "----\nYou awaken in a candle-lit cavern with a locked door.\nA sign reads: \"You have been found guilty of crimes against her majesty.\nBuy your freedom with a gold coin worth $1,000\"\n----\n"
MSG_2 .STRINGZ "How to play: Press keys listed under \"Available Actions\" to perform action.\nPress u to go to unlocks page\n\n"
;------------ END WELCOME_MSG -------------


; --------
; WIN_MSG
; --------
WIN_MSG
    LEA R0, MSG_WIN_1
    PUTS
    LD R0, WIN_ACK
    PUTS
    GETC
    LEA R0, MSG_WIN_2
    PUTS
    HALT
RET
WIN_ACK .FILL UP_ACK
MSG_WIN_1 .STRINGZ "You buy a golden coin and insert it into the door. You walk through it and pass out...\n"
MSG_WIN_2 .STRINGZ "\nYou wake up on a horse-drawn carriage, about to start a Skyrim playthrough. (you win)\n"
;------------ END WIN_MSG -------------


; --------
; PRINT_ASCII_R3
; takes values in R3, prints it to console
; current max value: 9999
; only works with non-negative numbers
; --------
PRINT_ASCII_R3
    ; ------------------------
    PAR_1000
        ; check if should accumulate
        LD R4, N1000
        ADD R3, R3, R4
        BRn PAR_1000_DONE
        ; load accumulate save
        LD R4, V1000
        ADD R4, R4, #1
        ST R4, V1000
        BR PAR_1000
    PAR_1000_DONE ; prior was negative so increment back up
        LD R4, P1000
        ADD R3, R3, R4
        
    ; ------------------------
    PAR_100
        ; check if should accumulate
        LD R4, N100
        ADD R3, R3, R4
        BRn PAR_100_DONE
        ; load accumulate save
        LD R4, V100
        ADD R4, R4, #1
        ST R4, V100
        BR PAR_100
    PAR_100_DONE ; prior was negative so increment back up
        LD R4, P100
        ADD R3, R3, R4
        
    ; ------------------------
    PAR_10
        ; check if should accumulate
        LD R4, N10
        ADD R3, R3, R4
        BRn PAR_10_DONE
        ; load accumulate save
        LD R4, V10
        ADD R4, R4, #1
        ST R4, V10
        BR PAR_10
    PAR_10_DONE ; prior was negative so increment back up
        LD R4, P10
        ADD R3, R3, R4
        
    ; ------------------------
    PAR_1
        ; check if should accumulate
        LD R4, N1
        ADD R3, R3, R4
        BRn PAR_1_DONE
        ; load accumulate save
        LD R4, V1
        ADD R4, R4, #1
        ST R4, V1
        BR PAR_1
    PAR_1_DONE ; prior was negative so increment back up
        LD R4, P1
        ADD R3, R3, R4
    
    ; ------------------------
    ; add ascii and immediately print digit
    LD R0, ASCII
    LD R4, V1000
    ADD R0, R0, R4
    OUT
    
    LD R0, ASCII
    LD R4, V100
    ADD R0, R0, R4
    OUT
    
    LD R0, ASCII
    LD R4, V10
    ADD R0, R0, R4
    OUT
    
    LD R0, ASCII
    LD R4, V1
    ADD R0, R0, R4
    OUT
    
    ; once printed, reset V values
    AND R4, R4, #0
    ST R4, V1000
    ST R4, V100
    ST R4, V10
    ST R4, V1
        
RET
P1000 .FILL #1000
P100 .FILL #100
P10 .FILL #10
P1 .FILL #1
N1000 .FILL #-1000
N100 .FILL #-100
N10 .FILL #-10
N1 .FILL #-1
V1000 .FILL #0
V100 .FILL #0
V10 .FILL #0
V1 .FILL #0
ASCII .FILL x30
;------------ END ASCII PRINT -------------

.END