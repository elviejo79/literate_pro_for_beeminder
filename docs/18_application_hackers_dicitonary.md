# 18 Application: Hacker's Dictionary

Search structures are for searching,
so let us look at one of the most straightforward applications for them:
a real dictionary.
We will use the public domain
The On-Line Hacker Jargon File,
version 2.9.9, 01 APR 1992, edited by Eric Raymond
(see the beginning of the included file for its history and full credits).
That file contains most of the entries in The New Hacker’s Dictionary [8].

## 18.1 Format of the Input
Our dictionary gets its entries from the raw jargon file.
The entries in the file look like this:

:adger: /aj’r/ [UCLA] vt. To make a boneheaded move with
consequences that could have been foreseen with a 
slight amount of mental effort. E.g. "He started
removing files and promptly adegered the whole project".
Compare {dumbass attack}.

:admin: /ad-min’/ Short for 'administrator';  very
commonly used in speech or on-line to refer to the 
systems person in charge on a computer. Common
construcitons of this include ‘sysadmin‘ and ‘site admin‘
(emphasizing the adminstrator's role as a site
contact for email and news) or ‘newsadmin‘ (focusing
specifically on news). Compare {postmaster}, {sysop},
{system mangler}.

Thus, entries are identified by the ‘:’ at the beginning of a line.
Everything up to the next ‘:’ is the key,
and then everything up to an empty line is the value (translation) for that key.

## 18.2 The Implementation

The dictionary design is so simple
(only two new classes) that it does not warrant a separate section.
Let us proceed to a study of the implementation.

In previous examples,
we had all assertion checking enabled.
In this example, running with assertion checks turned on may be unacceptably slow.
I recommend turning them all off in the Ace file (“assertion (no)”).

### 18.2.1 HACKERS_DICTIONARY

The main routine of the system is feature run of class `HACKERS_DICTIONARY`.
It creates a DICTIONARY _B_TREE and loads it with the entries from the file.

Then it repeatedly asks the user for a key and reports the matching value.

```Eiffel
class HACKERS_DICTIONARY
creation
    run
feature
    run is
        -- Main loop for the hacker's dictionary.
    local
        value: STRING;
    do
        print("Building the dictionary (this may take a while) ...%N");
        build("jargon/jargon");
        -- build is passed the path from the current directory to the Jargon file.
        print("Dictionary ready.%N%NEnter a word and I will give you its definition.%N");
        print("Hit end-of-file (control-d in Unix) to exit:%N");
        from
        until
            io.end_of_file
        loop
            io.read_line;
            value := dictionary.value(io.last_string);
            if value = Void then
                print("'");
                print(io.last_string);
                print("' is not in this dictionary.%N");
            else
                print(value);
                print("%N");
            end;
        end;
    end; -- run

feature {NONE}
    dictionary: DICTIONARY_B_TREE[STRING, STRING];

    build(file_name: STRING) is
        -- Build the dictionary from the jargon file named file_name.
    local
        file: FILE;
        -- Class FILE is presented in Appendix B,
        parsing_an_entry: BOOLEAN;
        line: STRING;
        end_of_key: INTEGER;
        key: STRING;
        value: STRING;
        entry_number: INTEGER;
    do
        file.make_open_read(file_name);
        dictionary.make_degree(33);
        -- You may want to experiment with the degree.
        from
        until
            file.end_of_file
        loop
            -- Skip to the first definition
            from
                parsing_an_entry := false;
            until
                file.end_of_file or else parsing_an_entry
            loop
                file.read_line;
                line := file.last_string;
                parsing_an_entry := line.count > 0 and then line.item(1) = ':';
            end;

            if parsing_an_entry then
                -- Find the matching ":".
                from
                    end_of_key := 2
                variant
                    line.count - end_of_key
                until
                    end_of_key > line.count or else line.item(end_of_key) = ":"
                loop
                    end_of_key := end_of_key + 1;
                end;

                key := line.substring(2, end_of_key-1);

                -- Start the value with the rest of this line.
                if end_of_key < line.count then
                    value := line.substring(end_of_key+1, line.count);
                else
                    value := clone("");
                end;

                -- Append the rest of the lines from this paragraph to value.
                from
                until
                    not parsing_an_entry or else file.end_of_file
                loop
                    file.read_line;
                    line := file.last_string;
                    parsing_an_entry := line.count > 0;
                    if parsing_an_entry then
                        value.append("%N");
                        value.append(line);
                    end;
                end;

                dictionary.put(value, key);
                
                debug
                    -- If debugging is enabled in Ace file, give progress reports every 50 entries.
                    entry_number := entry_number + 1;
                    if entry_number \\ 50 = 0 then
                        print(entry_number);
                        print(" entries (last key: ");
                        print(key);
                        print(")%N");
                    end;
                end;
            end;
        end;
        
        file.close;
        
        debug
            print(entry_number);
            print(" entries in the dictionary.%N");
        end;
    end; -- build
end -- class HACKERS_DICTIONARY
```

