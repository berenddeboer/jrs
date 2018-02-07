note

	description:

		"ODBC interface."

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2010, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_ODBC


inherit

	JRS_BASE
		rename
			echo as terminal_echo
		end


inherit {NONE}

	MEMORY
		redefine
			dispose
		end

  UC_SHARED_STRING_EQUALITY_TESTER


feature -- Command

	execute_sql (a_data_source: STRING; an_sql: STRING; a_parameters: TUPLE)
		require
			data_source_not_empty: a_data_source /= Void and then not a_data_source.is_empty
			not_empty: an_sql /= Void and then not an_sql.is_empty
		local
			stmt: JRS_ECLI_STATEMENT
			sql: STRING
		do
			sql := format_sql (an_sql, a_parameters)
			create stmt.make (session (a_data_source))
			debug ("jrs-print-sql")
				print (sql + "%N")
			end
			stmt.set_sql (sql)
			stmt.execute
			stmt.close
		rescue
			-- Print SQL in case something failed
			if stmt /= Void and then not stmt.is_ok then
				print ("SQL query failed: " + sql + "%N")
				print ("Error message: " + stmt.diagnostic_message + "%N")
			end
		end

	set_row (a_data_source: STRING; an_sql: STRING; a_parameters: TUPLE; a_row: TUPLE)
			-- Execute query, and retrieve a single row if query returns
			-- results, and put this in `a_row'.
		require
			data_source_not_empty: a_data_source /= Void and then not a_data_source.is_empty
			not_empty: an_sql /= Void and then not an_sql.is_empty
			row_not_empty: a_row /= Void
		local
			stmt: JRS_ECLI_STATEMENT
			sql: STRING
		do
			sql := format_sql (an_sql, a_parameters)
			create stmt.make (session (a_data_source))
			stmt.set_sql (sql)
			stmt.execute
			if stmt.is_executed and then stmt.has_result_set then
				stmt.tuple_bind (a_row)
				stmt.start
			end
			stmt.close
		end


feature -- Status

	query (a_data_source: STRING; an_sql: STRING; a_parameters: detachable TUPLE; a_row_format: TUPLE): JRS_ROWS_ITERATOR [like a_row_format]
			-- Rows returned by executing `an_sql'
			-- `an_sql' is a query like: "select * from table where id = $i"
			-- or: "select * from table where name = '$s'".
			-- All parameters in `a_parameters' should appear in the
			-- order given in the query and be of the appropriate type.
		require
			data_source_not_empty: a_data_source /= Void and then not a_data_source.is_empty
			not_empty: an_sql /= Void and then not an_sql.is_empty
			row_format_not_void: a_row_format /= Void
		local
			stmt: JRS_ECLI_STATEMENT
			sql: STRING
		do
			sql := format_sql (an_sql, a_parameters)
			create stmt.make (session (a_data_source))
			stmt.set_sql (sql)
			stmt.execute
			create Result.make (stmt, a_row_format)
		end

	query_value (a_data_source: STRING; an_sql: STRING; a_parameters: TUPLE): detachable STRING
			-- `an_sql' should be a query that returns a single value
			-- (more values are ignored) and a single row (more rows are
			-- ignored).
			-- If the query does not return any rows, Void is returned.
		require
			data_source_not_empty: a_data_source /= Void and then not a_data_source.is_empty
			not_empty: an_sql /= Void and then not an_sql.is_empty
		local
			single_value: TUPLE [id: detachable STRING]
		do
			create single_value
			set_row (a_data_source, an_sql, a_parameters, single_value)
			Result := single_value.id
		end

	query_set (a_data_source: STRING; an_sql: STRING; a_parameters: TUPLE): DS_HASH_SET [STRING]
			-- `an_sql' should be a query that returns a single value
			-- (more values are ignored).
			-- The value for every row is returned as a set
		require
			data_source_not_empty: a_data_source /= Void and then not a_data_source.is_empty
			not_empty: an_sql /= Void and then not an_sql.is_empty
		local
			single_value: TUPLE [id: detachable STRING]
		do
			create single_value
			create temp_set.make (16)
			temp_set.set_equality_tester (string_equality_tester)
			query (a_data_source, an_sql, a_parameters, single_value).rows (agent (a_row: TUPLE [id: STRING]; other: JRS_ROWS_ITERATOR_DATA): BOOLEAN
				do
				  temp_set.force (a_row.id)
				end)
			Result := temp_set
		end

	session (a_data_source: STRING): ECLI_SESSION
			-- New or existing session
		require
			data_source_not_empty: a_data_source /= Void and then not a_data_source.is_empty
		local
			login: ECLI_SIMPLE_LOGIN
			my_session: ECLI_SESSION
		do
			if not data_sources.has (a_data_source) then
				create login.make (a_data_source, "", "")
				create my_session.make_default
				my_session.set_login_strategy (login)
				my_session.connect
				if my_session.is_connected then
					my_session.raise_exception_on_error
				else
					stderr.put_line ("Cannot open data source '" + a_data_source + "'.")
					stderr.put_line ("Error message: " + my_session.diagnostic_message)
					exit_with_failure
				end
				data_sources.force_last (my_session, a_data_source)
				setup_connection (a_data_source)
			end
			Result := data_sources.item (a_data_source)
		ensure
			not_void: Result /= Void
			cached: data_sources.has (a_data_source)
		end


	setup_connection (a_data_source: STRING)
			-- Prepare connection for use
		require
			data_source_not_empty: a_data_source /= Void and then not a_data_source.is_empty
		do
			-- Require all data to be passed in UTF8
			--execute_sql (a_data_source, "set names 'utf8'", Void)
			-- This didn't work!!
			-- The ODBC connection must specify 'charset=utf8'
		end


feature -- Cleanup

	dispose
			-- Close handle if owner.
		do
			from
				data_sources.start
			until
				data_sources.after
			loop
				if data_sources.item_for_iteration.is_connected then
					data_sources.item_for_iteration.disconnect
				end
				data_sources.forth
			end
			data_sources.wipe_out
		end


feature {NONE} -- Implementation

	data_sources: DS_HASH_TABLE [ECLI_SESSION, STRING]
		once
			create Result.make (2)
		end

	temp_set: DS_HASH_SET [STRING]


end
