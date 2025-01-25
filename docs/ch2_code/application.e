note
	description: "ch2 application root class"
	date: "$Date$"
	revision: "$Revision$"

class
	APPLICATION

inherit
	ARGUMENTS_32

create
	make

feature {NONE} -- Initialization

	make
			-- Run application.
  local
    a_letter: LETTER;
  do
    create a_letter.make('J');
    print("The letter ");
    print (a_letter);
    print(" is number ");
    print (a_letter.alphabet_position);
    print(" in the alphabet .%N");
    check
      a_letter.is_upper_case;
    end;

    a_letter.set_character('k');
    print("The letter ");
    print (a_letter);
    print(" is number ");
    print (a_letter.alphabet_position);
    print(" in the alphabet.%N");
    check
      a_letter.is_lower_case;
    end;

    print("%NTest finished. %N");
   end

end
