note

	description:

		"Short description of the class"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2011, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_RESOLVER


inherit

	XM_SHARED_CATALOG_MANAGER

	UT_SHARED_URL_ENCODING


feature -- Resolver

	cat (a_url: STRING): detachable JRS_LINES_ITERATOR
		obsolete "does not work yet"
		require
			a_url_not_empty: a_url /= Void and then not a_url.is_empty
			a_url_valid: not Url_encoding.has_excluded_characters (a_url)
		local
			s: KI_CHARACTER_INPUT_STREAM
		do
			s := url_to_stream (a_url)
			-- TODO: this doesn't work, so this `cat' won't work
			if attached {KI_TEXT_INPUT_STREAM} s as ts then
				create {JRS_LINES_STREAM_ITERATOR} Result.make (ts)
			end
		ensure
			not_void: Result /= Void
		end

	url_to_stream (a_url: STRING): detachable KI_CHARACTER_INPUT_STREAM
		require
			a_url_not_empty: a_url /= Void and then not a_url.is_empty
			a_url_valid: not Url_encoding.has_excluded_characters (a_url)
		do
			resolver.resolve_uri (a_url)
			Result := resolver.last_stream
		end


feature {NONE} -- Implementation

	resolver: XM_SIMPLE_URI_EXTERNAL_RESOLVER
			-- Resolver for "file:", "http:" and "https:" scheme
		require
			valid_resolver: attached {XM_SIMPLE_URI_EXTERNAL_RESOLVER} shared_catalog_manager.bootstrap_resolver.uri_scheme_resolver
		local
			a_file: XM_FILE_URI_RESOLVER
			a_http: EPX_HTTP_URI_RESOLVER
			a_https: EPX_HTTP_URI_RESOLVER
		once
			if attached {XM_SIMPLE_URI_EXTERNAL_RESOLVER} shared_catalog_manager.bootstrap_resolver.uri_scheme_resolver as r then
				create a_file.make
				r.register_scheme (a_file)
				create a_http.make (r.uris)
				r.register_scheme (a_http)
				create a_https.make (r.uris)
				r.register_scheme (a_https)
				Result := r
			end
				check attached Result end
		ensure
			result_not_void: Result /= Void
		end

end
