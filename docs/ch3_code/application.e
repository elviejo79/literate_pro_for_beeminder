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
			test_runner: PAIR_RUNNER
		do
			create test_runner.test
		end

end
