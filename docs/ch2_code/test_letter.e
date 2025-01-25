note
	description: "[
			Eiffel tests that can be executed by testing tool.
		]"
	author: "EiffelStudio test wizard"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	TEST_LETTER

inherit
	EQA_TEST_SET

feature
	test_creation
			--Test an object of class LETTER
		local
			a_letter: LETTER
		do
			create a_letter.make ('J')

			assert ("it must be uppercase", a_letter.is_upper_case)
			assert ("it must be what is capital J position", 10 = a_letter.alphabet_position)

			a_letter.set_character ('k')
			assert ("the new letter must be number", 11 = a_letter.alphabet_position)
			assert ("must be lower case", a_letter.is_lower_case)
		end

end

