note
	description: "ch4_code application root class"
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
			-- Test an ENHANCED_PAIR.
		local
			pair: ENHANCED_PAIR [LETTER, LETTER]
			pair_runner: PAIR_RUNNER
			letter1: LETTER
			letter2: LETTER
		do
			create pair_runner.test
			
			create pair.make;
			print ("New pair created.%N You should see '(-void-,-void-)'")
			print (pair);
			print ("%NLast position changed (you should  see '0´):");
			print (pair.last_change);
			print ("%N");
			create letter1.make ('a');
			pair.set_first (letter1);
			print ("First item set to 'a'.%N You should see '(a,-void-)':");
			print (pair);
			print ("%NLast position changed (you should see '1´):");

			print (pair.last_change);
			print ("%N");
			create letter2.make ('b');
			pair.set_second (letter2);
			print ("%NSecond item set to 'b'.")
			print (pair);
			print ("%N You (you see '(a,b)': ");

			print (pair.last_change);

			print ("%N changed position you should see '2'): ");

			print ("%NTest done. %N");
		end;

end