### 18.2.2 DICTIONARY_B_TREE

DICTIONARY_B_TREE is very similar to DICTIONARY_BST
(see Listing 15.11).
In fact, it is so similar, that a common ancestor
(such as DICTIONARY_SEARCH_TREE) may be called for
-but that I leave as an exercise for you.

```Eiffel
class DICTIONARY_B_TREE[KEY -> COMPARABLE, VALUE]

inherit DICTIONARY[KEY, VALUE]

creation 
    make, make_degree

feature {DICTIONARY_B_TREE}
    associations: B_TREE_LINKED[ASSOCIATION[KEY, VALUE]];
    -- The b-tree of associations.

feature -- Creation and initialization
    make is
        -- Create a new, empty dictionary using a b-tree of default degree.
    do
        make_degree(5);
    end; -- make

    make_degree(b_tree_degree: INTEGER) is
        -- Create a new, empty dictionary using a b-tree of specified degree.
    do
        !associations.make(b_tree_degree);
    end; -- make_degree

feature -- Adding, removing, and checking associations
    value(key: KEY): VALUE is
        -- The value associated with key in this dictionary.
        -- Void if there is no such association.
    local
        pattern: ASSOCIATION[KEY, VALUE];
        match: ASSOCIATION[KEY, VALUE];
    do
        !pattern.make;
        pattern.set_key(key);
        match := associations.item_equal_to(pattern);
        if match /= Void then
            Result := match.value;
        end;
        -- else leave Result void.
    end; -- value

    put(new_value: VALUE; key: KEY) is
        -- Insert an association of key and new_value into this dictionary.
        -- If the dictionary already contains an association for key, replace it.
    local
        pattern: ASSOCIATION[KEY, VALUE];
        match: ASSOCIATION[KEY, VALUE];
    do
        !pattern.make;
        pattern.set_key(key);
        match := associations.item_equal_to(pattern);
        if match = Void then
            !match.make;
            match.set_key(key);
            match.set_value(new_value);
            associations.insert(match);
        else
            match.set_value(new_value);
        end;
    end; -- put

    delete(key: KEY) is
        -- Delete the association for key from this dictionary.
    local
        pattern: ASSOCIATION[KEY, VALUE];
    do
        !pattern.make;
        pattern.set_key(key);
        associations.delete(pattern);
    end; -- delete

    wipe_out is
        -- Make this dictionary empty.
    do
        associations.wipe_out;
    end; -- wipe_out

feature -- Sizing
    size: INTEGER is
        -- The number of associations currently in this dictionary.
    do
        Result := associations.size;
    end; -- size

    is_empty: BOOLEAN is
        -- Is this dictionary empty?
    do
        Result := associations.is_empty;
    end; -- is_empty

    is_full: BOOLEAN is
        -- Is there no room in this dictionary for one more association?
    do
        Result := associations.is_full;
    end; -- is_full

feature -- Comparisons and copying
    copy(other: like Current) is
        -- Copy other onto Current.
    do
        associations := clone(other.associations);
    end; -- copy

    is_equal(other: like Current): BOOLEAN is
        -- Do this dictionary and other associate the same values
        -- with the same keys?
    do
        Result := associations.out.is_equal(other.associations.out);
    end; -- is_equal

feature -- Simple input and output
    out: STRING is
        -- "< (<key₁>.out,<value₁>.out) ... (<keyₙ>.out,<valueₙ>.out) >".
    do
        Result := clone("< ");
        Result.append(associations.out);
        Result.append(" >");
    end; -- out

invariant
    have_list: associations /= Void;

end -- class DICTIONARY_B_TREE
```

# Exercises
1. Experiment with the degree of the tree to see how it affects performance.

2. Create a common ancestor for classes `DICTIONARY_BST` and `DICTIONARY_B_TREE`.

3. Modify HACKERS_DICTIONARY so that the user can specify the name
for the jargon file (for example, on the command line 
-you may need to peruse the manuals for your specific compiler and system for that).

4. Modify the program so that it ignores the case of the key
(i.e., the user can type in the key in either uppercase,
lowercase, or mixed case, and still match the key stored in the dictionary).
(Hint:Look at class STRING in Appendix B.)


