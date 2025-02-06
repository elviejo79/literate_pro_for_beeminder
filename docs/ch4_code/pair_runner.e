note
	description: "Summary description for {PAIR_RUNNER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PAIR_RUNNER

create
	test
feature
	test -- Test a PAIR.
		local
			pair: PAIR [LETTER, LETTER]
			letter1: LETTER
			letter2: LETTER
		do
			create {ENHANCED_PAIR [LETTER, LETTER]} pair.make;

			print ("New pair created.%N You should see (-void-,-void-)")
			print (pair);
			print ("%N");
			create Letter1.make ('a');
			pair.set_first (letter1);
			print ("First item set to ’a’.%N You should see’ (a,-void-)")
			print (pair);
			print ("%N");
			create Letter2.make ('b');
			pair.set_second (letter2);
			print (pair);
			print ("%NTestitem set to ‘’b’.%N You should see '’(a,b)’: done. %N")
		end

end
