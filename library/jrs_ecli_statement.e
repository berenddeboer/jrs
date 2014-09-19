note

	description:

		"ODBC commands"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2011, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_ECLI_STATEMENT


inherit

	ECLI_STATEMENT
		redefine
			fill_results
		end

inherit {NONE}

ECLI_TYPE_CONSTANTS
		undefine
			default_create
		end


create

	make


feature -- Basic operations

	tuple_bind (a_parameters: TUPLE)
			-- Auto bind tuple, so values reflect current record.
			-- Supports two modes: if TUPLE has only one attribute and
			-- this is a DS_HASH_SET, this is treated as fields.
			-- Else we bind the individual attributes of the tuple.
		require
			valid_statement: is_valid
			executed_or_prepared: is_prepared or else is_executed
			has_results: has_result_set
			only_allowed_reference_in_parameters_is_string: True
			result_description_and_parameters_compatible: True
			appropriate_tuple: is_fields_tuple (a_parameters) or else a_parameters.count = result_columns_count
		do
			results_tuple := a_parameters
			if results_description.count /= result_columns_count
			then
				describe_results
			end
			if is_fields_tuple (a_parameters) then
				tuple_bind_fields (a_parameters)
			else
				tuple_bind_tuple (a_parameters)
			end
		end


feature -- Access

	maximum_string_size: INTEGER
			-- 16MB
		once
			Result := 16 * 1024 * 1024
		ensure
			positive: Result > 0
		end

	fields_anchor: DS_HASH_TABLE [STRING, READABLE_STRING_GENERAL]
		once
			create Result.make (0)
		end


feature -- status

	is_fields_tuple (t: TUPLE):BOOLEAN
			-- Will this tuple be treated as a row with fields?
		do
			Result :=
				t.count = 1 and then
				t.valid_type_for_index (fields_anchor, t.lower)
		end


