note
	description: "ch3_code_single_thread application root class"
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
			--Test a PAIR
		local
			pair: PAIR [LETTER, LETTER]
			letter1: LETTER
			letter2: LETTER
		do
			create pair.make
			print("New pair created.%N You should see (-void-, -void-)")
			print(pair)
			print("%N")

			create letter1.make ('a')
			pair.set_first (letter1)
			print("First item set to 'a'.%N you should see (a, -void-)")
			print(pair)
			print("%N")

			create letter2.make ('b')
			pair.set_second (letter2);
			print("Second item set to 'b'.%N You should see '(a,b)'")
			print (pair)
			print("%N Test done.%N");
		end

end
