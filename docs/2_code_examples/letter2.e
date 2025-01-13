class LETTER inherit
    ANY
        redefine
            out
        end;
creation make
feature
    character: CHARACTER; 
    --The character representation of the letter.
    make (initial: CHARECTER) 
    --Create a new letter, load it with initial.
    require
    do 
        character := initial
    end;

    set_character(new: CHARACTER) 
    -- Change the letter to new. 
    require (('a' <= new and new <= 'z') or ('A' <= new and new <= 'Z')) do 
        character := new
    end;

    is_lower_case: BOOLEAN  
    -- Is this a lower case letter? 
    do 
        Result := 'a' <= character and character <= 'z'
    end; 

    is_upper_case: BOOLEAN 
    -- Is this an upper case letter? 
    do 
        Result := 'A' <= character and character <= 'Z'
    end; 

    alphabet_position: INTEGER 
    -- Relative position in the English alphabet (A = 1). 
    do
        if is_upper_case then     
            Result := character.code - ('A').code + 1 
        else         
            Result := character.code - ('a').code + 1 
        end; 
    end; 

    out: STRING 
    -- String representation of this letter. 
    do 
        Result := character.out
    end; 

invariant 
    either upper_or_lower: is_upper_case /= is_lower_case
end