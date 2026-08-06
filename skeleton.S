.section ".text"

.global vectors

.balign 2048
vectors:
   .align 7                      
   b unhandled                 
   .align 7
   b unhandled                    
   .align 7
   b unhandled           
   .align 7
   b unhandled      
   .align 7                      
   b unhandled                 
   .align 7
   b unhandled                    
   .align 7
   b unhandled           
   .align 7
   b unhandled
   .align 7                      
   b unhandled                 
   .align 7
   b unhandled                    
   .align 7
   b unhandled           
   .align 7
   b unhandled      
   .align 7                      
   b unhandled                 
   .align 7
   b unhandled                    
   .align 7
   b unhandled           
   .align 7
   b unhandled

unhandled:
    b .

