# NOTES:

https://ianparberry.com/art/ascii/color/

## IDEAS

- lazy matrix
    - ex: $m1->add($m2)->mul($m3)->max(255);
        - this will create several temp matricies 
        - a lazy version would prevent this 

    - operations do not immediately get applied
        - instead they are collected 
    - when the data is accessed, either:
        - all of it is calcuated at once (faster)
        - only the value's requested are calculated (slower)
        
    - the _slice method is the gateway to the $data array
    - any binary_op or unary_op can be lazyified
