deferred class BINARY_TREE_EXAMPLE [ITEM -> ANY]

inherit
	ANY
		undefine
			copy, is_equal
		redefine
			out, is_equal
		end

feature -- Creation and initialization
	make, wipe_out
			-- Make this an empty tree.
		deferred
		ensure
			empty: is_empty
		end -- make, wipe_out
feature -- Accessing the components
	left: like Current
			-- The left subtree.
		deferred
		end -- left

	right: like Current
			-- The right subtree.
		deferred
		end -- right

	root_item: ITEM
			-- The item at the root.
		deferred
		end -- root_item
feature -- Sizing
	is_empty: BOOLEAN
			-- Is this tree empty?
		deferred
		end -- is_empty

	size: INTEGER
			-- The number of items in this tree.
			-- Left as an exercise.

	height: INTEGER
			-- The number of levels in this tree.
		do
			if is_empty then
				Result := 0
			else
				Result := 1 + left.height.max (right.height)
			end
		end -- height
feature -- Comparisons and copying
	is_equal (other: like Current): BOOLEAN
		deferred
				-- Do this tree and other have identical structures
				-- and track the same items at the corresponding nodes?
				-- Left as an exercise.
		end

feature -- Simple input and output
	out: STRING
			-- "(left.out / root_item.out \ right.out)" or "" if empty.
		do
			if is_empty then
				Result := ""
			else
				Result := "("
				Result.append_string (left.out)
				Result.append_string ("/")
				Result.append_string (root_item.out)
				Result.append_string ("\")
				Result.append_string (right.out)
				Result.append_string (")")
			end
		end -- out

invariant
	empty_if_size_zero: is_empty = (size = 0)
	size_not_negative: size >= 0

end -- class BINARY_TREE
