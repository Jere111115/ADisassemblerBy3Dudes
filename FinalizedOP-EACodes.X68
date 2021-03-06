*-----------------------------------------------------------
* Title      : Disassembler IO File
* Written by : Torren,Doug,Jeremiah
* Date       : 11/23/2018
* Description:
*-----------------------------------------------------------
START           EQU     $1000
CR              EQU     $0D         * ASCII code for Carriage Return
LF              EQU     $0A         * ASCII code for Line Feed
STACK           EQU     $10000      * Defined location for the stack
LINE_CNT        EQU     $F          * Number of lines to print before pausing
EXIT            EQU     $2700


*   D0:  
*   D1:  
*   D2:  
*   D3:  
*   D4: 
*   !D5: OP_CHECK to I/O RTS holder
*   !D6: Current OP code read from latest Current Address position
*   !D7: The current line being printed (I/O line counter)

*   A0:  
*   A1:  
*   A2:  
*   A3:  
*   A4:  
*   !A5: Current Address;   DO NOT ALTER (Initialized via start up requests
*           - except for when in EA to get more information
*   !A6: End Address;       DO NOT ALTER (Initialized via start up requests)
*   !A7: STACK POINTER;     DO NOT ALTER
*           - except in adding or taking from stack






        ORG    START
        

*-----------------I/O code----------------

*---Positioning the stack---
        LEA     STACK,SP        * Position the stack
        
*-------Requesting the Starting Address---
STRT_ADDR_RQST
        LEA     STRT_RQST,A1    * Load/print start address request text
        MOVE.L  #14,D0
        TRAP    #15
        
        CLR.L   D1              * Clear any previously used Dr from looped requests
        CLR.L   D2
        CLR.L   D3
        CLR.L   D4
        
        MOVE.L  #2,D0           * Take in their start address
        MOVE.L  #0,A1           * Cleared A1 to not print over start address request in memory
        TRAP    #15
        
        CMP     #8,D1           * Make sure not longer than 8
        BGT     STRT_ADDR_RQST
     
*---Converting input to hex address------           
CNVRT_STRT
        CMP.L   D2,D1           * Check if all entered ASCII converted
        BEQ     SAVE_STRT       * Move on to save the start address into Current Address (A5)
            
        LSL.L   #4,D4           * Move D4 left to make room for next entry
        MOVE.B  (A1)+,D3        * Put first char into D3 for conversion
            
            
        CMP.B   #$39,D3         * Check if char is '9' or less in ASCII
        BLE     ITS_A_NUM_STRT  * Branch to number intake method
                        
        CMP.B   #$41,D3         * Check if char is 'A' or higher in ASCII
        BGE     ITS_A_CHR_STRT  * Branch to char intake mehtod

        BRA     STRT_ADDR_RQST  * Not in bounds of valid data, request again

ITS_A_NUM_STRT
        CMP.B   #$30,D3         * Check if char is '0' or higher in ASCII
        BLT     STRT_ADDR_RQST  * Not in bounds of valid data, request again
        
        SUB.L   #$30,D3         * Convert from ASCII number to hex number
        
        ADD.L   D3,D4           * Add newest converted char to entire hex
        
        ADD.B   #1,D2           * Increment counter
        
        BRA     CNVRT_STRT      * Loop back to convert next char
        
ITS_A_CHR_STRT
        CMP.B   #$46,D3         * Check if char is 'F' or less in ASCII
        BGT     STRT_ADDR_RQST  * Not in bounds of valid data, request again
        
        SUB.L   #$37,D3         * Convert from ASCII letter to hex 'letter'
        
        ADD.L   D3,D4           * Add newest converted char to entire hex
        
        ADD.B   #1,D2           * Increment counter
        
        BRA     CNVRT_STRT      * Loop back to convert next char
        
        
SAVE_STRT
        MOVE.L  D4,D3           * Double up the converted address for mutation
        AND.L   #$1,D3          * Bit-mask with 1 to check for odd/even
        CMP     #1,D3
        BEQ     STRT_ADDR_RQST  * Odd value not allowed, request again
        
        MOVE.L  D4,A5           * Save the given starting address in Current Address position (A5)
   
   
   
*-------Requesting the End Address-------
END_ADDR_RQST
        LEA     END_RQST,A1     * Load/print end address request text
        MOVE.L  #14,D0
        TRAP    #15
        
        CLR.L   D1              * Clear any previously used Dr from looped requests
        CLR.L   D2
        CLR.L   D3
        CLR.L   D4
        
        MOVE.L  #2,D0           * Take in their end address
        MOVE.L  #0,A1           * Cleared A1 to not print over start address request in memory
        TRAP    #15
        
        CMP     #8,D1           * Make sure not longer than 8
        BGT     END_ADDR_RQST   
        
        
*---Converting input to hex address------
CNVRT_END
        CMP.L   D2,D1           * Check if all entered ASCII converted
        BEQ     SAVE_END        * Move on to saving end address if done
            
        LSL.L   #4,D4           * Move D4 left to make room for next entry
        MOVE.B  (A1)+,D3        * Put first char into D3 for conversion
            
            
        CMP.B   #$39,D3         * Check if char is '9' or less in ASCII
        BLE     ITS_A_NUM_END   * Branch to number intake method
                        
        CMP.B   #$41,D3         * Check if char is 'A' or higher in ASCII
        BGE     ITS_A_CHR_END   * Branch to char intake mehtod

        BRA     END_ADDR_RQST

ITS_A_NUM_END
        CMP.B   #$30,D3         * Check if char is '0' or higher in ASCII
        BLT     END_ADDR_RQST   * Not in bounds of valid data, request again
        
        SUB.L   #$30,D3         * Convert from ASCII number to hex number
        
        ADD.L   D3,D4           * Add newest converted char to entire hex
        
        ADD.B   #1,D2           * Increment counter
        
        BRA     CNVRT_END       * Loop back to convert next char
        
ITS_A_CHR_END
        CMP.B   #$46,D3         * Check if char is 'F' or less in ASCII
        BGT     END_ADDR_RQST   * Not in bounds of valid data, request again
        
        SUB.L   #$37,D3         * Convert from ASCII letter to hex 'letter'
        
        ADD.L   D3,D4           * Add newest converted char to entire hex
        
        ADD.B   #1,D2           * Increment counter
        
        BRA     CNVRT_END       * Loop back to convert next char
        
        
SAVE_END
        MOVE.L  D4,A6           * Save the given/converted address in End Address (A6)
        
        CLR.L   D0              * Clear unnecessary data from Dr list
        CLR.L   D1
        CLR.L   D2
        CLR.L   D3
        CLR.L   D4
        CLR.L   D5
        CLR.L   D6
        CLR.L   D7
        
        
*-------Moving on to decoding; start with instructions-------        
BEGIN
        LEA     INSTRCTNS,A1    * Load instruction to inform user how disassembler will work
        MOVE.B  #14,D0
        TRAP    #15
        
        MOVE.L  #0,A1           * Clear A1 to ensure instructions not overwritten

*-------Pause and wait for user to continue------------------
WAIT
        MOVE.L  #5,D0           * Pause for 'enter' by user to move forward
        TRAP    #15             *   A char is actually taken in for D1
        
        CLR.L   D7              * Zero the line counter

*---Check if done or perform next line's disassembly---------
SEE_IF_DONE
        CMP     A5,A6           * Check if Current Address is past End Address
        BLT     DONE            * Branch to DONE if completed
        
        CMP.L   #15,D7          * Check if we have printed 15 lines
        BEQ     WAIT            * Await 'Enter' before continuing if so
        
        CLR.L   D0              * Clear unnecessary data from register list except for:
        CLR.L   D1              * (D7) line counter, (A5) current address, (A6) end address,
        CLR.L   D2              * and (A7/SP) stack pointer
        CLR.L   D3
        CLR.L   D4
        CLR.L   D5
        CLR.L   D6
        MOVE.L  #0,A0
        MOVE.L  #0,A1
        MOVE.L  #0,A2
        MOVE.L  #0,A3
        MOVE.L  #0,A4
        
        JSR     PRINT_CURRENT_ADDRESS
        
        MOVE.W  (A5)+,D6        * Take the next word of instruction into Current OPcode and increment Current address
        
        JSR     OP_CHECK        * Jump to the OP_CHECK code
                                * Sending:      A0-A4:  Empty
                                *               A5:     The Current Address (just after Current OPcode)
                                *                           Alter this only if more information deemed necessary via OPcode/EAcode
                                *               !A6:    The End Address (DO NOT TOUCH)
                                *               A7:     The current stack position
                                *                           Alter this in order to maintain RTS position and to prepare print statement for OPcode's line
                                *               D0-D5:  Empty
                                *               !D6:    The current OPcode being worked (DO NOT TOUCH)
                                *               !D7:    The current count of lines printed (DO NOT TOUCH)
                                *
                                * Need back:    A0-A4:  Garbage - anything is fine as these will be cleared
                                *               A5:     The Current Address from which the next OPcode will be read
                                *               !A6:    The End Address
                                *               A7:     The current stack position
                                *                           Should have the start of the OPcode's string to be printed and end with "'CR','LF',0"
                                *               D0-D5:  Garbage - anything is fine as these will be cleared
                                *               D6:     Unneeded / was the just completed OPcode
                                *               !D7:    The current count of lines printed
        
        
        MOVE.L  #14,D0           * Prep for printing the just disassembled OPcode
        
        MOVE.L  SP,A1
        TRAP    #15
        
        LEA     STACK,SP
        
        ADD.L   #1,D7
        
        BRA     SEE_IF_DONE




*---------Print a hex address as a string-----
PRINT_CURRENT_ADDRESS
        MOVE.L  A5,D4
        LEA     HEX_to_ASCII,A4

PRNT_LOOP
        CMP     #4,D2           * Check if the 4 bytes have been printed
        BEQ     PRNT_DONE
        
        ROL.L   #8,D4           * Position the first/next byte
        
        MOVE.B  D4,D3           * Take in the byte
        LSR.L   #4,D3           * Only use first nibble

        MOVE.B  (0,A4,D3.W),D1  * Find the correct ASCII char

        MOVE.B  #6,D0           * Print the char
        TRAP    #15A

        MOVE.B  D4,D3           * Take in the byte again
        AND.B   #%00001111,D3   * Mask for second nibble

        MOVE.B  (0,A4,D3.W),D1  * Find the correct ASCII char
        TRAP    #15             * and print
        
        ADDI.B  #1,D2           * Increment counter
        BRA     PRNT_LOOP
        
PRNT_DONE
        CLR.L   D0              * Clear the Drs that were used
        CLR.L   D1
        CLR.L   D3
        CLR.L   D4
        CLR.L   D5
        RTS



*---------Branch to when Current Address past End Address-----
DONE
    STOP    #EXIT               * Done, thus exit










* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! *
OP_CHECK

    * PLACEHOLDER FOR ACTUAL OP CODE ELSEWHERE
    *
    * Put your own code here to test it
    

    CMP.L   #$00004E71,D6
    BEQ     NOP_FOUND
    
    MOVE.L  #15,D4
    
    * !!! *
    * Place your finalized CMP code block above this line
    * !!! *
    
    
NOP_FOUND
    MOVE.L  (SP)+,D5
    MOVE.W  #$0A00,-(SP)
    MOVE.W  #$500D,-(SP)
    MOVE.W  #$4E4F,-(SP)
    MOVE.L  D5,-(SP)
    RTS 
    
    
    * !!! *
    * Place your finalized <OP code name>_FOUND code block above this line
    * !!! *
*    
*    
* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! *




* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! *
* Placeholder position for where the EA code will go
    
    * SELF EXPLANATORY ADDITIONAL TESTING AREA
    * 
    * Replace the name and test your I/O -> OP_CHECK -> EA code here



    * !!! *
    * Place your finalized <OP code name>_EA code block above this line
    * !!! *
*
*
* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! *











* Variables and defined constraints

STRT_RQST       DC.B    'Please provide a valid starting hex address for the code to be disassembled.',CR,LF
                DC.B    'Invalid entry will only lead to the question being repeated.',CR,LF
                DC.B    'Only numbers 0-9 and capitals A-F are accepted.',CR,LF
                DC.B    'Starting address must also be even.',CR,LF
                                                                          * There's a chance we also want to iron out and check to ensure it's not our own code?
                DC.B    'What will the starting address be?',CR,LF,0 
            
END_RQST        DC.B    'Thank you for the starting address.',CR,LF
                DC.B    'Please now provide an end address.',CR,LF
                DC.B    'Invalid entry will only lead to the question being repeated.',CR,LF
                DC.B    'Only numbers 0-9 and capitals A-F are accepted.',CR,LF
                                                                          * There's a chance we also want to iron out and check to ensure it's not our own code?
                DC.B    'What will the ending address be?',CR,LF,0
            
INSTRCTNS       DC.B    'We are ready to begin reading the code between the given starting and end addresses.',CR,LF
                DC.B    'While running, the program will pause every fifteen lines.',CR,LF
                DC.B    'To continue, press the "Enter" key.',CR,LF
                DC.B    'Do so now to begin.',CR,LF,0

HEX_to_ASCII    DC.B    '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'


    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
