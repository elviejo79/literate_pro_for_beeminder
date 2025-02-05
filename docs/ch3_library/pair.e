note
	description: "Summary description for {PAIR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class PAIR [ITEM1, ITEM2]

inherit

	ANY
		redefine
			out

		end
create
	make

feature
	first: detachable ITEM1 -- First item.
	second: detachable ITEM2 -- Second item.

	make
			-- Initialization.
		do

		end

	set_first (an_item: ITEM1)
			--Track an_item as first item.
		do
			first := an_item
		ensure
			first_was_replaced: first = an_item
			second_is_same: second = old second
			second_is_unchanged:
				attached old first as old_first
				and then attached first as new_first
				implies
				new_first.is_equal (old_first.deep_twin)
		end

	set_second (an_item: ITEM2)
			--Track an_item as second item.
		do
			second := an_item
		ensure
			second_was_replaced: second = an_item
			first_is_same: first = old first
			first_is_unchanged:
				attached old first as old_first
				and then attached first as new_first
				implies
				new_first.is_equal (old_first.deep_twin)
		end

	out: STRING
			--Printable representation of the pair
			--(void items replaced with "-void-").
		do
			if attached first as x and attached second as y then
				Result := "(" + x.out +"," + y.out + ")"
			elseif attached first as x and not attached second then
				Result := "(" + x.out + ",-void-)"
			elseif not attached first and attached second as x then
				Result := "(-void-," + x.out+")"
			else
				Result := "(-void-, -void-)"
			end
		end

end