feature {NONE} -- Implementation

	results_tuple: TUPLE

	tuple_bind_fields (a_parameters: TUPLE)
			-- Auto bind tuple, so its fields reflect current record.
		require
			valid_statement: is_valid
			executed_or_prepared: is_prepared or else is_executed
			has_results: has_result_set
			only_allowed_reference_in_parameters_is_string: True
			result_description_and_parameters_compatible: True
			appropriate_tuple: is_fields_tuple (a_parameters)
		local
			descr: ECLI_COLUMN_DESCRIPTION
			column: ECLI_VALUE
			i: INTEGER
			v: ARRAY [ECLI_VALUE]
			h: like fields_anchor
		do
			create h.make (result_columns_count)
			results_tuple.put (h, results_tuple.lower)
			create v.make_filled (Void, 1, result_columns_count)
			from
				i := v.lower
			until
				i > v.upper
			loop
				descr := results_description.item (i)
				-- How do we know if our strings are UTF8?
				-- Perhaps check if anchor is STRING or UC_STRING ?
				if descr.size = 0 or else descr.size * 4 > maximum_string_size then
					create {ECLI_UTF8_STRING} column.make_force_maximum_capacity (maximum_string_size)
				else
					create {ECLI_UTF8_STRING} column.make_force_maximum_capacity ((descr.size * 4).to_integer_32)
				end
				v.put (column, i)
				i := i + 1
			end
			set_results (v)
		end

	tuple_bind_tuple (a_parameters: TUPLE)
			-- Auto bind tuple, so values reflect current record.
			-- TODO: transform transformable checks into precondition
		require
			valid_statement: is_valid
			executed_or_prepared: is_prepared or else is_executed
			has_results: has_result_set
			only_allowed_reference_in_parameters_is_string: True
			result_description_and_parameters_compatible: True
			tuple_has_enough_elements: a_parameters.count = result_columns_count
		local
			descr: ECLI_COLUMN_DESCRIPTION
			column: ECLI_VALUE
			i: INTEGER
			v: ARRAY [ECLI_VALUE]
		do
			create v.make_filled (Void, 1, result_columns_count)
			from
				i := v.lower
			until
				i > v.upper
			loop
				descr := results_description.item (i)
				--print (descr.name + "%N")
				--print ("  " + descr.sql_type_code.out + "%N")
				--print ("  " + descr.size.out + "%N")
				inspect results_tuple.item_code (i)
				when boolean_code then
					create {ECLI_BOOLEAN} column.make
				when integer_32_code then
					create {ECLI_INTEGER} column.make
				when reference_code then
					if results_tuple.valid_type_for_index (string_type, i) then
						-- Allocate more, could be UTF8 so it appears size
						-- reflects Unicode characters, not bytes
						if descr.size = 0 or else descr.size * 4 > maximum_string_size then
							create {ECLI_LONGVARCHAR} column.make_force_maximum_capacity (maximum_string_size)
						else
							create {ECLI_LONGVARCHAR} column.make_force_maximum_capacity ((descr.size * 4).to_integer_32)
						end
					elseif results_tuple.valid_type_for_index (uc_string_type, i) then
						-- How do we know if our strings are UTF8?
						if descr.size = 0 or else descr.size * 4 > maximum_string_size then
							create {ECLI_UTF8_STRING} column.make_force_maximum_capacity (maximum_string_size)
						else
							create {ECLI_UTF8_STRING} column.make_force_maximum_capacity ((descr.size * 4).to_integer_32)
						end

					elseif results_tuple.valid_type_for_index (date_time_type, i) then
						-- At least with MDB driver we cannot convert a
						-- varchar to a date/time, and it is unlikely any
						-- driver would support his.
						if descr.sql_type_code /= Sql_longvarchar then
							create {ECLI_TIMESTAMP} column.make_default
						else
							raise ("Cannot bind DT_DATE_TIME class to varchar column")
						end
					else
						-- Cannot transform
						raise ("Cannot bind ODBC data to a class of this type")
					end
				else
					-- Cannot transform
					raise ("Cannot bind ODBC data to a class of this type")
				end
				v.put (column, i)
				i := i + 1
			end
			set_results (v)
		end

	fill_results
		do
			precursor
			if is_fields_tuple (results_tuple) then
				fill_results_fields
			else
				fill_results_tuple
			end
		end

	fill_results_fields
			-- Put bound values into a hash table.
		require
			results_as_fields: is_fields_tuple (results_tuple)
		local
			i: INTEGER
			v: ECLI_VALUE
		do
			if attached {like fields_anchor} results_tuple.item (results_tuple.lower) as h then
				h.wipe_out
				from
					i := results_description.lower
				until
					i > results_description.upper
				loop
					v := results.item (i)
					h.force_last (v.out, results_description.item (i).name)
					i := i + 1
				end
			end
		end

	fill_results_tuple
			-- Put bound values into the tuple.
		local
			i: INTEGER
			v: ECLI_VALUE
		do
			from
				i := results_description.lower
			until
				i > results_description.upper
			loop
				v := results.item (i)
				inspect results_tuple.item_code (i)
				when boolean_code then
					if not v.is_null then
						results_tuple.put (v.as_boolean, i)
					else
						results_tuple.put (False, i)
					end
				when integer_32_code then
					if not v.is_null then
						results_tuple.put (v.as_integer, i)
					else
						results_tuple.put (0, i)
					end
				when reference_code then
					-- For dynamic types, we try to do something smarter
					if not v.is_null then
						if results_tuple.valid_type_for_index (string_type, i) then
							results_tuple.put (v.as_string, i)
						elseif results_tuple.valid_type_for_index (date_time_type, i) then
							results_tuple.put (v.as_timestamp, i)
						else
							-- Can't transform
						end
					else
						results_tuple.put (Void, i)
					end
				else
					-- Oops, can't copy
				end
				i := i + 1
			end
		end

	string_type: STRING
		once
			create Result.make_empty
		ensure
			not_void: Result /= Void
		end

	uc_string_type: UC_STRING
		once
			create Result.make_empty
		ensure
			not_void: Result /= Void
		end

	date_time_type: DT_DATE_TIME
		once
			create Result.make (1, 1, 1, 1, 1, 1)
		ensure
			not_void: Result /= Void
		end


feature {NONE} -- Had to be copied from TUPLE

	reference_code: NATURAL_8 = 0x00
	boolean_code: NATURAL_8 = 0x01
	character_8_code, character_code: NATURAL_8 = 0x02
	real_64_code: NATURAL_8 = 0x03
	real_32_code: NATURAL_8 = 0x04
	pointer_code: NATURAL_8 = 0x05
	integer_8_code: NATURAL_8 = 0x06
	integer_16_code: NATURAL_8 = 0x07
	integer_32_code: NATURAL_8 = 0x08
	integer_64_code: NATURAL_8 = 0x09
	natural_8_code: NATURAL_8 = 0x0A
	natural_16_code: NATURAL_8 = 0x0B
	natural_32_code: NATURAL_8 = 0x0C
	natural_64_code: NATURAL_8 = 0x0D
	character_32_code, wide_character_code: NATURAL_8 = 0x0E
	any_code: NATURAL_8 = 0xFF
			-- Code used to identify type in TUPLE.

end
