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


create

	make


feature -- Basic operations

	tuple_bind (a_parameters: TUPLE)
			-- Auto bind parameters.
		require
			valid_statement: is_valid
			executed_or_prepared: is_prepared or else is_executed
			has_results: has_result_set
			only_allowed_reference_in_parameters_is_string: True
			result_description_and_parameters_compatible: True
		local
			descr: ECLI_COLUMN_DESCRIPTION
			column: ECLI_VALUE
			v: ARRAY [ECLI_VALUE]
			i: INTEGER
		do
			results_tuple := a_parameters
			if
				results_description = Void or else
				results_description.count = result_columns_count
			then
				describe_results
			end
			create v.make (1, result_columns_count)
			from
				i := v.lower
			until
				i > v.upper
			loop
				descr := results_description.item (i)
				inspect results_tuple.item_code (i)
				when boolean_code then
					create {ECLI_BOOLEAN} column.make
				when integer_32_code then
					create {ECLI_INTEGER} column.make
				else
					-- How do we know if our strings are UTF8?
					if descr.size * 4 > maximum_string_size then
						create {ECLI_UTF8_STRING} column.make_force_maximum_capacity (maximum_string_size)
					else
						create {ECLI_UTF8_STRING} column.make_force_maximum_capacity (descr.size * 4)
					end
				end
				v.put (column, i)
				i := i + 1
			end
			set_results (v)
		end


feature -- Access

	maximum_string_size: INTEGER
			-- 16MB
		once
			Result := 16 * 1024 * 1024
		ensure
			positive: Result > 0
		end


feature {NONE} -- Implementation

	results_tuple: TUPLE

	fill_results
		local
			i: INTEGER
		do
			precursor
			from
				i := results_description.lower
			until
				i > results_description.upper
			loop
				inspect results_tuple.item_code (i)
				when boolean_code then
					results_tuple.put (results.item (i).as_boolean, i)
				when integer_32_code then
					results_tuple.put (results.item (i).as_integer, i)
				else
					results_tuple.put (results.item (i).as_string, i)
				end
				i := i + 1
			end
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
