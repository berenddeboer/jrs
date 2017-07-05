About
=====
This is an attempt to use Eiffel to write shell scripts.

Safe shell scripts are not that easy to write, most of them happily
continue in case of errors.

So why not use Eiffel to it better?

The idea is to write shell scripts the jQuery way. To see how this works.

Examples:

  ls ("*.html").grep ("whatever").words (agent ...)

  ls (<<"system/test.inc", "modules/test.inc">>).each (agent (a_path_name: STRING): BOOLEAN
    do
       ...
     end)



Status
======
State of the code: somewhat useful.
