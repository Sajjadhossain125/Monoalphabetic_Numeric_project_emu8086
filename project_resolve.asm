ORG 0100H

.data

newline                EQU 10  ; \n
cret                   EQU 13  ; \r
bcksp                  EQU 8   ; \b


input_string           DB      259 dup ('$') 
message_welcome        DB      10,13,10,13,'Choose a encryption system... ', cret, newline
                       DB      '1. Monoalphabetic ', cret, newline
                       DB      '2. Mononumeric', cret, newline, '$'
                       
message_welcome1       DB      10,13,10,13,'This is monoalphabetic encryption system... $'                 
message_welcome2       DB      10,13,10,13,'This is mononumeric encryption system... $' 
message_using_input    DB      10,13,'Please enter your string below...' , cret, newline, '$'              
message_try_again      DB      cret, newline, 'Give it one more try? (y/n)', cret, newline, '$'
message_press_key      DB      'Press any key to exit...$'                      
message_display_org    DB      cret, newline, 'Your original string: $'                       
message_display_enc    DB      cret, 'Encrypted message: $'
message_display_dec    DB      cret, 'Decrypted message: $'
message_encrypting     DB      'Encrypting...$'
message_decrypting     DB      'Decrypting...$'
                       
                       
encryption_table_lower DB      97 dup (' '), 'zyxwvutsrqponmlkjihgfedcba'  
decryption_table_lower DB      97 dup (' '), 'zyxwvutsrqponmlkjihgfedcba'  
                                   
encryption_table_upper DB      65 dup (' '), 'ZYXWVUTSRQPONMLKJIHGFEDCBA'  
decryption_table_upper DB      65 dup (' '), 'ZYXWVUTSRQPONMLKJIHGFEDCBA' 

encryption_digit_table DB      48 dup (' '), '9876543210'  
decryption_digit_table DB      48 dup (' '), '9876543210' 

.code
main proc
    
     
    
    JMP start 
    
    start:                 
    LEA     DX, message_welcome
    MOV     AH, 09
    INT     21H   
    
    MOV AH, 1
    INT 21H
    sub al,48
    
    CMP AL, 2
    JE mononumeric

    LEA     DX, message_welcome1
    MOV     AH, 9
    INT     21H 
                
    LEA     DX, message_using_input
    MOV     AH, 9
    INT     21H
    LEA     SI, input_string
    MOV     AH, 1
    MOV     CX, 255                   
    JMP     input_loop
     
    
    mononumeric:
    LEA     DX, message_welcome2
    MOV     AH, 9
    INT     21H
    
    LEA     DX, message_using_input
    MOV     AH, 9
    INT     21H
    LEA     SI, input_string
    MOV     AH, 1
    MOV     CX, 255                   
    JMP     input_loop
    
    backspace_entered:     
    INC     CX 
                
    input_loop:            
    INT     21H                                                      
    MOV     [SI], AL
    CMP     AL, bcksp
    JNE     cont_input                     
    CMP     SI, offset input_string  
    JE      input_loop                     
    MOV     [SI], ' '
    CALL    omit_space
    DEC     SI                      
    JMP     backspace_entered 
                                               
    cont_input:            
    INC     SI
    CMP     AL, cret
    JE      terminate_string                   
    LOOP    input_loop 
                                                     
    terminate_string:      
    MOV     [SI-1], cret
    MOV     [SI], newline
    MOV     [SI+1], '$'
    LEA     SI, input_string
    JMP     start_process

                                                                
    start_process:
    LEA     DX, message_display_org
    MOV     AH, 9         
    INT     21H            
    LEA     DX, SI
    MOV     AH, 9          
    INT     21H             
                                                                                              
    ; Encrypt:             
    LEA     DX, message_encrypting   
    MOV     AH, 9
    INT     21H
    MOV     AH, 1           
    CALL    encrypt_decrypt 
    
    LEA     DX, message_display_enc
    MOV     AH, 9         
    INT     21H                        
    LEA     DX, SI
    MOV     AH, 9          
    INT     21H             
    
    ; Decrypt:
    LEA     DX, message_decrypting    
    MOV     AH, 9
    INT     21H
    MOV     AH, 0           
    CALL    encrypt_decrypt 
    
    LEA     DX, message_display_dec
    MOV     AH, 9          
    INT     21H                         
    LEA     DX, SI
    MOV     AH, 9          
    INT     21H

    try_again:             
    LEA     DX, message_try_again    
    MOV     AH, 9
    INT     21H
    MOV     AH, 0
    INT     16H
    CMP     AL, 'y'
    JE      start
    CMP     AL, 'n'
    JNE     try_again

    ; message_press_key
    LEA     DX, message_press_key
    MOV     AH, 9
    INT     21H
    MOV     AH, 0          
    INT     16H               
    
    RET   
    main endp


encrypt_decrypt PROC    
    PUSH    SI  
    
    next_char:             
    MOV     AL, [SI]
    CMP     AL, '$'         
    JE      end_of_string
    CALL    enc_dec_char
    INC     SI	
    JMP     next_char
    
    end_of_string:         
    POP     SI
    RET            
    encrypt_decrypt ENDP

omit_space PROC       
    PUSH    SI  
                                  
    omit_space_loop:       
    MOV     AL, [SI+1]      
    MOV     [SI+1], ' '     
    MOV     [SI], AL
    INC     SI
    CMP     [SI-1], '$'                      
    JNE     omit_space_loop
    POP     SI  
    RET
    omit_space ENDP    


enc_dec_char PROC    
    PUSH    BX    
    CMP     AL, 'a'       
    JB      check_upper_char
    CMP     AL, 'z'
    JA      skip_char
    CMP     AH, 1          
    JE      encrypt_lower_char
    CMP     AH, 0          
    JNE     skip_char
    LEA     BX, decryption_table_lower
    JMP     translate_char  
                       
    encrypt_lower_char:	   
    LEA     BX, encryption_table_lower 
    JMP     translate_char 
                   	
    check_upper_char:      
    CMP     AL, 'A'
    JB      check_digit_char
    CMP     AL, 'Z'
    JA      skip_char
    CMP     AH, 1          
    JE      encrypt_upper_char
    CMP     AH, 0         
    JNE     skip_char
    LEA     BX, decryption_table_upper
    JMP     translate_char
     
    encrypt_upper_char:    
    LEA     BX, encryption_table_upper	
    JMP     translate_char
    
    check_digit_char: 
    CMP     AL, '0'
    JB      skip_char
    CMP     AL, '9'
    JA      skip_char
    CMP     AH, 1          
    JE      encrypt_digit
    CMP     AH, 0         
    JNE     skip_char
    LEA     BX, decryption_digit_table
    JMP     translate_char
     
    encrypt_digit:    
    LEA     BX, encryption_digit_table
    	
    translate_char: 
    
           
    XLATB
    MOV     [SI], AL
    	                		
    skip_char:             
    POP     BX
    RET
    enc_dec_char ENDP

end main